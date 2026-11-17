import 'package:material_ui/material_ui.dart';

import 'package:tomza_kit/tomza_kit.dart';

class RowInfo extends StatelessWidget {
  const RowInfo({
    super.key,
    required this.context,
    required this.icon,
    required this.label,
    required this.value,
  });

  final BuildContext context;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Icono
        Container(
          padding: EdgeInsets.all(isMobile ? 6 : 8),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
          ),
          child: Icon(
            icon,
            size: isMobile ? 16 : 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(width: isMobile ? 12 : 16),

        // Contenido
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: isMobile ? 12 : 13,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isMobile ? 2 : 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: isMobile ? 14 : 15,
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
