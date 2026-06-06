import 'dart:developer' as dev;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as im;

/// Conversor de imágenes PNG a comandos ESC/POS para impresoras térmicas
/// Optimizado para impresoras Bixolon de 3 pulgadas (576 dots @ 203 DPI)
class EscPosConverter {
  /// Convierte un PNG a bytes ESC/POS raster (`GS v 0`) listo para enviar.
  ///
  /// [png]          : bytes del PNG de entrada.
  /// [maxDotsWidth] : ancho máximo imprimible (576 para Bixolon 3").
  /// [bandHeight]   : filas por banda (256 va bien para RAM/velocidad).
  /// [threshold]    : umbral binario 0–255 (más bajo = impresión más clara).
  /// [gamma]        : >1 aclara, <1 oscurece (se aplica ANTES del threshold).
  /// [useDither]    : si true, aplica Floyd–Steinberg (fotos/logos grises).
  /// [invert]       : si tu impresora imprime invertido, ponlo en true.
  static Uint8List pngToEscPosRaster(
    Uint8List png, {
    int maxDotsWidth = 576,
    int bandHeight = 256,
    int threshold = 185,
    double gamma = 1.0,
    bool useDither = false,
    bool invert = false,
  }) {
    try {
      final im.Image? decoded = im.decodeImage(png);
      if (decoded == null) {
        dev.log('[EscPosConverter] No se pudo decodificar PNG');
        return Uint8List(0);
      }

      dev.log(
        '[EscPosConverter] Imagen original: ${decoded.width}x${decoded.height}',
      );

      // 1) Resize al ancho máximo y asegurar múltiplo de 8
      int w = math.min(decoded.width, maxDotsWidth);
      w = w - (w % 8); // Redondear hacia abajo al múltiplo de 8 más cercano
      if (w < 8) {
        dev.log('[EscPosConverter] Ancho muy pequeño: $w');
        return Uint8List(0);
      }

      final int h = (decoded.height * (w / decoded.width)).round();

      dev.log('[EscPosConverter] Redimensionando a: ${w}x$h');

      final im.Image resized = im.copyResize(
        decoded,
        width: w,
        height: h,
        // Lanczos3 no está disponible, cubic es la mejor alternativa integrada
        interpolation: im.Interpolation.cubic,
      );

      // 2) Convertir a escala de grises
      im.Image gray = im.grayscale(resized);

      // 3) Ajuste de gamma (gamma > 1 aclara)
      if (gamma != 1.0) {
        gray = _applyGamma(gray, gamma);
      }

      // 4) Binarizar
      final im.Image mono = useDither
          ? toMonoDitherFS(gray) // 0 / 255 con dithering
          : _toMonoThreshold(gray, threshold); // 0 / 255 por umbral

      // 5) Convertir a formato ESC/POS raster (GS v 0) en bandas
      return _buildRasterBytes(mono, bandHeight: bandHeight, invert: invert);
    } catch (e) {
      dev.log('[EscPosConverter] Error: $e');
      return Uint8List(0);
    }
  }

  /// Aplica un threshold simple.
  /// Valores < threshold → negro (0), >= threshold → blanco (255).
  static im.Image _toMonoThreshold(im.Image g, int threshold) {
    final im.Image out = im.Image(
      width: g.width,
      height: g.height,
      numChannels: 1,
    );

    for (int y = 0; y < g.height; y++) {
      for (int x = 0; x < g.width; x++) {
        final im.Pixel pixel = g.getPixel(x, y);
        final num luminance = pixel.r;
        final int value = luminance < threshold ? 0 : 255;
        out.setPixelR(x, y, value);
      }
    }

    return out;
  }

  /// Ajuste de gamma en escala de grises.
  /// gamma > 1 aclara, gamma < 1 oscurece.
  static im.Image _applyGamma(im.Image g, double gamma) {
    final im.Image out = im.Image.from(g);
    final double invGamma = 1.0 / gamma;

    for (int y = 0; y < out.height; y++) {
      for (int x = 0; x < out.width; x++) {
        final im.Pixel p = out.getPixel(x, y);
        final double l = p.r.toDouble();
        final double n = l / 255.0;
        final double corrected = math.pow(n, invGamma).toDouble();
        final int v = (corrected * 255.0).round().clamp(0, 255);
        out.setPixelR(x, y, v);
      }
    }

    return out;
  }

  /// Floyd–Steinberg dithering para mejor detalle en fotos
  /// Distribuye el error de cuantización a píxeles vecinos
  static im.Image toMonoDitherFS(im.Image g) {
    final im.Image out = im.Image.from(g); // Crear copia

    for (int y = 0; y < out.height; y++) {
      for (int x = 0; x < out.width; x++) {
        final im.Pixel pixel = out.getPixel(x, y);
        final num oldL = pixel.r;

        // Cuantizar a 0 o 255
        final int newL = oldL < 128 ? 0 : 255;
        final num err = oldL - newL;

        out.setPixelR(x, y, newL);

        // Distribuir error a píxeles vecinos:
        //     X   7/16
        // 3/16 5/16 1/16
        addErr(out, x + 1, y, (err * 7 ~/ 16));
        addErr(out, x - 1, y + 1, (err * 3 ~/ 16));
        addErr(out, x, y + 1, (err * 5 ~/ 16));
        addErr(out, x + 1, y + 1, (err * 1 ~/ 16));
      }
    }

    return out;
  }

  /// Helper para agregar error de dithering a un píxel
  static void addErr(im.Image img, int x, int y, int v) {
    if (x < 0 || y < 0 || x >= img.width || y >= img.height) return;

    final num currentL = img.getPixel(x, y).r;
    final int newL = (currentL + v).clamp(0, 255) as int;
    img.setPixelR(x, y, newL);
  }

  /// Construye los comandos ESC/POS raster (`GS v 0`) a partir de una imagen
  /// ya binarizada (0 = negro, 255 = blanco) en bandas.
  static Uint8List _buildRasterBytes(
    im.Image mono, {
    int bandHeight = 256,
    bool invert = false,
  }) {
    final BytesBuilder bb = BytesBuilder();

    bb.add(_escInit());
    bb.add(_alignLeft());

    final int width = mono.width;
    final int height = mono.height;
    final int bytesPerRow = (width + 7) ~/ 8;
    if (bandHeight <= 0) bandHeight = height;

    for (int bandY = 0; bandY < height; bandY += bandHeight) {
      final int rows = math.min(bandHeight, height - bandY);

      // GS v 0 m xL xH yL yH
      bb.add(<int>[
        0x1D,
        0x76,
        0x30,
        0x00, // m = 0 (normal)
        bytesPerRow & 0xFF,
        (bytesPerRow >> 8) & 0xFF,
        rows & 0xFF,
        (rows >> 8) & 0xFF,
      ]);

      for (int y = 0; y < rows; y++) {
        final int yy = bandY + y;
        for (int bx = 0; bx < bytesPerRow; bx++) {
          int b = 0;
          for (int bit = 0; bit < 8; bit++) {
            final int x = bx * 8 + bit;
            if (x >= width) continue;

            final int l = mono.getPixel(x, yy).r.toInt();
            bool isBlack = l == 0;
            if (invert) isBlack = !isBlack;

            if (isBlack) {
              // bit más significativo = píxel más a la izquierda
              b |= (0x80 >> bit);
            }
          }
          bb.addByte(b);
        }
      }
    }

    // Unos feeds al final para asegurar salida completa del papel
    bb.add(_lineFeed(count: 3));

    return bb.toBytes();
  }

  // === Comandos ESC/POS básicos ===

  /// ESC @ - Inicializar impresora
  static List<int> _escInit() => <int>[0x1B, 0x40];

  /// ESC a 0 - Alinear a la izquierda
  static List<int> _alignLeft() => <int>[0x1B, 0x61, 0x00];

  /// ESC a 1 - Alinear al centro
  static List<int> _alignCenter() => <int>[0x1B, 0x61, 0x01];

  /// ESC a 2 - Alinear a la derecha
  static List<int> _alignRight() => <int>[0x1B, 0x61, 0x02];

  /// GS V m - Cortar papel
  /// m=0: Corte total
  /// m=1: Corte parcial (si la impresora lo soporta)
  static List<int> _cut({bool partial = false}) => <int>[
    0x1D,
    0x56,
    partial ? 0x01 : 0x00,
  ];

  /// LF - Line feed (nueva línea)
  static List<int> _lineFeed({int count = 1}) => List<int>.filled(count, 0x0A);

  /// Crear comando ESC/POS para imprimir texto plano
  static Uint8List textToEscPos(
    String text, {
    bool bold = false,
    bool underline = false,
    int fontSize = 0, // 0=normal, 1=2x height, 2=2x width, 3=2x both
    String alignment = 'left', // 'left', 'center', 'right'
    bool cut = true,
  }) {
    final BytesBuilder bytes = BytesBuilder();

    // Inicializar
    bytes.add(_escInit());

    // Alineación  (arreglado: sin fall-through)
    switch (alignment.toLowerCase()) {
      case 'center':
        bytes.add(_alignCenter());
        break;
      case 'right':
        bytes.add(_alignRight());
        break;
      default:
        bytes.add(_alignLeft());
        break;
    }

    // Negrita: ESC E 1
    if (bold) {
      bytes.add(<int>[0x1B, 0x45, 0x01]);
    }

    // Subrayado: ESC - 1
    if (underline) {
      bytes.add(<int>[0x1B, 0x2D, 0x01]);
    }

    // Tamaño: GS ! n
    if (fontSize > 0) {
      int n = 0;
      if (fontSize == 1 || fontSize == 3) n |= 0x01;
      if (fontSize == 2 || fontSize == 3) n |= 0x10;
      bytes.add(<int>[0x1D, 0x21, n]);
    }

    // Texto
    bytes.add(text.codeUnits);

    // Reset estilos
    if (bold) bytes.add(<int>[0x1B, 0x45, 0x00]);
    if (underline) bytes.add(<int>[0x1B, 0x2D, 0x00]);
    if (fontSize > 0) bytes.add(<int>[0x1D, 0x21, 0x00]);

    // Line feeds
    bytes.add(_lineFeed(count: 2));

    // Cortar
    if (cut) {
      bytes.add(_cut());
    }

    return bytes.toBytes();
  }

  /// Validar que la imagen cumpla con los requisitos de la impresora
  static Map<String, dynamic> validateImage(Uint8List png, int maxDotsWidth) {
    try {
      final im.Image? decoded = im.decodeImage(png);
      if (decoded == null) {
        return <String, dynamic>{
          'valid': false,
          'error': 'No se pudo decodificar la imagen',
        };
      }

      return <String, dynamic>{
        'valid': true,
        'width': decoded.width,
        'height': decoded.height,
        'willResize': decoded.width > maxDotsWidth,
        'finalWidth':
            math.min(decoded.width, maxDotsWidth) -
            (math.min(decoded.width, maxDotsWidth) % 8),
        'finalHeight': decoded.width > maxDotsWidth
            ? (decoded.height * (maxDotsWidth / decoded.width)).round()
            : decoded.height,
      };
    } catch (e) {
      return <String, dynamic>{
        'valid': false,
        'error': 'Error validando imagen: $e',
      };
    }
  }
}
