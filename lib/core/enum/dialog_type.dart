import 'package:material_ui/material_ui.dart';

enum DialogType { error, warning, info, success }

extension DialogTypeIconExtension on DialogType {
  IconData get icon {
    switch (this) {
      case DialogType.error:
        return Icons.error_outline;
      case DialogType.warning:
        return Icons.warning_amber_rounded;
      case DialogType.info:
        return Icons.info_outline;
      case DialogType.success:
        return Icons.check_circle_outline;
    }
  }
}

extension DialogTypeColorExtension on DialogType {
  Color get backgroundColor {
    switch (this) {
      case DialogType.error:
        return Colors.red;
      case DialogType.warning:
        return Colors.orange;
      case DialogType.info:
        return Colors.blue;
      case DialogType.success:
        return Colors.green;
    }
  }
}

extension DialogTypeIconColorExtension on DialogType {
  Color get iconColor {
    return Colors.white; // All dialog types use white for the icon color
  }
}
