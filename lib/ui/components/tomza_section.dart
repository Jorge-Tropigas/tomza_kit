import 'package:flutter/material.dart';

class TomzaSection extends StatelessWidget {
  const TomzaSection({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.padding,
    this.iconColor,
    this.spacing = 8,
    this.dense = false,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final Color? iconColor;
  final double spacing;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? style = theme.textTheme.titleMedium?.copyWith(
      fontSize: dense ? 14 : 16,
      fontWeight: FontWeight.w600,
    );
    return Padding(
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: dense ? 12 : 16,
            vertical: dense ? 8 : 12,
          ),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: dense ? 18 : 22,
            color: iconColor ?? theme.colorScheme.primary,
          ),
          SizedBox(width: spacing),
          Expanded(child: Text(title, style: style)),
          ?trailing,
        ],
      ),
    );
  }
}
