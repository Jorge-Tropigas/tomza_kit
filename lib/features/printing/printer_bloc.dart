import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'printer_device.dart';
import 'native_bixolon.dart';

enum PrinterDocKind { invoice, record }

class PrinterDocument {
  final String name;
  final Uint8List bytes;

  PrinterDocument({
    required this.name,
    required this.bytes,
  });
}

typedef PrinterPrintCallback = Future<bool> Function({
  required Uint8List pdfBytes,
  required String macAddress,
  required int dpi,
  required double paperWidthInches,
});

class PrinterArguments {
  final List<PrinterDocument> documents;
  final PrinterPrintCallback? onPrint;
  final VoidCallback? onTapBack;
  final VoidCallback? onSuccessPrint;
  final String? backConfirmationTitle;
  final String? backConfirmationDescription;
  final Widget Function(BuildContext context, Uint8List pdfBytes)? pdfViewerBuilder;

  @Deprecated('Use documents instead')
  final Uint8List? documentBytes;
  @Deprecated('Use documents instead')
  final Uint8List? recordBytes;
  @Deprecated('Use onTapBack instead')
  final VoidCallback? onTap;

  PrinterArguments({
    List<PrinterDocument>? documents,
    this.onPrint,
    this.onTapBack,
    this.onSuccessPrint,
    this.backConfirmationTitle,
    this.backConfirmationDescription,
    this.pdfViewerBuilder,
    this.documentBytes,
    this.recordBytes,
    this.onTap,
  })  : documents = documents ?? [
          if (documentBytes != null && documentBytes.isNotEmpty)
            PrinterDocument(name: 'Factura', bytes: documentBytes),
          if (recordBytes != null && recordBytes.isNotEmpty)
            PrinterDocument(name: 'Constancia', bytes: recordBytes),
        ];
}

class PrinterBloc extends ChangeNotifier {
  PrinterBloc({required this.printerArgs}) {
    if (printerArgs.documents.isNotEmpty) {
      _selectedDocument = printerArgs.documents.first;
    }
    _init();
  }

  final PrinterArguments printerArgs;

  PrinterDocument? _selectedDocument;
  PrinterDocument? get selectedDocument => _selectedDocument;

  Uint8List? get pdfBytes => _selectedDocument?.bytes;

  // Compatibility getter/setter for legacy enum-based docKind
  PrinterDocKind get docKind {
    if (_selectedDocument != null) {
      if (_selectedDocument!.name.toLowerCase().contains('constancia') ||
          _selectedDocument!.name.toLowerCase().contains('record')) {
        return PrinterDocKind.record;
      }
    }
    return PrinterDocKind.invoice;
  }

  bool get hasInvoice => printerArgs.documents.any((d) =>
      d.name.toLowerCase().contains('factura') ||
      d.name.toLowerCase().contains('invoice'));

  bool get hasRecord => printerArgs.documents.any((d) =>
      d.name.toLowerCase().contains('constancia') ||
      d.name.toLowerCase().contains('record'));

  void setDocKind(PrinterDocKind kind) {
    final String lookFor = kind == PrinterDocKind.record ? 'constancia' : 'factura';
    try {
      final doc = printerArgs.documents.firstWhere(
        (d) => d.name.toLowerCase().contains(lookFor) ||
            (kind == PrinterDocKind.record
                ? d.name.toLowerCase().contains('record')
                : d.name.toLowerCase().contains('invoice')),
      );
      setSelectedDocument(doc);
    } catch (_) {
      // If not found by name, fallback to index
      if (kind == PrinterDocKind.invoice && printerArgs.documents.isNotEmpty) {
        setSelectedDocument(printerArgs.documents.first);
      } else if (kind == PrinterDocKind.record && printerArgs.documents.length > 1) {
        setSelectedDocument(printerArgs.documents[1]);
      }
    }
  }

  void setSelectedDocument(PrinterDocument doc) {
    if (_selectedDocument == doc) return;
    _selectedDocument = doc;
    notifyListeners();
  }

  // Estado de UI / errores
  bool _busy = false;
  bool get busy => _busy;
  String? _error;
  String? get error => _error;

  void _setBusy(bool v) {
    _busy = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  // Impresoras emparejadas y selección
  List<PrinterDevice> _paired = <PrinterDevice>[];
  List<PrinterDevice> get pairedDevices => List.unmodifiable(_paired);
  PrinterDevice? _selected;
  PrinterDevice? get selected => _selected;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  int? _androidSdkIntCache;

  void _setPaired(List<PrinterDevice> list) {
    _paired = list;
    if (_selected != null &&
        !_paired.any((PrinterDevice p) => p.id == _selected!.id)) {
      _selected = null;
    }
    notifyListeners();
  }

  void setSelected(PrinterDevice? dev) {
    _selected = dev;
    notifyListeners();
  }

  Future<void> _init() async {
    _setBusy(true);
    _setError(null);
    _setBusy(false);
    await discoverPairedPrinters();
  }

  Future<bool> _ensureBluetoothPerms() async {
    try {
      final List<Permission> perms = await _bluetoothPermissionsByApi();
      if (perms.isEmpty) {
        return true;
      }
      final Map<Permission, PermissionStatus> results = await perms.request();
      final bool allGranted = perms.every(
        (Permission permission) => results[permission]?.isGranted ?? false,
      );
      if (!allGranted) {
        final bool anyPermanentlyDenied = perms.any(
          (Permission permission) =>
              results[permission]?.isPermanentlyDenied ??
              results[permission]?.isRestricted ??
              false,
        );
        if (anyPermanentlyDenied) {
          await openAppSettings();
        }
      }
      return allGranted;
    } catch (e) {
      dev.log('[PrinterBloc] Bluetooth permission error: $e');
      return false;
    }
  }

  Future<void> discoverPairedPrinters() async {
    _setBusy(true);
    _setError(null);
    try {
      if (!await _ensureBluetoothPerms()) {
        _setPaired(<PrinterDevice>[]);
        _setError('Permisos de Bluetooth no concedidos');
        return;
      }
      final List<BluetoothDevice> bonded =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      final List<PrinterDevice> list = bonded
          .map(
            (BluetoothDevice d) =>
                PrinterDevice(id: d.address, name: d.name ?? d.address),
          )
          .toList();
      _setPaired(list);
    } catch (e) {
      _setError('Error listando impresoras: $e');
      _setPaired(<PrinterDevice>[]);
    } finally {
      _setBusy(false);
    }
  }

  Future<List<Permission>> _bluetoothPermissionsByApi() async {
    if (!Platform.isAndroid) {
      return <Permission>[Permission.bluetooth];
    }
    final int sdkInt = await _androidSdkInt();
    if (sdkInt >= 31) {
      return <Permission>[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
      ];
    }
    return <Permission>[Permission.bluetooth, Permission.locationWhenInUse];
  }

  Future<int> _androidSdkInt() async {
    if (_androidSdkIntCache != null) {
      return _androidSdkIntCache!;
    }
    try {
      final AndroidDeviceInfo info = await _deviceInfo.androidInfo;
      _androidSdkIntCache = info.version.sdkInt;
    } catch (_) {
      _androidSdkIntCache = -1;
    }
    return _androidSdkIntCache!;
  }

  Future<void> openBluetooth() async {
    try {
      final bool granted = await _ensureBluetoothPerms();
      if (!granted) {
        _setError('Permisos de Bluetooth requeridos');
        return;
      }

      bool enabled = false;
      try {
        enabled = (await FlutterBluetoothSerial.instance.isEnabled) ?? false;
      } catch (_) {}

      if (!enabled) {
        try {
          final bool? res =
              await FlutterBluetoothSerial.instance.requestEnable();
          enabled = res == true;
        } catch (_) {
          enabled = false;
        }
      }

      if (!enabled) {
        await openAppSettings();
      }
    } catch (e) {
      await openAppSettings();
    }
  }

  Future<void> showSelectDialog(BuildContext context) async {
    if (_paired.isEmpty) await discoverPairedPrinters();
    if (!context.mounted) return;
    final PrinterDevice? chosen = await showDialog<PrinterDevice?>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Seleccionar impresora'),
        content: SizedBox(
          width: double.maxFinite,
          child: _paired.isEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('No se encontraron impresoras emparejadas'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        await openBluetooth();
                        await discoverPairedPrinters();
                      },
                      child: const Text('Abrir Bluetooth'),
                    ),
                  ],
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _paired.length,
                  itemBuilder: (BuildContext c, int i) {
                    final PrinterDevice d = _paired[i];
                    return ListTile(
                      title: Text(d.name),
                      subtitle: Text(d.id),
                      onTap: () => Navigator.pop(ctx, d),
                    );
                  },
                ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
    if (chosen != null) setSelected(chosen);
  }

  Future<File> _saveToTemp(Uint8List bytes, {String? name}) async {
    final Directory dir = await getTemporaryDirectory();
    final String path =
        '${dir.path}${Platform.pathSeparator}${name ?? 'doc_${DateTime.now().millisecondsSinceEpoch}'}.pdf';
    final File file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<bool> printCurrentDocument({
    int dpi = 203,
    double widthIn = 3.0,
  }) async {
    _setBusy(true);
    _setError(null);
    try {
      if (_selected == null) {
        if (_paired.isEmpty) await discoverPairedPrinters();
        if (_paired.isNotEmpty) {
          _selected = _paired.firstWhere(
            (PrinterDevice d) =>
                (d.name.toUpperCase().contains('BIXOLON') ||
                d.name.toUpperCase().contains('SPP') ||
                d.name.toUpperCase().contains('SRP')),
            orElse: () => _paired.first,
          );
        }
      }
      final String? addr = _selected?.id;
      if (addr == null || addr.isEmpty) {
        _setError('Seleccione una impresora BIXOLON emparejada');
        return false;
      }

      final Uint8List? bytes = pdfBytes;
      if (bytes == null || bytes.isEmpty) {
        _setError('Documento actual no disponible para imprimir.');
        return false;
      }

      // Delegate the actual print job if custom callback is provided
      if (printerArgs.onPrint != null) {
        final bool success = await printerArgs.onPrint!(
          pdfBytes: bytes,
          macAddress: addr,
          dpi: dpi,
          paperWidthInches: widthIn,
        );
        if (!success) {
          _setError('Error imprimiendo documento');
        }
        return success;
      }

      // Fallback to NativeBixolon in the library if no delegate is injected
      final File file = await _saveToTemp(bytes);
      final Map<String, dynamic>? res = await NativeBixolon.printPdfToBixolonOverBt(
        file.path,
        addr,
        options: <String, dynamic>{
          'dpi': dpi,
          'paperWidthInches': widthIn,
          'printWidth': 576,
          'useBitImage': true,
          'threshold': -1,
          'invert': false,
          'dither': 'none',
          'gamma': 1.30,
          'sharpen': 0.04,
          'rasterMode': 0,
          'chunkSize': 512,
          'interChunkDelayMs': 65,
          'feedLinesAfterPrint': 8,
        },
      );
      final bool ok = (res != null && res['success'] == true);
      if (!ok) {
        _setError(res?['message'] as String? ?? 'Error imprimiendo PDF');
      }
      return ok;
    } catch (e) {
      _setError('Error al imprimir: $e');
      return false;
    } finally {
      _setBusy(false);
    }
  }
}
