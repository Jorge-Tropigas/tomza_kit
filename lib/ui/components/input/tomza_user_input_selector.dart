import 'package:flutter/material.dart';

typedef Validator<T> = String? Function(T? value);

class UserInputSelector<T> extends StatelessWidget {
  const UserInputSelector({
    super.key,
    this.value,
    required this.options,
    required this.label,
    this.title,
    this.hint,
    this.onChanged,
    this.validator,
    this.borderRadius = 10.0,
    this.style,
    this.dropdownColor,
    this.dropdownMaxHeight = 250,
    this.itemToString,
    this.padding = const EdgeInsets.all(16),
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.always,
    this.fontSize = 14,
    this.fontSizeTitle = 16,
    this.fontWeight = FontWeight.bold,
    this.color,
    this.maxLines = 1,
  });

  final T? value;
  final List<T> options;
  final String label;
  final String? title;
  final String? hint;
  final ValueChanged<T?>? onChanged;
  final Validator<T>? validator;
  final double borderRadius;
  final TextStyle? style;
  final Color? dropdownColor;
  final double dropdownMaxHeight;
  final String Function(T)? itemToString;
  final EdgeInsetsGeometry? padding;
  final bool enabled;
  final AutovalidateMode? autovalidateMode;
  final double fontSize;
  final double fontSizeTitle;
  final FontWeight fontWeight;
  final Color? color;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextStyle = style ??
        theme.textTheme.bodyMedium?.copyWith(
          fontSize: fontSize,
          fontWeight: fontWeight,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: fontWeight,
              fontSize: fontSizeTitle,
              color: color ?? theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          enableFeedback: enabled,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: theme.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            filled: true,
            fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
          style: effectiveTextStyle,
          dropdownColor: dropdownColor ?? theme.canvasColor,
          menuMaxHeight: dropdownMaxHeight,
          icon: const SizedBox.shrink(),
          items: options.map((opt) {
            return DropdownMenuItem<T>(
              value: opt,
              child: Text(
                itemToString?.call(opt) ?? opt.toString(),
                overflow: TextOverflow.ellipsis,
                maxLines: maxLines,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          autovalidateMode: autovalidateMode,
        ),
      ],
    );
  }
}
