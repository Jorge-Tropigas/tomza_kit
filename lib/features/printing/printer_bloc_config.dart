class PrinterBlocConfig {
  static const double paperWidthInches = 3.0;
  static const int optimalDpi = 203;
  static const int maxDotsWidth = 576;
  static const int marginDots = 16;
  static const int printableDotsWidth = maxDotsWidth - (marginDots * 2);

  /// Supported paper widths (inches) selectable from the UI / documents.
  static const List<double> supportedPaperWidthsInches = <double>[2.0, 3.0];

  /// Printable dot width (at [optimalDpi]) for each supported paper size,
  /// matching common 58mm (2") and 80mm (3") thermal printer specs.
  static final Map<double, int> _printableDotsByWidth = <double, int>{
    2.0: 384,
    3.0: printableDotsWidth,
  };

  /// Resolves how many printable dots a [widthInches] paper roll has.
  /// Falls back to a DPI-based estimate for widths outside the known table.
  static int dotsForPaperWidth(double widthInches, {int dpi = optimalDpi}) {
    final int? known = _printableDotsByWidth[widthInches];
    if (known != null) return known;
    return (widthInches * dpi).round();
  }
}
