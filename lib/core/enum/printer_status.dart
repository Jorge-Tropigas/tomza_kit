import 'package:material_ui/material_ui.dart';

enum PrinterStatus { idle, connecting, connected, printing, error }

extension PrinterStatusExtension on PrinterStatus {
  String get statusText {
    switch (this) {
      case PrinterStatus.connecting:
        return 'Conectando...';
      case PrinterStatus.connected:
        return 'Conectada';
      case PrinterStatus.printing:
        return 'Imprimiendo...';
      case PrinterStatus.error:
        return 'Error';
      case PrinterStatus.idle:
        return 'Inactiva';
    }
  }
}

extension PrinterStatusExtensionCap on PrinterStatus {
  Color get statusColor {
    switch (this) {
      case PrinterStatus.idle:
        return Colors.grey;
      case PrinterStatus.connecting:
        return Colors.orange;
      case PrinterStatus.connected:
        return Colors.green;
      case PrinterStatus.printing:
        return Colors.blue;
      case PrinterStatus.error:
        return Colors.red;
    }
  }
}
