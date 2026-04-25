import 'package:tomza_kit/features/printing/print_models.dart';
import 'package:tomza_kit/features/printing/native_bixolon.dart';
import 'dart:developer' as dev;

/// Manager para orquestar la impresión de diferentes tipos de items.
class PrintManager {
  /// Imprime una lista de items (texto, QR, etc.)
  Future<void> printItems(List<PrintItem> items, {String? btAddress}) async {
    for (final item in items) {
      if (item is PrintText) {
        if (btAddress != null) {
          await NativeBixolon.printTextOverBt(btAddress, text: item.text);
        } else {
          dev.log('Printing text: ${item.text}');
        }
      } else if (item is PrintQr) {
        if (btAddress != null) {
          // Implementación de QR sobre BT si NativeBixolon lo soporta
          // Por ahora logueamos
          dev.log('Printing QR over BT: ${item.data}');
        } else {
          dev.log('Printing QR: ${item.data}');
        }
      }
    }
  }
}
