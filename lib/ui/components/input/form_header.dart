import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormHeader extends StatelessWidget {
  const FormHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.center = false,
    this.spacing = 8,
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
    this.fontSizeTitle = 16,
    this.color,
  });

  final String title;
  final String? subtitle;
  final bool center;
  final double spacing;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final double fontSizeTitle;

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
          style: GoogleFonts.gabarito(
            fontWeight: fontWeight,
            fontSize: fontSizeTitle,
            color: color ?? theme.textTheme.bodyMedium?.color,
          ),
        ),
        if (subtitle != null) ...<Widget>[
          SizedBox(height: spacing),
          Text(
            subtitle!,
            textAlign: align,
            style: GoogleFonts.gabarito(
              fontWeight: fontWeight,
              fontSize: fontSizeTitle,
              color: color ?? theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ],
    );
  }
}
