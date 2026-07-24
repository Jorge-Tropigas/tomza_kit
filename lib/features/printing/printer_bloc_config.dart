class PrinterBlocConfig {
  static const double paperWidthInches = 3.0;
  static const int optimalDpi = 203;

  static const int maxDotsWidth = 576;
  static const int marginDots = 16;
  static const int printableDotsWidth = maxDotsWidth - (marginDots * 2);

  static const int maxDotsWidth2Inch = 384;
  static const int marginDots2Inch = 8;
  static const int printableDotsWidth2Inch =
      maxDotsWidth2Inch - (marginDots2Inch * 2);

  static const List<double> supportedPaperWidthsInches = <double>[2.0, 3.0];

  static final Map<double, int> _printableDotsByWidth = <double, int>{
    2.0: printableDotsWidth2Inch,
    3.0: printableDotsWidth,
  };

  static int dotsForPaperWidth(double widthInches, {int dpi = optimalDpi}) {
    final int? known = _printableDotsByWidth[widthInches];
    if (known != null) return known;
    return (widthInches * dpi).round();
  }

  static double scaleFactorForWidth(
    double targetWidthInches, {
    double baseWidthInches = 3.0,
  }) {
    if (targetWidthInches >= baseWidthInches) return 1.0;

    final int baseDots = dotsForPaperWidth(baseWidthInches);
    final int targetDots = dotsForPaperWidth(targetWidthInches);

    return targetDots / baseDots;
  }

  /// Bluetooth name substrings (uppercased) of printer models known to take
  /// 2" (58mm) paper rather than the 3" default. Extend as new narrow-format
  /// models are supported.
  static const List<String> narrowPaperModelHints = <String>['R200'];

  /// Best-effort paper width guess from a paired device's Bluetooth name,
  /// e.g. a Bixolon SPP-R200III reports itself as a 2" printer. Returns null
  /// when the model isn't recognized, so callers can fall back to
  /// [paperWidthInches].
  static double? detectPaperWidthInchesFromName(String name) {
    final String upper = name.toUpperCase();
    for (final String hint in narrowPaperModelHints) {
      if (upper.contains(hint)) return 2.0;
    }
    return null;
  }
}
