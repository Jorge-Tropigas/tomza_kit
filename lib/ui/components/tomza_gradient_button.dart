import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TomzaGradientButton extends StatefulWidget {
  const TomzaGradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 52,
    this.borderRadius = 16,
    this.isLoading = false,
    this.gradient,
    this.color,
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final Gradient? gradient;
  final Color? color;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  State<TomzaGradientButton> createState() => _TomzaGradientButtonState();
}

class _TomzaGradientButtonState extends State<TomzaGradientButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (widget.onPressed == null) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = widget.color ?? (widget.gradient is LinearGradient 
        ? (widget.gradient as LinearGradient).colors.first 
        : theme.primaryColor);

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: widget.height,
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: effectiveColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: widget.isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : DefaultTextStyle(
                    key: const ValueKey('text'),
                    style: GoogleFonts.gabarito(
                      color: widget.color,
                      fontSize: widget.fontSize,
                      fontWeight: widget.fontWeight,
                    ),
                    child: widget.child,
                  ),
          ),
        ),
      ),
    );
  }
}
