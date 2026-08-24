import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tomza_kit/ui/themes/colors.dart';
import 'package:tomza_kit/ui/themes/status_color.dart';

enum ThemeType { blue, orange, dark }

class ThemeProvider extends ChangeNotifier {
  ThemeType _currentThemeType = ThemeType.blue;

  ThemeType get currentThemeType => _currentThemeType;

  void toggleTheme() {
    if (_currentThemeType == ThemeType.blue) {
      _currentThemeType = ThemeType.orange;
    } else if (_currentThemeType == ThemeType.orange) {
      _currentThemeType = ThemeType.dark;
    } else {
      _currentThemeType = ThemeType.blue;
    }
    notifyListeners();
  }

  bool get isDarkMode => _currentThemeType == ThemeType.dark;

  ThemeData get currentTheme {
    switch (_currentThemeType) {
      case ThemeType.blue:
        return lightTheme;
      case ThemeType.orange:
        return orangeTheme;
      case ThemeType.dark:
        return darkTheme;
    }
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: <ThemeExtension<dynamic>>[AppStatusColors.light()],

      // Esquema de colores
      colorScheme: ColorScheme.fromSeed(
        seedColor: UnigasColors.primary,
        primary: UnigasColors.primary,
        onPrimary: Colors.white,
        secondary: UnigasColors.accent,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: UnigasColors.textPrimary,
        // background: surfaceGrey, // deprecated
        // onBackground: darkGrey, // deprecated
        error: UnigasColors.secondary,
        onError: Colors.white,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: Colors.white,
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: UnigasColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.alexandria(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
      ),

      // Card Theme: white background with elevation, shape, margin for contrast
      cardTheme: CardThemeData(
        elevation: 4,
        color: Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ListTile Theme: white tiles with primary color icons, shape and padding
      listTileTheme: ListTileThemeData(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selectedColor: UnigasColors.primary,
        iconColor: UnigasColors.primary,
        textColor: UnigasColors.textPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),

      // ElevatedButton Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: UnigasColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.alexandria(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: UnigasColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // InputDecoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: UnigasColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: UnigasColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: UnigasColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: UnigasColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: UnigasColors.secondary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: GoogleFonts.alexandria(
          fontSize: 16,
          color: UnigasColors.textSecondary,
        ),
        hintStyle: GoogleFonts.alexandria(
          fontSize: 16,
          color: UnigasColors.textSecondary,
        ),
      ),

      // Text Theme
      textTheme: GoogleFonts.alexandriaTextTheme().copyWith(
        displayLarge: GoogleFonts.alexandria(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: UnigasColors.textPrimary,
        ),
        displayMedium: GoogleFonts.alexandria(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: UnigasColors.textPrimary,
        ),
        displaySmall: GoogleFonts.alexandria(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: UnigasColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.alexandria(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: UnigasColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.alexandria(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: UnigasColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.alexandria(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: UnigasColors.textPrimary,
        ),
        titleLarge: GoogleFonts.alexandria(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: UnigasColors.textPrimary,
        ),
        titleMedium: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: UnigasColors.textPrimary,
        ),
        titleSmall: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: UnigasColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: UnigasColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: UnigasColors.textPrimary,
        ),
        bodySmall: GoogleFonts.alexandria(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: UnigasColors.textSecondary,
        ),
        labelLarge: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: UnigasColors.textSecondary,
        ),
        labelMedium: GoogleFonts.alexandria(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: UnigasColors.textSecondary,
        ),
        labelSmall: GoogleFonts.alexandria(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: UnigasColors.textSecondary,
        ),
      ),

      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),

      // Divider Theme: stronger contrast
      dividerTheme: DividerThemeData(
        color: UnigasColors.textSecondary.withValues(alpha: 0.5),
        thickness: 1,
        space: 0.5,
      ),
      // DataTable Theme: improved table styling
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(UnigasColors.primaryDark),
        headingTextStyle: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: UnigasColors.secondaryDark,
        ),
        dataRowColor: WidgetStateProperty.all(Colors.white),
        dataTextStyle: GoogleFonts.alexandria(
          fontSize: 14,
          color: UnigasColors.secondaryDark,
        ),
        dividerThickness: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: UnigasColors.secondaryDark,
        selectedColor: UnigasColors.accent,
        disabledColor: UnigasColors.textSecondary.withValues(alpha: 0.3),
        labelStyle: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(
          color: UnigasColors.textSecondary.withValues(alpha: 0.3),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ThemeData get orangeTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: <ThemeExtension<dynamic>>[AppStatusColors.light()],

      // Esquema de colores
      colorScheme: ColorScheme.fromSeed(
        seedColor: GranelGTColors.primary,
        primary: GranelGTColors.primary,
        onPrimary: Colors.white,
        secondary: GranelGTColors.secondary,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: GranelGTColors.textPrimary,
        error: GranelGTColors.primaryDark,
        onError: Colors.white,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: Colors.white,
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: GranelGTColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.alexandria(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
      ),

      // Card Theme: white background with elevation, shape, margin for contrast
      cardTheme: CardThemeData(
        elevation: 4,
        color: Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ListTile Theme: white tiles with primary color icons, shape and padding
      listTileTheme: ListTileThemeData(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selectedColor: GranelGTColors.primary,
        iconColor: GranelGTColors.primary,
        textColor: GranelGTColors.textPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),

      // ElevatedButton Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GranelGTColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.alexandria(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: GranelGTColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // InputDecoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GranelGTColors.dividerSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: GranelGTColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: GranelGTColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: GranelGTColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: GranelGTColors.primaryDark,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: GoogleFonts.alexandria(
          fontSize: 16,
          color: GranelGTColors.textSecondary,
        ),
        hintStyle: GoogleFonts.alexandria(
          fontSize: 16,
          color: GranelGTColors.textSecondary,
        ),
      ),

      // Text Theme
      textTheme: GoogleFonts.alexandriaTextTheme().copyWith(
        displayLarge: GoogleFonts.alexandria(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: GranelGTColors.textPrimary,
        ),
        displayMedium: GoogleFonts.alexandria(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: GranelGTColors.textPrimary,
        ),
        displaySmall: GoogleFonts.alexandria(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: GranelGTColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.alexandria(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: GranelGTColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.alexandria(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: GranelGTColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.alexandria(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: GranelGTColors.textPrimary,
        ),
        titleLarge: GoogleFonts.alexandria(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: GranelGTColors.textPrimary,
        ),
        titleMedium: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: GranelGTColors.textPrimary,
        ),
        titleSmall: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: GranelGTColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: GranelGTColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: GranelGTColors.textPrimary,
        ),
        bodySmall: GoogleFonts.alexandria(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: GranelGTColors.textSecondary,
        ),
        labelLarge: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: GranelGTColors.textSecondary,
        ),
        labelMedium: GoogleFonts.alexandria(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: GranelGTColors.textSecondary,
        ),
        labelSmall: GoogleFonts.alexandria(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: GranelGTColors.textSecondary,
        ),
      ),

      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),

      // Divider Theme: stronger contrast
      dividerTheme: DividerThemeData(
        color: GranelGTColors.dividerSoft.withValues(alpha: 0.5),
        thickness: 1,
        space: 0.5,
      ),
      // DataTable Theme: improved table styling
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(GranelGTColors.surface),
        headingTextStyle: GoogleFonts.alexandria(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: GranelGTColors.textPrimary,
        ),
        dataRowColor: WidgetStateProperty.all(Colors.white),
        dataTextStyle: GoogleFonts.alexandria(
          fontSize: 14,
          color: GranelGTColors.textPrimary,
        ),
        dividerThickness: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: GranelGTColors.dividerSoft,
        selectedColor: GranelGTColors.primary,
        disabledColor: GranelGTColors.textSecondary.withValues(alpha: 0.3),
        labelStyle: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(
          color: GranelGTColors.textSecondary.withValues(alpha: 0.3),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: <ThemeExtension<dynamic>>[AppStatusColors.dark()],

      // Esquema de colores oscuro
      colorScheme: ColorScheme.fromSeed(
        seedColor: GranelGTColors.primaryDark,
        brightness: Brightness.dark,
        primary: GranelGTColors.primaryDark,
        onPrimary: Colors.white,
        secondary: GranelGTColors.accent,
        onSecondary: Colors.white,
        surface: GranelGTColors.background,
        onSurface: Colors.white,
        // background: const Color(0xFF121212), // deprecated
        // onBackground: Colors.white, // deprecated
        error: GranelGTColors.primaryDark,
        onError: Colors.white,
      ),

      // Scaffold Background (Oscuro)
      scaffoldBackgroundColor: GranelGTColors.background,
      // AppBar Theme Oscuro
      appBarTheme: AppBarTheme(
        backgroundColor: GranelGTColors.background,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.alexandria(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
      ),

      // Card Theme Oscuro
      cardTheme: CardThemeData(
        color: GranelGTColors.background,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ElevatedButton Theme Oscuro
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GranelGTColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.alexandria(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FloatingActionButton Theme Oscuro
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: GranelGTColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // InputDecoration Theme Oscuro
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: UnigasColors.primaryDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: UnigasColors.primaryDark,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: UnigasColors.secondaryDark,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: GoogleFonts.alexandria(
          fontSize: 16,
          color: Colors.grey.shade400,
        ),
        hintStyle: GoogleFonts.alexandria(
          fontSize: 16,
          color: Colors.grey.shade400,
        ),
      ),

      // Text Theme Oscuro
      textTheme: GoogleFonts.alexandriaTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.alexandria(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            displayMedium: GoogleFonts.alexandria(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            displaySmall: GoogleFonts.alexandria(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            headlineLarge: GoogleFonts.alexandria(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            headlineMedium: GoogleFonts.alexandria(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            headlineSmall: GoogleFonts.alexandria(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            titleLarge: GoogleFonts.alexandria(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            titleMedium: GoogleFonts.alexandria(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            titleSmall: GoogleFonts.alexandria(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            bodyLarge: GoogleFonts.alexandria(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
            bodyMedium: GoogleFonts.alexandria(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
            bodySmall: GoogleFonts.alexandria(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.grey.shade400,
            ),
            labelLarge: GoogleFonts.alexandria(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
            ),
            labelMedium: GoogleFonts.alexandria(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
            ),
            labelSmall: GoogleFonts.alexandria(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
            ),
          ),

      // Drawer Theme Oscuro
      drawerTheme: const DrawerThemeData(
        backgroundColor: UnigasColors.primaryDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),

      // Divider Theme Oscuro
      dividerTheme: DividerThemeData(
        color: Colors.grey.withValues(alpha: 0.3),
        thickness: 1,
        space: 1,
      ),

      // Chip Theme Oscuro
      chipTheme: ChipThemeData(
        backgroundColor: UnigasColors.primaryDark,
        selectedColor: UnigasColors.secondaryDark,
        disabledColor: Colors.grey.withValues(alpha: 0.3),
        labelStyle: GoogleFonts.alexandria(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
