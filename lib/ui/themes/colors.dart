import 'package:flutter/material.dart';

/// Paleta Premium Muted para la marca Unigas.
class UnigasColors {
  UnigasColors._();

  // Paleta Premium Muted
  static const Color primary = Color(0xFF253058);
  static const Color secondary = Color(0xFFC83A32);
  static const Color accent = Color(0xFFD8C53A);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF242423);
  static const Color textSecondary = Color(0xFF6B6B66);
  static const Color dividerSoft = Color(0xFFE2DED2);

  // Variantes para gradientes o estados
  static const Color primaryDark = Color(0xFF1A2143);
  static const Color secondaryDark = Color(0xFFA02A25);
  static const Color white = Colors.white;

  // Fondo neutro tibio para pantallas (deriva de dividerSoft) que da
  // contraste premium a las tarjetas blancas sin salir de la paleta.
  static const Color scaffoldBackground = Color(0xFFF7F5F1);

  /// Gradientes útiles
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[primary, primaryDark],
  );

  static const Gradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[secondary, secondaryDark],
  );

  static const Gradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[white, scaffoldBackground],
  );
}

/// Paleta Premium Muted para la marca Tropigas.
class GranelGTColors {
  GranelGTColors._();

  // Paleta Premium Muted
  static const Color primary = Color(0xFFC83A32); // Brand Red Muted
  static const Color secondary = Color(0xFF243F73); // Brand Blue Muted
  static const Color accent = Color(0xFFD8C53A); // Brand Yellow Muted
  static const Color background = Color(0xFFFFFFFF); // Blanco
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF242423);
  static const Color textSecondary = Color(0xFF6B6B66);
  static const Color dividerSoft = Color(0xFFE2DED2);

  // Variantes para gradientes o estados
  static const Color primaryDark = Color(0xFFA02A25);
  static const Color secondaryDark = Color(0xFF1A2E52);
  static const Color white = Colors.white;

  // Fondo neutro tibio para pantallas (deriva de dividerSoft) que da
  // contraste premium a las tarjetas blancas sin salir de la paleta.
  static const Color scaffoldBackground = Color(0xFFF7F5F1);

  /// Gradientes útiles
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[primary, primaryDark],
  );

  static const Gradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[secondary, secondaryDark],
  );

  static const Gradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[white, scaffoldBackground],
  );
}

class TropigasGTColors {
  TropigasGTColors._();

  static const Color primary = Color(0xFFDF7401);
  static const Color primaryDark = Color(0xFF11094B);
  static const Color accent = Color(0xFFFFC107);
  static const Color editField = Color(0xFFEEE8AA);
  static const Color nonEditField = Color(0xFFFFFFFF);

  static const Color winBackground = Color(0xFFA4A4A4);
  static const Color button = Color(0xFF51C2FB);
  static const Color secondary = button;
  static const Color layout = Color(0xFFF0F5F5);
  static const Color layoutBorder = Color(0xFF476B6B);
  static const Color secondaryDark = layoutBorder;
  static const Color focusedEditTxt = Color(0xFFDF7401);
  static const Color toolBar = Color(0xFFDF7401);

  static const Color textPrimary = Color(0xFF242423);
  static const Color textSecondary = Color(0xFF6B6B66);

  static const Color circleBackground = Color(0xFFFF8000);
  static const Color circleBackgroundDis = Color(0xFF9C9C9C);
  static const Color circleBackgroundTitle = Color(0xFF000000);
  static const Color swipeListItem = Color(0xFFC4D4D4);
  static const Color squareFactura = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFFF0000);
  static const Color white = Colors.white;

  // Fondo neutro tibio para pantallas (deriva de dividerSoft) que da
  // contraste premium a las tarjetas blancas sin salir de la paleta.
  static const Color scaffoldBackground = Color(0xFFF7F5F1);

  /// Gradientes útiles
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[primary, primaryDark],
  );

  static const Gradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[secondary, secondaryDark],
  );

  static const Gradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[white, scaffoldBackground],
  );
}
