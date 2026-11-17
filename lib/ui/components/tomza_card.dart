import 'package:material_ui/material_ui.dart';

class TomzaCard extends StatelessWidget {
  const TomzaCard({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.variant = AppCardVariant.filled,
    this.outlinedColor,
    this.background,
    this.borderRadius,
    this.elevation,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final AppCardVariant variant;
  final Color? outlinedColor;
  final Color? background;
  final double? borderRadius;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    final double radius = borderRadius ?? 16;
    final double resolvedElevation = elevation ?? 4;

    // Resolver colores base segun variante
    late Color bg;
    late Color? borderCol;
    switch (variant) {
      case AppCardVariant.filled:
        bg = background ?? cs.surface;
        borderCol = (cs.surfaceContainerHighest).withValues(alpha: 0.15);
        break;
      case AppCardVariant.outlined:
        bg = background ?? cs.surface;
        borderCol = (outlinedColor ?? cs.outlineVariant).withValues(alpha: 0.5);
        break;
      case AppCardVariant.tonal:
        bg = background ?? cs.surfaceTint.withValues(alpha: 0.08);
        borderCol = cs.surfaceTint.withValues(alpha: 0.25);
        break;
    }

    final Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderCol, width: 1.2),
        boxShadow: <BoxShadow>[
          if (resolvedElevation > 0)
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.07 * (resolvedElevation / 4),
              ),
              blurRadius: 6 + resolvedElevation,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}

enum AppCardVariant { filled, outlined, tonal }
