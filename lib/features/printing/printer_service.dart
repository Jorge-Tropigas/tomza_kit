import 'package:flutter/services.dart';
import 'printer_device.dart';

class PrinterService {
  final MethodChannel _channel;

  PrinterService({String channelName = 'com.tomzagroup.tomza_sv_cobros/bixolon'})
      : _channel = MethodChannel(channelName);

  Future<bool> isBluetoothEnabled() async {
    final res = await _channel.invokeMethod<bool>('isBluetoothEnabled');
    return res ?? false;
  }

  Future<List<PrinterDeviceInfo>> getPairedDevices() async {
    final list = await _channel.invokeMethod<List<dynamic>>('getPairedDevices');
    final maps = (list ?? []).cast<Map<dynamic, dynamic>>();
    return maps
        .map((m) => PrinterDeviceInfo.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<bool> connect(String macAddress) async {
    final ok = await _channel.invokeMethod<bool>('connect', {
      'mac': macAddress,
    });
    return ok ?? false;
  }

  Future<void> disconnect() async {
    await _channel.invokeMethod('disconnect');
  }

  Future<bool> printImage(
    Uint8List imageBytes, {
    int maxWidth = 384,
    int feed = 2,
  }) async {
    final ok = await _channel.invokeMethod<bool>('printImage', {
      'bytes': imageBytes,
      'maxWidth': maxWidth,
      'feed': feed,
    });
    return ok ?? false;
  }

  /// Sends raw PDF bytes to the native side, which renders every page with
  /// Android's PdfRenderer and streams the ESC/POS commands to the printer.
  Future<bool> printPdf(
    Uint8List pdfBytes, {
    int maxWidth = 544,
    int feedLines = 4,
  }) async {
    final ok = await _channel.invokeMethod<bool>('printPdf', {
      'bytes': pdfBytes,
      'maxWidth': maxWidth,
      'feedLines': feedLines,
    });
    return ok ?? false;
  }

  Future<bool> writeRaw(Uint8List data) async {
    final ok = await _channel.invokeMethod<bool>('printRaw', {'bytes': data});
    return ok ?? false;
  }
}
