import 'package:material_ui/material_ui.dart';

/// ThemeExtension to centralize semantic status colors (success, warning, info, danger)
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.danger,
    required this.successBg,
    required this.warningBg,
    required this.infoBg,
    required this.dangerBg,
  });

  final Color success;
  final Color warning;
  final Color info;
  final Color danger;
  final Color successBg;
  final Color warningBg;
  final Color infoBg;
  final Color dangerBg;

  @override
  AppStatusColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? danger,
    Color? successBg,
    Color? warningBg,
    Color? infoBg,
    Color? dangerBg,
  }) => AppStatusColors(
    success: success ?? this.success,
    warning: warning ?? this.warning,
    info: info ?? this.info,
    danger: danger ?? this.danger,
    successBg: successBg ?? this.successBg,
    warningBg: warningBg ?? this.warningBg,
    infoBg: infoBg ?? this.infoBg,
    dangerBg: dangerBg ?? this.dangerBg,
  );

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) {
    if (other is! AppStatusColors) {
      return this;
    }
    return AppStatusColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      dangerBg: Color.lerp(dangerBg, other.dangerBg, t)!,
    );
  }

  static AppStatusColors light() => const AppStatusColors(
    success: Color(0xFF2E7D32),
    warning: Color(0xFFED6C02),
    info: Color(0xFF0277BD),
    danger: Color(0xFFC62828),
    successBg: Color(0xFFE8F5E9),
    warningBg: Color(0xFFFFF3E0),
    infoBg: Color(0xFFE1F5FE),
    dangerBg: Color(0xFFFFEBEE),
  );

  static AppStatusColors dark() => const AppStatusColors(
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFB74D),
    info: Color(0xFF4FC3F7),
    danger: Color(0xFFEF5350),
    successBg: Color(0xFF1B3C1D),
    warningBg: Color(0xFF412F14),
    infoBg: Color(0xFF0D3442),
    dangerBg: Color(0xFF43181B),
  );
}
