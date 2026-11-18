import 'package:material_ui/material_ui.dart';

class SearchInput<T> extends StatelessWidget {
  const SearchInput({
    super.key,
    required this.items,
    required this.itemToString,
    required this.onItemSelected,
    required this.controller,
    this.hintText = 'Buscar...',
    this.prefixIcon,
    this.isLoading = false,
    this.enabled = true,
    this.onClear,
    this.validator,
    this.onChanged,
  });

  final List<T> items;
  final String Function(T) itemToString;
  final void Function(T) onItemSelected;
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final bool isLoading;
  final bool enabled;
  final VoidCallback? onClear;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.cardColor;
    const double radius = 14;
    const double fontSize = 14;
    const double hintFontSize = 13;
    const double iconSize = 20;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        validator: validator,
        onChanged: onChanged,
        style: const TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: hintFontSize),
          prefixIcon: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : (prefixIcon ?? const Icon(Icons.search, size: iconSize)),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: iconSize),
                  onPressed: enabled
                      ? () {
                          controller.clear();
                          if (onClear != null) onClear!();
                        }
                      : null,
                )
              : null,
          filled: true,
          fillColor: bg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.4),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
