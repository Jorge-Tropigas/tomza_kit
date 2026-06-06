import 'package:flutter/material.dart';

class FormHeader extends StatelessWidget {
  const FormHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.center = false,
    this.spacing = 8,
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
  });

  final String title;
  final String? subtitle;
  final bool center;
  final double spacing;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextAlign align = center ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          title,
          textAlign: align,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        if (subtitle != null) ...<Widget>[
          SizedBox(height: spacing),
          Text(
            subtitle!,
            textAlign: align,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ],
    );
  }
}
