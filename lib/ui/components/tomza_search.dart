import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/responsive.dart';

class TomzaSearchField<T> extends StatefulWidget {
  const TomzaSearchField({
    required this.items,
    required this.itemToString,
    required this.onItemSelected,
    required this.controller,
    super.key,
    this.hintText = 'Buscar...',
    this.label,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.enabled = true,
    this.readOnly = false,
    this.onClear,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.focusNode,
    this.color,
    this.fillColor,
    this.borderColor,
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
    this.borderRadius = 12.0,
    this.maxSuggestions = 5,
    this.suggestionBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
    this.caseSensitive = false,
    this.filterFn,
    this.localFilter = true,
  });

  final List<T> items;
  final String Function(T) itemToString;
  final void Function(T) onItemSelected;
  final TextEditingController controller;
  final String hintText;
  final String? label;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isLoading;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onClear;
  final void Function(String)? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final Color? color;
  final Color? fillColor;
  final Color? borderColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderRadius;
  final int maxSuggestions;
  final Widget Function(BuildContext, T)? suggestionBuilder;
  final Widget Function(BuildContext)? emptyBuilder;
  final Widget Function(BuildContext)? loadingBuilder;
  final bool caseSensitive;
  final bool Function(T, String)? filterFn;
  final bool localFilter;

  @override
  State<TomzaSearchField<T>> createState() => _TomzaSearchFieldState<T>();
}

class _TomzaSearchFieldState<T> extends State<TomzaSearchField<T>> {
  final LayerLink _layerLink = LayerLink();
  late FocusNode _focusNode;
  OverlayEntry? _overlayEntry;
  List<T> _filteredSuggestions = <T>[];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(TomzaSearchField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.removeListener(_onFocusChanged);
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChanged);
    }

    if (widget.isLoading != oldWidget.isLoading ||
        widget.items != oldWidget.items) {
      if (widget.controller.text.isNotEmpty) {
        _applyFiltering(widget.controller.text);
      } else {
        _removeOverlay();
      }
    }
  }

  @override
  void dispose() {
    _removeOverlay(skipSetState: true);
    if (widget.focusNode == null) {
      _focusNode.removeListener(_onFocusChanged);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      Future<void>.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _removeOverlay();
      });
    }
  }

  void _applyFiltering(String value) {
    if (value.isEmpty) {
      if (mounted) {
        setState(() => _filteredSuggestions = <T>[]);
      }
      _removeOverlay();
      return;
    }

    List<T> filtered;

    if (!widget.localFilter) {
      filtered = widget.items;
    } else if (widget.filterFn != null) {
      filtered = widget.items
          .where((T item) => widget.filterFn!(item, value))
          .toList();
    } else {
      final String searchValue =
          widget.caseSensitive ? value : value.toLowerCase();
      filtered = widget.items.where((T item) {
        final String text = widget.caseSensitive
            ? widget.itemToString(item)
            : widget.itemToString(item).toLowerCase();
        return text.contains(searchValue);
      }).toList();
    }

    if (mounted) {
      setState(() {
        _filteredSuggestions = filtered.take(widget.maxSuggestions).toList();
      });

      if (_focusNode.hasFocus &&
          (_filteredSuggestions.isNotEmpty || widget.isLoading)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _updateOverlay();
        });
      } else if (_filteredSuggestions.isEmpty && !widget.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _updateOverlay();
        });
      }
    }
  }

  void _updateOverlay() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
      return;
    }

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final Size? size = renderBox?.size;
    if (size == null) return;

    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (BuildContext ctx) => _buildSuggestionsOverlay(size),
      );
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }

    if (!_showSuggestions && mounted) {
      setState(() => _showSuggestions = true);
    }
  }

  void _removeOverlay({bool skipSetState = false}) {
    if (_overlayEntry != null) {
      try {
        _overlayEntry!.remove();
      } catch (_) {}
      _overlayEntry = null;
    }
    if (!skipSetState && mounted && _showSuggestions) {
      setState(() => _showSuggestions = false);
    }
  }

  Widget _buildSuggestionsOverlay(Size inputSize) {
    final bool isMobile = context.isMobile;
    final ThemeData theme = Theme.of(context);
    final Color fill = widget.fillColor ?? theme.cardColor;
    final Color outline =
        widget.borderColor ?? theme.colorScheme.outline;

    return Positioned(
      width: inputSize.width,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        followerAnchor: Alignment.topLeft,
        targetAnchor: Alignment.bottomLeft,
        offset: const Offset(0, 5),
        child: Material(
          elevation: 8.0,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: Colors.transparent,
          child: Container(
            constraints:
                BoxConstraints(maxHeight: isMobile ? 200 : 300),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(color: outline),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: widget.isLoading
                ? _buildLoadingWidget()
                : _filteredSuggestions.isEmpty
                    ? _buildEmptyWidget()
                    : _buildSuggestionsList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    if (widget.loadingBuilder != null) return widget.loadingBuilder!(context);
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
    );
  }

  Widget _buildEmptyWidget() {
    if (widget.emptyBuilder != null) return widget.emptyBuilder!(context);
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'No se encontraron resultados',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: _filteredSuggestions.length,
      itemBuilder: (BuildContext ctx, int index) {
        final T suggestion = _filteredSuggestions[index];
        if (widget.suggestionBuilder != null) {
          return InkWell(
            onTap: () => _selectSuggestion(suggestion),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: widget.suggestionBuilder!(ctx, suggestion),
          );
        }
        return _buildDefaultSuggestionItem(suggestion, index);
      },
    );
  }

  Widget _buildDefaultSuggestionItem(T suggestion, int index) {
    final ThemeData theme = Theme.of(context);
    final bool isMobile = context.isMobile;
    final bool isLast = index == _filteredSuggestions.length - 1;

    return InkWell(
      onTap: () => _selectSuggestion(suggestion),
      borderRadius: BorderRadius.vertical(
        top: index == 0
            ? Radius.circular(widget.borderRadius)
            : Radius.zero,
        bottom: isLast
            ? Radius.circular(widget.borderRadius)
            : Radius.zero,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: isMobile ? 12.0 : 16.0,
        ),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.search,
              size: isMobile ? 18 : 20,
              color: theme.hintColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.itemToString(suggestion),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectSuggestion(T suggestion) {
    final String text = widget.itemToString(suggestion);
    widget.controller.text = text;
    widget.controller.selection = TextSelection.collapsed(offset: text.length);
    widget.onItemSelected(suggestion);
    _removeOverlay();
    _focusNode.unfocus();
  }

  void _onTextChanged(String value) {
    widget.onChanged?.call(value);

    if (value.isEmpty) {
      setState(() => _filteredSuggestions = <T>[]);
      _removeOverlay();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateOverlay();
    });

    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      _applyFiltering(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isMobile = context.isMobile;
    final Color fill = widget.fillColor ?? theme.cardColor;
    final Color outline =
        widget.borderColor ?? theme.colorScheme.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label!,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ),
        CompositedTransformTarget(
          link: _layerLink,
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            validator: widget.validator,
            onChanged: _onTextChanged,
            onFieldSubmitted: widget.onSubmitted,
            style: GoogleFonts.zenAntiqueSoft(
              color: widget.enabled
                  ? (widget.color ?? theme.colorScheme.onSurface)
                  : theme.disabledColor,
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
              helperText: widget.helperText,
              errorText: widget.errorText,
              prefixIcon: widget.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : (widget.prefixIcon ??
                      Icon(Icons.search, color: theme.hintColor)),
              suffixIcon: _showSuggestions || widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close, color: theme.hintColor),
                      onPressed: () {
                        widget.controller.clear();
                        _onTextChanged('');
                        widget.onClear?.call();
                      },
                    )
                  : widget.suffixIcon,
              filled: true,
              fillColor: fill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: widget.borderColor ?? theme.colorScheme.primary,
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: theme.colorScheme.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 2.0,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: outline.withValues(alpha: 0.3),
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isMobile ? 12 : 16,
              ),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }
}
