import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomza_kit/tomza_kit.dart';

void main() {
  test('PrinterArguments and PrinterDevice instantiation', () {
    final dev = PrinterDevice(id: '12:34:56:78', name: 'Bixolon Printer');
    expect(dev.id, '12:34:56:78');
    expect(dev.name, 'Bixolon Printer');

    final doc = PrinterDocument(name: 'Factura', bytes: Uint8List(0));
    final args = PrinterArguments(
      documents: [doc],
      backConfirmationTitle: 'Salir',
    );
    expect(args.documents.first.name, 'Factura');
    expect(args.backConfirmationTitle, 'Salir');
  });
}
