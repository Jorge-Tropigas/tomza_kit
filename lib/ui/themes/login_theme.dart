import 'package:material_ui/material_ui.dart';

/// Pequeño wrapper que fuerza un subárbol con tema claro para el flujo de login
/// aunque el resto de la aplicación esté en modo oscuro. De esta forma se
/// garantiza legibilidad de inputs y contraste del formulario sobre fondos
/// corporativos.
class LoginTheme extends StatelessWidget {
  const LoginTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData parent = Theme.of(context);

    // Reusamos la paleta primaria existente pero forzamos esquema claro.
    final ColorScheme parentScheme = parent.colorScheme;
    final ColorScheme lightScheme = parentScheme.copyWith(
      brightness: Brightness.light,
      // Aseguramos superficies claras para tarjeta / fondo local.
      surface: Colors.white,
      onSurface: Colors.black87,
      primary: parentScheme.primary,
      onPrimary: Colors.white,
      secondary: parentScheme.secondary,
      onSecondary: parentScheme.onSecondary,
      error: parentScheme.error,
      onError: parentScheme.onError,
    );

    final ThemeData light = ThemeData(
      useMaterial3: parent.useMaterial3,
      brightness: Brightness.light,
      colorScheme: lightScheme,
      cardTheme: const CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      textTheme: parent.textTheme.apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),
      scaffoldBackgroundColor: parent.scaffoldBackgroundColor,
      // InputDecoration para campos de login (fondo claro independiente del dark global)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: parentScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: parentScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: parentScheme.error, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.black87),
        hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.55)),
        prefixIconColor: Colors.black54,
        suffixIconColor: Colors.black54,
      ),
      iconTheme: parent.iconTheme.copyWith(color: Colors.black54),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: parentScheme.primary,
          foregroundColor: parentScheme.onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      // Conservamos extensiones personalizadas (ej. AppStatusColors) para consistencia.
      extensions: parent.extensions.values.toList(),
    );

    return Theme(data: light, child: child);
  }
}
