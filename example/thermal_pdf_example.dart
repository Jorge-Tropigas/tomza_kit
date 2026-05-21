import 'dart:io';
import 'package:tomza_kit/features/printing/thermal_pdf_generator.dart';

/// Ejemplo de uso del generador de PDFs térmicos
///
/// Este ejemplo muestra cómo generar una factura optimizada para
/// impresoras térmicas Bixolon.
Future<void> main() async {
  // 1. Crear instancia del generador
  final generator = ThermalPdfGenerator();
  await generator.initialize();

  // 2. Preparar datos de la factura
  final items = [
    InvoiceItem(
      description: 'Producto A',
      quantity: 2,
      unitPrice: 15.50,
      total: 31.00,
    ),
    InvoiceItem(
      description: 'Producto B con nombre largo para probar',
      quantity: 1,
      unitPrice: 25.00,
      total: 25.00,
    ),
    InvoiceItem(
      description: 'Servicio C',
      quantity: 3,
      unitPrice: 10.00,
      total: 30.00,
    ),
  ];

  final subtotal = 86.00;
  final tax = 10.32; // 12% IVA
  final total = 96.32;

  // 3. Generar el PDF
  final pdfBytes = await generator.generateInvoice(
    invoiceNumber: 'FAC-001-2024',
    date: '11/12/2024 09:45',
    customerName: 'Juan Pérez García',
    customerInfo: 'NIT: 1234567-8\nDirección: Zona 10, Guatemala',
    items: items,
    subtotal: subtotal,
    tax: tax,
    total: total,
    footer: 'Gracias por su compra\nwww.tomza.com',
  );

  // 4. Guardar el PDF
  final file = File('factura_termica_ejemplo.pdf');
  await file.writeAsBytes(pdfBytes);

  print('✓ PDF generado: ${file.path}');
  print('  Tamaño: ${pdfBytes.length} bytes');
  print('');
  print('Características del PDF:');
  print('  - Fuente: Roboto Mono Bold (monoespaciada)');
  print('  - Sin compresión (evita artifacts)');
  print('  - Fondo blanco puro');
  print('  - Optimizado para impresora térmica de 3"');
  print('');
  print('Para imprimir:');
  print('  await NativeBixolon.printPdfAsImageOverBt(');
  print('    "${file.path}",');
  print('    printerAddress,');
  print('    options: {');
  print('      "threshold": 215,');
  print('      "printWidth": 576,');
  print('    },');
  print('  );');
}
