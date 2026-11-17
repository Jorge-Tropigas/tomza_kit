import 'package:material_ui/material_ui.dart';

import 'package:tomza_kit/tomza_kit.dart';

class AppSizes {
  AppSizes._();

  // Espaciado base
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;

  // Radios de borde
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;

  // Elevaciones
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;

  /// Obtiene el espaciado responsivo
  static double getSpacing(
    BuildContext context,
    double mobileSize,
    double desktopSize,
  ) {
    return context.isMobile ? mobileSize : desktopSize;
  }

  /// Obtiene el radio responsivo
  static double getRadius(
    BuildContext context, [
    double? customMobile,
    double? customDesktop,
  ]) {
    return context.isMobile
        ? (customMobile ?? radiusS)
        : (customDesktop ?? radiusM);
  }

  /// Obtiene el tamaño de fuente responsivo
  static double getFontSize(
    BuildContext context,
    double mobileSize,
    double desktopSize,
  ) {
    return context.isMobile ? mobileSize : desktopSize;
  }

  /// Obtiene el tamaño de icono responsivo
  static double getIconSize(
    BuildContext context, [
    double? customMobile,
    double? customDesktop,
  ]) {
    return context.isMobile ? (customMobile ?? 20.0) : (customDesktop ?? 24.0);
  }

  /// Obtiene el padding responsivo
  static EdgeInsets getPadding(
    BuildContext context, {
    double? mobile,
    double? desktop,
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    if (all != null) {
      return EdgeInsets.all(context.isMobile ? all * 0.8 : all);
    }

    if (horizontal != null || vertical != null) {
      return EdgeInsets.symmetric(
        horizontal: context.isMobile
            ? (horizontal ?? 0) * 0.8
            : (horizontal ?? 0),
        vertical: context.isMobile ? (vertical ?? 0) * 0.8 : (vertical ?? 0),
      );
    }

    final double mobileValue = mobile ?? spacingM;
    final double desktopValue = desktop ?? spacingL;

    return EdgeInsets.all(context.isMobile ? mobileValue : desktopValue);
  }

  /// Obtiene el margen responsivo
  static EdgeInsets getMargin(
    BuildContext context, {
    double? mobile,
    double? desktop,
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    return getPadding(
      context,
      mobile: mobile,
      desktop: desktop,
      horizontal: horizontal,
      vertical: vertical,
      all: all,
    );
  }
}

// Tamaños específicos para componentes
class AppBarSizes {
  static double getHeight(BuildContext context) =>
      context.isMobile ? kToolbarHeight : 64.0;

  static double getTitleFontSize(BuildContext context) =>
      context.isMobile ? 18.0 : 22.0;
}

class CardSizes {
  static double getElevation(BuildContext context) =>
      context.isMobile ? AppSizes.elevationS : AppSizes.elevationM;

  static BorderRadius getBorderRadius(BuildContext context) =>
      BorderRadius.circular(AppSizes.getRadius(context));
}

class ButtonSizes {
  static EdgeInsets getPadding(BuildContext context) => EdgeInsets.symmetric(
    horizontal: context.isMobile ? 16.0 : 24.0,
    vertical: context.isMobile ? 12.0 : 16.0,
  );

  static double getFontSize(BuildContext context) =>
      context.isMobile ? 14.0 : 16.0;
}

class DialogSizes {
  static EdgeInsets getPadding(BuildContext context) =>
      EdgeInsets.all(context.isMobile ? 20.0 : 24.0);

  static BorderRadius getBorderRadius(BuildContext context) =>
      BorderRadius.circular(context.isMobile ? 12.0 : 16.0);
}

class InputSizes {
  static EdgeInsets getContentPadding(BuildContext context) =>
      EdgeInsets.symmetric(
        horizontal: context.isMobile ? 12.0 : 16.0,
        vertical: context.isMobile ? 12.0 : 16.0,
      );
}
