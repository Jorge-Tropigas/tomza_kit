import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'printer_device.dart';
import 'printer_service.dart';

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
  final PrinterArguments printerArgs;
  final PrinterService _svc;

  PrinterBloc({
    required this.printerArgs,
    PrinterService? printerService,
  }) : _svc = printerService ?? PrinterService() {
    if (printerArgs.documents.isNotEmpty) {
      _selectedDocument = printerArgs.documents.first;
    }
    _init();
  }

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
      final List<PrinterDeviceInfo> bonded = await _svc.getPairedDevices();
      final List<PrinterDevice> list = bonded
          .map(
            (PrinterDeviceInfo d) =>
                PrinterDevice(id: d.address, name: d.name),
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

      final bool enabled = await _svc.isBluetoothEnabled();
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

    final theme = Theme.of(context);

    final PrinterDevice? chosen = await showDialog<PrinterDevice?>(
      context: context,
      builder: (BuildContext ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.bluetooth_searching_rounded, color: Colors.white, size: 32),
                      const SizedBox(height: 12),
                      Text(
                        'SELECCIONAR IMPRESORA',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.gabarito(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Device List
                Flexible(
                  child: _paired.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.print_disabled_rounded, size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'No se encontraron dispositivos emparejados',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.gabarito(color: Colors.grey, fontSize: 14),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () async {
                                  await openBluetooth();
                                  await discoverPairedPrinters();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.secondary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text('BUSCAR DE NUEVO', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: _paired.length,
                          separatorBuilder: (_, __) => const Divider(indent: 20, endIndent: 20, height: 1),
                          itemBuilder: (BuildContext c, int i) {
                            final PrinterDevice d = _paired[i];
                            final bool isBixolon = d.name.toUpperCase().contains('BIXOLON') || 
                                                 d.name.toUpperCase().contains('SPP');
                            
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isBixolon 
                                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                      : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isBixolon ? Icons.print_rounded : Icons.bluetooth_rounded,
                                  color: isBixolon ? theme.colorScheme.primary : Colors.grey,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                d.name,
                                style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              subtitle: Text(
                                d.id,
                                style: GoogleFonts.gabarito(color: Colors.grey.shade600, fontSize: 12),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                              onTap: () => Navigator.pop(ctx, d),
                            );
                          },
                        ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'CERRAR',
                      style: GoogleFonts.gabarito(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (chosen != null) setSelected(chosen);
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

      // Fallback to default PrinterService method channel sequence
      final bool connected = await _svc.connect(addr);
      if (!connected) {
        _setError('Error al conectar con ${_selected!.name}');
        return false;
      }

      final bool ok = await _svc.printPdf(bytes);
      await _svc.disconnect();
      if (!ok) {
        _setError('Error al imprimir con ${_selected!.name}');
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

