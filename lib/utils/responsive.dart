import 'package:material_ui/material_ui.dart';

/// Enum para clasificar el tipo de dispositivo según ancho de pantalla.
enum DeviceScreenType {
  smallMobile,
  mediumMobile,
  largeMobile,
  tablet,
  desktop,
}

class AppResponsive {
  static double _w(final BuildContext c) => MediaQuery.of(c).size.width;

  static DeviceScreenType deviceType(final BuildContext c) {
    final double w = _w(c);
    if (w < 360) {
      return DeviceScreenType.smallMobile;
    }
    if (w < 414) {
      return DeviceScreenType.mediumMobile;
    }
    if (w < 600) {
      return DeviceScreenType.largeMobile;
    }
    if (w < 1024) {
      return DeviceScreenType.tablet;
    }
    return DeviceScreenType.desktop;
  }

  static double screenWidth(final BuildContext c) => _w(c);
  static double screenHeight(final BuildContext c) =>
      MediaQuery.of(c).size.height;
}

extension AppResponsiveExtension on BuildContext {
  /// Tipo de dispositivo detectado.
  DeviceScreenType get deviceScreenType => AppResponsive.deviceType(this);

  /// True si es móvil (cualquiera de sus 3 tamaños).
  bool get isMobile =>
      deviceScreenType == DeviceScreenType.smallMobile ||
      deviceScreenType == DeviceScreenType.mediumMobile ||
      deviceScreenType == DeviceScreenType.largeMobile;

  /// Para cuando necesites distinguir cada rango:
  bool get isSmallMobile => deviceScreenType == DeviceScreenType.smallMobile;
  bool get isMediumMobile => deviceScreenType == DeviceScreenType.mediumMobile;
  bool get isLargeMobile => deviceScreenType == DeviceScreenType.largeMobile;

  bool get isTablet => deviceScreenType == DeviceScreenType.tablet;
  bool get isDesktop => deviceScreenType == DeviceScreenType.desktop;

  double get screenWidth => AppResponsive.screenWidth(this);
  double get screenHeight => AppResponsive.screenHeight(this);
}
