import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';

class UserInput extends StatefulWidget {
  const UserInput({
    super.key,
    required this.title,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.enabled,
    this.prefixIcon,
    this.suffixIcon,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 10.0,
    this.autovalidateMode = AutovalidateMode.always,
    this.fontSize = 16,
    this.fontSizeTitle = 18,
    this.fontWeight = FontWeight.bold,
    this.color,
  });

  final String title;
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? maxLength;
  final bool? enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final AutovalidateMode? autovalidateMode;
  final double fontSize;
  final double fontSizeTitle;
  final FontWeight fontWeight;
  final Color? color;

  @override
  State<UserInput> createState() => _UserInputState();
}

class _UserInputState extends State<UserInput> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isPasswordField = widget.obscureText;
    final theme = Theme.of(context);

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title.isNotEmpty) ...[
            Text(
              widget.title,
              style: GoogleFonts.gabarito(
                fontWeight: FontWeight.bold,
                fontSize: widget.fontSizeTitle,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
          ],
          TextFormField(
            controller: widget.controller,
            validator: widget.validator,
            autovalidateMode: widget.autovalidateMode,
            obscureText: _obscure,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            enabled: widget.enabled,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              labelStyle: GoogleFonts.gabarito(
                color: theme.hintColor,
              ),
              hintStyle: GoogleFonts.gabarito(
                color: theme.hintColor,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon: widget.prefixIcon,
              suffixIcon: isPasswordField
                  ? IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                    )
                  : widget.suffixIcon,
              filled: true,
              fillColor:
                  theme.inputDecorationTheme.fillColor ?? Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: theme.primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: theme.colorScheme.error),
              ),
            ),
            style: GoogleFonts.gabarito(
              color: widget.color ?? theme.textTheme.bodyMedium?.color,
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}
