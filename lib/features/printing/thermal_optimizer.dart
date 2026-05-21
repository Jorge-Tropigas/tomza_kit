import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Utilidades para optimizar PDFs para impresión térmica
///
/// Esta clase proporciona configuraciones y estilos optimizados para
/// impresoras térmicas, eliminando problemas de anti-aliasing y líneas blancas.
class ThermalOptimizer {
  // === Constantes de Impresora Térmica ===

  /// Ancho estándar de impresora térmica de 3 pulgadas en puntos (203 DPI)
  static const double thermal3InchWidthPt = 216.0; // 3" × 72 pt/inch

  /// Altura de página para formato continuo (ajustable según contenido)
  static const double thermalDefaultHeightPt = 792.0; // 11 inches

  /// DPI estándar de impresoras térmicas
  static const int thermalDpi = 203;

  /// Ancho en dots/píxeles para impresora de 3"
  static const int thermal3InchWidthDots = 576; // 3" × 203 DPI

  // === Colores Puros (sin anti-aliasing) ===

  /// Blanco puro (sin grises) - esencial para fondo térmico
  static PdfColor get pureWhite => PdfColor.fromInt(0xFFFFFFFF);

  /// Negro puro (sin grises) - esencial para texto térmico
  static PdfColor get pureBlack => PdfColor.fromInt(0xFF000000);

  // === Fuentes ===

  static pw.Font? _cachedThermalFont;

  /// Carga la fuente monoespaciada bold optimizada para impresión térmica
  ///
  /// Esta fuente se carga una sola vez y se cachea para reutilización.
  /// Usa Roboto Mono Bold que tiene excelente definición en impresoras térmicas.
  static Future<pw.Font> loadThermalFont() async {
    if (_cachedThermalFont != null) {
      return _cachedThermalFont!;
    }

    try {
      // Intentar cargar fuente personalizada desde assets de la librería
      final fontData = await rootBundle.load(
        'packages/tomza_kit/assets/fonts/RobotoMono-Bold.ttf',
      );
      _cachedThermalFont = pw.Font.ttf(fontData);
      return _cachedThermalFont!;
    } catch (e) {
      // Fallback: usar fuente base del paquete PDF
      // Nota: Las fuentes base no son ideales para térmica pero funcionan
      _cachedThermalFont = pw.Font.courier();
      return _cachedThermalFont!;
    }
  }

  // === Estilos de Texto Térmico ===

  /// Estilo de texto optimizado para impresión térmica
  ///
  /// Características:
  /// - Fuente monoespaciada bold
  /// - Tamaños grandes para evitar anti-aliasing
  /// - Sin efectos que generen grises
  static pw.TextStyle thermalTextStyle({
    required pw.Font font,
    double fontSize = 12.0,
    bool bold = true,
    PdfColor? color,
  }) {
    return pw.TextStyle(
      font: font,
      fontSize: fontSize,
      color: color ?? pureBlack,
      // Bold ya está en la fuente, no aplicar fontWeight adicional
      // que podría causar anti-aliasing
    );
  }

  /// Estilo para encabezados (texto grande)
  static pw.TextStyle thermalHeaderStyle({
    required pw.Font font,
    double fontSize = 20.0,
  }) {
    return thermalTextStyle(font: font, fontSize: fontSize, bold: true);
  }

  /// Estilo para texto normal del cuerpo
  static pw.TextStyle thermalBodyStyle({
    required pw.Font font,
    double fontSize = 12.0,
  }) {
    return thermalTextStyle(font: font, fontSize: fontSize, bold: true);
  }

  /// Estilo para texto pequeño (pie de página, notas)
  static pw.TextStyle thermalSmallStyle({
    required pw.Font font,
    double fontSize = 10.0,
  }) {
    return thermalTextStyle(font: font, fontSize: fontSize, bold: true);
  }

  // === Formato de Página ===

  /// Formato de página para impresora térmica de 3 pulgadas
  ///
  /// Usa márgenes mínimos para aprovechar todo el ancho del papel
  static PdfPageFormat get thermal3InchFormat {
    return PdfPageFormat(
      thermal3InchWidthPt,
      thermalDefaultHeightPt,
      marginAll: 8.0, // Márgenes mínimos
    );
  }

  /// Tema de página optimizado para térmica
  ///
  /// Configuración:
  /// - Fondo blanco puro
  /// - Sin compresión de imágenes
  /// - Fuente térmica por defecto
  static pw.PageTheme thermalPageTheme(pw.Font font) {
    return pw.PageTheme(
      pageFormat: thermal3InchFormat,
      theme: pw.ThemeData.withFont(
        base: font,
        bold: font, // Usar la misma fuente bold para todo
      ),
      buildBackground: (context) {
        return pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(color: pureWhite),
        );
      },
    );
  }

  // === Configuración de Documento ===

  /// Crea un documento PDF optimizado para impresión térmica
  ///
  /// Características:
  /// - Sin compresión (evita artifacts)
  /// - Metadatos básicos
  /// - Tema térmico aplicado
  static pw.Document createThermalDocument({
    String? title,
    String? author,
    String? subject,
  }) {
    return pw.Document(
      compress: false, // CRÍTICO: Sin compresión para evitar artifacts
      title: title,
      author: author,
      subject: subject,
      creator: 'TomzaKit Thermal Printer',
      producer: 'TomzaKit',
    );
  }

  // === Utilidades de Layout ===

  /// Espaciado vertical estándar entre elementos
  static pw.Widget verticalSpace([double height = 8.0]) {
    return pw.SizedBox(height: height);
  }

  /// Espaciado horizontal estándar entre elementos
  static pw.Widget horizontalSpace([double width = 8.0]) {
    return pw.SizedBox(width: width);
  }

  /// Línea divisoria horizontal
  static pw.Widget divider({double thickness = 1.0, PdfColor? color}) {
    return pw.Container(height: thickness, color: color ?? pureBlack);
  }

  /// Contenedor con borde para resaltar secciones
  static pw.Widget borderedBox({
    required pw.Widget child,
    double borderWidth = 1.0,
    PdfColor? borderColor,
    double padding = 8.0,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.all(padding),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: borderColor ?? pureBlack,
          width: borderWidth,
        ),
      ),
      child: child,
    );
  }

  // === Utilidades de Imagen ===

  /// Crea un widget de imagen optimizado para térmica
  ///
  /// Las imágenes (QR, logos) ya se renderizan bien, esta función
  /// solo las envuelve con configuración consistente.
  static pw.Widget thermalImage(
    Uint8List imageBytes, {
    double? width,
    double? height,
    pw.BoxFit fit = pw.BoxFit.contain,
  }) {
    final image = pw.MemoryImage(imageBytes);
    return pw.Image(image, width: width, height: height, fit: fit);
  }

  /// Crea un QR code optimizado para térmica
  static pw.Widget thermalQrCode(String data, {double size = 100.0}) {
    return pw.BarcodeWidget(
      data: data,
      barcode: pw.Barcode.qrCode(),
      width: size,
      height: size,
      drawText: false,
    );
  }

  // === Utilidades de Tabla ===

  /// Estilo de tabla optimizado para térmica
  static pw.TableBorder thermalTableBorder({
    double width = 1.0,
    PdfColor? color,
  }) {
    return pw.TableBorder.all(color: color ?? pureBlack, width: width);
  }

  /// Padding estándar para celdas de tabla
  static pw.EdgeInsets get tableCellPadding {
    return const pw.EdgeInsets.all(4.0);
  }
}
