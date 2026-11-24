import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;
import 'package:tomza_kit/features/printing/thermal_optimizer.dart';

/// Generador de PDFs optimizados para impresión térmica
///
/// Esta clase proporciona métodos para generar diferentes tipos de documentos
/// (facturas, recibos, tickets) optimizados para impresoras térmicas Bixolon.
///
/// Características:
/// - Fuentes bold monoespaciadas (sin anti-aliasing)
/// - Sin compresión PDF (evita artifacts)
/// - Fondos blancos puros
/// - Tamaños de fuente grandes para claridad
class ThermalPdfGenerator {
  late pw.Font _thermalFont;
  bool _initialized = false;

  /// Inicializa el generador cargando las fuentes necesarias
  Future<void> initialize() async {
    if (_initialized) return;
    _thermalFont = await ThermalOptimizer.loadThermalFont();
    _initialized = true;
  }

  /// Asegura que el generador esté inicializado
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// Genera un PDF de factura optimizado para térmica
  ///
  /// [invoiceNumber]: Número de factura
  /// [date]: Fecha de la factura
  /// [customerName]: Nombre del cliente
  /// [customerInfo]: Información adicional del cliente (dirección, NIT, etc.)
  /// [items]: Lista de items de la factura
  /// [subtotal]: Subtotal antes de impuestos
  /// [tax]: Monto de impuestos
  /// [total]: Total a pagar
  /// [qrCode]: Bytes del código QR (opcional)
  /// [logo]: Bytes del logo (opcional)
  /// [footer]: Texto del pie de página (opcional)
  Future<Uint8List> generateInvoice({
    required String invoiceNumber,
    required String date,
    required String customerName,
    String? customerInfo,
    required List<InvoiceItem> items,
    required double subtotal,
    required double tax,
    required double total,
    Uint8List? qrCode,
    Uint8List? logo,
    String? footer,
  }) async {
    await _ensureInitialized();

    final pdf = ThermalOptimizer.createThermalDocument(
      title: 'Factura $invoiceNumber',
      subject: 'Factura para $customerName',
    );

    pdf.addPage(
      pw.Page(
        pageFormat: ThermalOptimizer.thermal3InchFormat,
        theme: ThermalOptimizer.thermalPageTheme(_thermalFont).theme,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo (si existe)
              if (logo != null) ...[
                pw.Center(
                  child: ThermalOptimizer.thermalImage(logo, height: 60),
                ),
                ThermalOptimizer.verticalSpace(8),
              ],

              // Encabezado
              pw.Center(
                child: pw.Text(
                  'FACTURA',
                  style: ThermalOptimizer.thermalHeaderStyle(
                    font: _thermalFont,
                    fontSize: 24,
                  ),
                ),
              ),
              ThermalOptimizer.verticalSpace(4),

              // Número de factura
              pw.Center(
                child: pw.Text(
                  'No. $invoiceNumber',
                  style: ThermalOptimizer.thermalBodyStyle(
                    font: _thermalFont,
                    fontSize: 14,
                  ),
                ),
              ),
              ThermalOptimizer.verticalSpace(4),

              // Fecha
              pw.Center(
                child: pw.Text(
                  date,
                  style: ThermalOptimizer.thermalBodyStyle(
                    font: _thermalFont,
                    fontSize: 12,
                  ),
                ),
              ),
              ThermalOptimizer.verticalSpace(8),
              ThermalOptimizer.divider(),
              ThermalOptimizer.verticalSpace(8),

              // Información del cliente
              pw.Text(
                'Cliente:',
                style: ThermalOptimizer.thermalBodyStyle(
                  font: _thermalFont,
                  fontSize: 12,
                ),
              ),
              pw.Text(
                customerName,
                style: ThermalOptimizer.thermalBodyStyle(
                  font: _thermalFont,
                  fontSize: 14,
                ),
              ),
              if (customerInfo != null) ...[
                ThermalOptimizer.verticalSpace(2),
                pw.Text(
                  customerInfo,
                  style: ThermalOptimizer.thermalSmallStyle(
                    font: _thermalFont,
                    fontSize: 10,
                  ),
                ),
              ],
              ThermalOptimizer.verticalSpace(8),
              ThermalOptimizer.divider(),
              ThermalOptimizer.verticalSpace(8),

              // Items
              pw.Text(
                'Detalle:',
                style: ThermalOptimizer.thermalBodyStyle(
                  font: _thermalFont,
                  fontSize: 12,
                ),
              ),
              ThermalOptimizer.verticalSpace(4),

              // Tabla de items
              ...items.map((item) => _buildInvoiceItem(item)),

              ThermalOptimizer.verticalSpace(8),
              ThermalOptimizer.divider(),
              ThermalOptimizer.verticalSpace(8),

              // Totales
              _buildTotalRow('Subtotal:', subtotal),
              ThermalOptimizer.verticalSpace(2),
              _buildTotalRow('Impuesto:', tax),
              ThermalOptimizer.verticalSpace(4),
              ThermalOptimizer.divider(thickness: 2),
              ThermalOptimizer.verticalSpace(4),
              _buildTotalRow('TOTAL:', total, isBold: true, fontSize: 16),

              ThermalOptimizer.verticalSpace(12),

              // QR Code (si existe)
              if (qrCode != null) ...[
                pw.Center(
                  child: ThermalOptimizer.thermalImage(
                    qrCode,
                    width: 100,
                    height: 100,
                  ),
                ),
                ThermalOptimizer.verticalSpace(8),
              ],

              // Footer
              if (footer != null) ...[
                ThermalOptimizer.divider(),
                ThermalOptimizer.verticalSpace(4),
                pw.Center(
                  child: pw.Text(
                    footer,
                    style: ThermalOptimizer.thermalSmallStyle(
                      font: _thermalFont,
                      fontSize: 9,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Genera un PDF de recibo simple
  Future<Uint8List> generateReceipt({
    required String receiptNumber,
    required String date,
    required String description,
    required double amount,
    String? paymentMethod,
    Uint8List? logo,
    String? footer,
  }) async {
    await _ensureInitialized();

    final pdf = ThermalOptimizer.createThermalDocument(
      title: 'Recibo $receiptNumber',
    );

    pdf.addPage(
      pw.Page(
        pageFormat: ThermalOptimizer.thermal3InchFormat,
        theme: ThermalOptimizer.thermalPageTheme(_thermalFont).theme,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo
              if (logo != null) ...[
                pw.Center(
                  child: ThermalOptimizer.thermalImage(logo, height: 60),
                ),
                ThermalOptimizer.verticalSpace(8),
              ],

              // Título
              pw.Center(
                child: pw.Text(
                  'RECIBO',
                  style: ThermalOptimizer.thermalHeaderStyle(
                    font: _thermalFont,
                    fontSize: 20,
                  ),
                ),
              ),
              ThermalOptimizer.verticalSpace(4),

              // Número y fecha
              pw.Center(
                child: pw.Text(
                  'No. $receiptNumber',
                  style: ThermalOptimizer.thermalBodyStyle(
                    font: _thermalFont,
                    fontSize: 12,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  date,
                  style: ThermalOptimizer.thermalBodyStyle(
                    font: _thermalFont,
                    fontSize: 12,
                  ),
                ),
              ),
              ThermalOptimizer.verticalSpace(8),
              ThermalOptimizer.divider(),
              ThermalOptimizer.verticalSpace(8),

              // Descripción
              pw.Text(
                description,
                style: ThermalOptimizer.thermalBodyStyle(
                  font: _thermalFont,
                  fontSize: 12,
                ),
              ),
              ThermalOptimizer.verticalSpace(8),

              // Monto
              ThermalOptimizer.divider(thickness: 2),
              ThermalOptimizer.verticalSpace(4),
              _buildTotalRow('MONTO:', amount, isBold: true, fontSize: 16),
              ThermalOptimizer.verticalSpace(4),
              ThermalOptimizer.divider(thickness: 2),

              // Método de pago
              if (paymentMethod != null) ...[
                ThermalOptimizer.verticalSpace(8),
                pw.Text(
                  'Forma de pago: $paymentMethod',
                  style: ThermalOptimizer.thermalBodyStyle(
                    font: _thermalFont,
                    fontSize: 11,
                  ),
                ),
              ],

              ThermalOptimizer.verticalSpace(12),

              // Footer
              if (footer != null) ...[
                ThermalOptimizer.divider(),
                ThermalOptimizer.verticalSpace(4),
                pw.Center(
                  child: pw.Text(
                    footer,
                    style: ThermalOptimizer.thermalSmallStyle(
                      font: _thermalFont,
                      fontSize: 9,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Genera un documento genérico con texto personalizado
  Future<Uint8List> generateDocument({
    required String title,
    required List<DocumentSection> sections,
    Uint8List? logo,
    Uint8List? qrCode,
    String? footer,
  }) async {
    await _ensureInitialized();

    final pdf = ThermalOptimizer.createThermalDocument(title: title);

    pdf.addPage(
      pw.Page(
        pageFormat: ThermalOptimizer.thermal3InchFormat,
        theme: ThermalOptimizer.thermalPageTheme(_thermalFont).theme,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo
              if (logo != null) ...[
                pw.Center(
                  child: ThermalOptimizer.thermalImage(logo, height: 60),
                ),
                ThermalOptimizer.verticalSpace(8),
              ],

              // Título
              pw.Center(
                child: pw.Text(
                  title,
                  style: ThermalOptimizer.thermalHeaderStyle(
                    font: _thermalFont,
                    fontSize: 20,
                  ),
                ),
              ),
              ThermalOptimizer.verticalSpace(8),
              ThermalOptimizer.divider(),
              ThermalOptimizer.verticalSpace(8),

              // Secciones
              ...sections.map((section) => _buildDocumentSection(section)),

              // QR Code
              if (qrCode != null) ...[
                ThermalOptimizer.verticalSpace(8),
                pw.Center(
                  child: ThermalOptimizer.thermalImage(
                    qrCode,
                    width: 100,
                    height: 100,
                  ),
                ),
              ],

              // Footer
              if (footer != null) ...[
                ThermalOptimizer.verticalSpace(8),
                ThermalOptimizer.divider(),
                ThermalOptimizer.verticalSpace(4),
                pw.Center(
                  child: pw.Text(
                    footer,
                    style: ThermalOptimizer.thermalSmallStyle(
                      font: _thermalFont,
                      fontSize: 9,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // === Métodos Privados de Construcción ===

  pw.Widget _buildInvoiceItem(InvoiceItem item) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  item.description,
                  style: ThermalOptimizer.thermalBodyStyle(
                    font: _thermalFont,
                    fontSize: 11,
                  ),
                ),
              ),
              pw.Text(
                _formatCurrency(item.total),
                style: ThermalOptimizer.thermalBodyStyle(
                  font: _thermalFont,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (item.quantity > 0 && item.unitPrice > 0) ...[
            pw.Text(
              '  ${item.quantity} x ${_formatCurrency(item.unitPrice)}',
              style: ThermalOptimizer.thermalSmallStyle(
                font: _thermalFont,
                fontSize: 9,
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildTotalRow(
    String label,
    double amount, {
    bool isBold = false,
    double fontSize = 12,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: ThermalOptimizer.thermalBodyStyle(
            font: _thermalFont,
            fontSize: fontSize,
          ),
        ),
        pw.Text(
          _formatCurrency(amount),
          style: ThermalOptimizer.thermalBodyStyle(
            font: _thermalFont,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildDocumentSection(DocumentSection section) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (section.title != null) ...[
          pw.Text(
            section.title!,
            style: ThermalOptimizer.thermalBodyStyle(
              font: _thermalFont,
              fontSize: 14,
            ),
          ),
          ThermalOptimizer.verticalSpace(4),
        ],
        pw.Text(
          section.content,
          style: ThermalOptimizer.thermalBodyStyle(
            font: _thermalFont,
            fontSize: 11,
          ),
        ),
        ThermalOptimizer.verticalSpace(8),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}

/// Modelo para un item de factura
class InvoiceItem {
  final String description;
  final double quantity;
  final double unitPrice;
  final double total;

  InvoiceItem({
    required this.description,
    this.quantity = 0,
    this.unitPrice = 0,
    required this.total,
  });
}

/// Modelo para una sección de documento genérico
class DocumentSection {
  final String? title;
  final String content;

  DocumentSection({this.title, required this.content});
}
