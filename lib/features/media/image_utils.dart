import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// ImageUtils: utilidades de procesamiento de imagen (mock).

class ImageUtils {
  static List<int> resize(List<int> bytes, {int maxWidth = 512}) {
    // TODO: Usar paquete de imágenes para resizing real.
    return bytes;
  }

  /// Convierte bytes de imagen a string base64.
  static String imageToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  /// Convierte string base64 a bytes de imagen.
  static Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  /// Convierte archivo de imagen a base64 (asíncrono).
  static Future<String> fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return imageToBase64(bytes);
  }

  /// Convierte base64 a archivo temporal (asíncrono).
  static Future<File> base64ToFile(String base64String, String fileName) async {
    final bytes = base64ToImage(base64String);
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<String> compressBase64(String base64String, int quality) async {
    final bytes = base64ToImage(base64String);
    final compressedImage = await FlutterImageCompress.compressWithList(
      bytes,
      quality: quality,
    );
    return imageToBase64(compressedImage);
  }
}
