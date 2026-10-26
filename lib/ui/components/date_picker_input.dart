import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tomza_kit/utils/responsive.dart';

/// Widget personalizado para selección de fechas que se muestra como un input
class DatePickerInput extends StatefulWidget {
  const DatePickerInput({
    super.key,
    this.label,
    this.hintText = 'Seleccionar fecha',
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateChanged,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.dateFormat = 'dd/MM/yyyy',
    this.errorText,
    this.helperText,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.textColor,
    this.labelColor,
    this.iconColor,
    this.borderRadius,
    this.contentPadding,
  });

  final String? label;
  final String hintText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateChanged;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(DateTime?)? validator;
  final String dateFormat;
  final String? errorText;
  final String? helperText;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? textColor;
  final Color? labelColor;
  final Color? iconColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<DatePickerInput> createState() => _DatePickerInputState();
}

class _DatePickerInputState extends State<DatePickerInput> {
  DateTime? _selectedDate;
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _errorText = widget.errorText;
  }

  @override
  void didUpdateWidget(DatePickerInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      setState(() {
        _selectedDate = widget.initialDate;
      });
    }
    if (widget.errorText != oldWidget.errorText) {
      setState(() {
        _errorText = widget.errorText;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: widget.labelColor ?? colors.onSurface,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
        ],
        _buildInputField(context, isMobile, theme, colors),
        if (widget.helperText != null || _errorText != null) ...<Widget>[
          SizedBox(height: isMobile ? 4 : 6),
          Text(
            _errorText ?? widget.helperText!,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: _errorText != null
                  ? colors.error
                  : colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputField(
    BuildContext context,
    bool isMobile,
    ThemeData theme,
    ColorScheme colors,
  ) {
    final BorderRadius effectiveRadius =
        widget.borderRadius ?? BorderRadius.circular(12.0);
    final Color iconBase = widget.iconColor ?? colors.onSurface;

    return GestureDetector(
      onTap: widget.enabled ? _showDatePicker : null,
      child: Container(
        decoration: BoxDecoration(
          color:
              widget.backgroundColor ??
              colors.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: effectiveRadius,
          border: Border.all(
            color: _getBorderColor(colors),
            width: _focusNode.hasFocus ? 2 : 1,
          ),
        ),
        child: Padding(
          padding:
              widget.contentPadding ??
              EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isMobile ? 12 : 16,
              ),
          child: Row(
            children: <Widget>[
              if (widget.prefixIcon != null) ...<Widget>[
                IconTheme(
                  data: IconThemeData(
                    color: iconBase,
                    size: isMobile ? 20 : 24,
                  ),
                  child: widget.prefixIcon!,
                ),
                SizedBox(width: isMobile ? 8 : 12),
              ],
              Expanded(
                child: Text(
                  _getDisplayText(),
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: _getTextColor(colors),
                    fontWeight: _selectedDate != null
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ),
              IconTheme(
                data: IconThemeData(color: iconBase, size: isMobile ? 20 : 24),
                child:
                    widget.suffixIcon ??
                    Icon(
                      Icons.calendar_today,
                      color: widget.enabled
                          ? (widget.iconColor ?? colors.primary)
                          : theme.disabledColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDisplayText() {
    if (_selectedDate == null) return widget.hintText;
    return DateFormat(widget.dateFormat, 'es_ES').format(_selectedDate!);
  }

  Color _getTextColor(ColorScheme colors) {
    if (!widget.enabled) return colors.onSurface.withValues(alpha: 0.38);
    if (_selectedDate == null) return colors.onSurface.withValues(alpha: 0.6);
    return widget.textColor ?? colors.onSurface;
  }

  Color _getBorderColor(ColorScheme colors) {
    if (_errorText != null) return colors.error;
    if (_focusNode.hasFocus) return widget.focusedBorderColor ?? colors.primary;
    return widget.borderColor ?? colors.outline;
  }

  Future<void> _showDatePicker() async {
    _focusNode.requestFocus();

    final DateTime now = DateTime.now();
    final DateTime firstDate = widget.firstDate ?? DateTime(now.year - 100);
    final DateTime lastDate = widget.lastDate ?? DateTime(now.year + 100);
    final DateTime initialDate =
        _selectedDate ??
        (now.isBefore(firstDate)
            ? firstDate
            : now.isAfter(lastDate)
            ? lastDate
            : now);

    try {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        locale: const Locale('es', 'ES'),
      );

      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
          _errorText = null;
        });

        if (widget.validator != null) {
          final String? validationError = widget.validator!(_selectedDate);
          if (validationError != null) {
            setState(() {
              _errorText = validationError;
            });
          }
        }

        widget.onDateChanged?.call(pickedDate);
      }
    } finally {
      _focusNode.unfocus();
    }
  }

  bool validate() {
    if (widget.validator != null) {
      final String? error = widget.validator!(_selectedDate);
      setState(() {
        _errorText = error;
      });
      return error == null;
    }
    return true;
  }

  void clear() {
    setState(() {
      _selectedDate = null;
      _errorText = null;
    });
  }

  void setDate(DateTime? date) {
    setState(() {
      _selectedDate = date;
      _errorText = null;
    });
  }

  DateTime? get selectedDate => _selectedDate;
}
