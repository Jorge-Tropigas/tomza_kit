import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:tomza_kit/ui/themes/colors.dart';

class CustomSvgImage extends StatelessWidget {
  const CustomSvgImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.colorBlendMode = BlendMode.srcIn,
    this.semanticsLabel,
    this.placeholderBuilder,
    this.errorBuilder,
    this.alignment = Alignment.center,
    this.clipBehavior = Clip.hardEdge,
    this.allowDrawingOutsideViewBox = false,
    this.matchTextDirection = false,
  });

  /// Ruta del asset SVG (ej: 'assets/images/logo.svg')
  final String assetPath;

  /// Ancho del widget
  final double? width;

  /// Altura del widget
  final double? height;

  /// Cómo ajustar la imagen dentro del widget
  final BoxFit fit;

  /// Color para aplicar al SVG (opcional)
  final Color? color;

  /// Modo de mezcla de color
  final BlendMode colorBlendMode;

  /// Etiqueta para accesibilidad
  final String? semanticsLabel;

  /// Constructor para widget de placeholder mientras carga
  final WidgetBuilder? placeholderBuilder;

  /// Constructor para widget de error si falla la carga
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  /// Alineación de la imagen
  final Alignment alignment;

  /// Comportamiento de recorte
  final Clip clipBehavior;

  /// Permitir dibujar fuera del ViewBox
  final bool allowDrawingOutsideViewBox;

  /// Coincidir con la dirección del texto
  final bool matchTextDirection;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    double? sanitizeNullable(double? v) {
      if (v == null) {
        return null;
      }
      if (v.isNaN || v.isInfinite) {
        return null;
      }
      return v;
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Valores solicitados por el consumidor (sanitizados)
        final double? requestedW = sanitizeNullable(width);
        final double? requestedH = sanitizeNullable(height);

        // Tomar tamaños del padre si son acotados y válidos
        final double? parentW =
            (constraints.hasBoundedWidth &&
                constraints.maxWidth.isFinite &&
                !constraints.maxWidth.isNaN)
            ? constraints.maxWidth
            : null;
        final double? parentH =
            (constraints.hasBoundedHeight &&
                constraints.maxHeight.isFinite &&
                !constraints.maxHeight.isNaN)
            ? constraints.maxHeight
            : null;

        // Fallbacks seguros (nunca NaN)
        const double fallbackW = 100.0;
        const double fallbackH = 100.0;

        // Elegir tamaños efectivos en orden: solicitado -> padre -> fallback
        double safeW = (requestedW ?? parentW ?? fallbackW).clamp(1.0, 4000.0);
        double safeH = (requestedH ?? parentH ?? fallbackH).clamp(1.0, 4000.0);

        // Normalizar por si acaso (evitar NaN/Infinity)
        if (safeW.isNaN || !safeW.isFinite) {
          safeW = fallbackW;
        }
        if (safeH.isNaN || !safeH.isFinite) {
          safeH = fallbackH;
        }

        // Ajustar tamaños a los constraints del padre
        final Size constrained = constraints.constrain(Size(safeW, safeH));
        safeW = constrained.width;
        safeH = constrained.height;

        // Defensive guards: ensure we never pass NaN or infinite sizes to SvgPicture
        if (safeW.isNaN || !safeW.isFinite) {
          safeW = fallbackW;
        }
        if (safeH.isNaN || !safeH.isFinite) {
          safeH = fallbackH;
        }

        final Widget svg = SvgPicture.asset(
          'assets/$assetPath',
          width: safeW,
          height: safeH,
          fit: fit,
          colorFilter: color != null
              ? ColorFilter.mode(color!, colorBlendMode)
              : null,
          semanticsLabel: semanticsLabel,
          placeholderBuilder: placeholderBuilder ?? _defaultPlaceholderBuilder,
          clipBehavior: clipBehavior,
          allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
          matchTextDirection: matchTextDirection,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
                if (errorBuilder != null) {
                  return errorBuilder!(context, error, stackTrace);
                }
                return _defaultErrorBuilder(context, error, isDark);
              },
        );

        return SizedBox(
          width: safeW,
          height: safeH,
          child: Align(alignment: alignment, child: svg),
        );
      },
    );
  }

  /// Widget de placeholder por defecto mientras carga la imagen
  Widget _defaultPlaceholderBuilder(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Manejar casos de NaN/infinity
    double? sanitize(double? v) {
      if (v == null) {
        return null;
      }
      if (v.isNaN || v.isInfinite) {
        return null;
      }
      return v;
    }

    final double? effectiveWidth = sanitize(width);
    final double? effectiveHeight = sanitize(height);

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: isDark
            ? UnigasColors.textPrimary
            : UnigasColors.dividerSoft.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? UnigasColors.textPrimary : UnigasColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  /// Widget de error por defecto cuando falla la carga
  Widget _defaultErrorBuilder(BuildContext context, Object error, bool isDark) {
    // Manejar casos de NaN/infinity
    double? sanitize(double? v) {
      if (v == null) {
        return null;
      }
      if (v.isNaN || v.isInfinite) {
        return null;
      }
      return v;
    }

    final double? effectiveWidth = sanitize(width);
    final double? effectiveHeight = sanitize(height);

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: isDark
            ? UnigasColors.textPrimary
            : UnigasColors.dividerSoft.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? UnigasColors.textPrimary : UnigasColors.dividerSoft,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.broken_image_outlined,
            color: isDark ? UnigasColors.dividerSoft : UnigasColors.textPrimary,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Error al cargar SVG',
            style: TextStyle(
              color: isDark
                  ? UnigasColors.dividerSoft
                  : UnigasColors.textPrimary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget simplificado para casos comunes de uso de SVG
class SimpleSvgImage extends StatelessWidget {
  const SimpleSvgImage({
    super.key,
    required this.assetPath,
    this.size = 24,
    this.color,
  });

  /// Ruta del asset SVG
  final String assetPath;

  /// Tamaño cuadrado (width y height iguales)
  final double size;

  /// Color para aplicar al SVG
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomSvgImage(
      assetPath: assetPath,
      width: size,
      height: size,
      color: color,
    );
  }
}

/// Widget para logos que se adapta al tema
class LogoSvgImage extends StatelessWidget {
  const LogoSvgImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.adaptToTheme = true,
  });

  /// Ruta del asset SVG del logo
  final String assetPath;

  /// Ancho del logo
  final double? width;

  /// Altura del logo
  final double? height;

  /// Si debe adaptarse al tema (cambiar color según modo claro/oscuro)
  final bool adaptToTheme;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomSvgImage(
      assetPath: assetPath,
      width: width,
      height: height,
      color: adaptToTheme
          ? (isDark ? UnigasColors.primaryDark : UnigasColors.primary)
          : null,
      semanticsLabel: 'Logo de la aplicación',
    );
  }
}

/// Widget para iconos SVG con colores dinámicos
class IconSvgImage extends StatelessWidget {
  const IconSvgImage({
    super.key,
    required this.assetPath,
    this.size = 24,
    this.useThemeColor = true,
    this.customColor,
  });

  /// Ruta del asset SVG del icono
  final String assetPath;

  /// Tamaño del icono
  final double size;

  /// Si debe usar el color del tema
  final bool useThemeColor;

  /// Color personalizado (anula useThemeColor)
  final Color? customColor;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color? iconColor;
    if (customColor != null) {
      iconColor = customColor;
    } else if (useThemeColor) {
      iconColor = isDark ? UnigasColors.primaryDark : UnigasColors.primary;
    }

    return CustomSvgImage(
      assetPath: assetPath,
      width: size,
      height: size,
      color: iconColor,
    );
  }
}
