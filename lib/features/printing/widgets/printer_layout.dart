import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../printer_bloc.dart';
import '../../../utils/responsive.dart';

class PrinterLayout extends StatelessWidget {
  const PrinterLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = AppResponsiveExtension(context).isMobile;
    final bool isSmallMobile = AppResponsiveExtension(context).isSmallMobile;
    final theme = Theme.of(context);

    return Consumer<PrinterBloc>(
      builder: (BuildContext context, PrinterBloc model, Widget? child) => Padding(
        padding: isMobile
            ? (isSmallMobile
                ? const EdgeInsets.all(8.0)
                : const EdgeInsets.all(16.0))
            : const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Estado de emparejamiento/selección
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: model.selected != null
                    ? Colors.green.withValues(alpha: 0.12)
                    : Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: model.selected != null ? Colors.green : Colors.amber,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    model.selected != null
                        ? Icons.check_circle
                        : Icons.warning_amber,
                    color: model.selected != null
                        ? Colors.green
                        : Colors.amber[800],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      model.selected != null
                          ? 'Impresora seleccionada'
                          : 'Sin impresora seleccionada',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallMobile ? 13 : 15,
                      ),
                    ),
                  ),
                  if (!isSmallMobile) ...<Widget>[
                    const Spacer(),
                    Text(
                      model.selected?.name ?? '-',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Selección de documento
            Builder(
              builder: (_) {
                if (model.printerArgs.documents.isEmpty) {
                  return const Text('No hay documentos para mostrar');
                }
                if (model.printerArgs.documents.length <= 1) {
                  return const SizedBox.shrink();
                }
                return Wrap(
                  spacing: 8,
                  children: model.printerArgs.documents.map((doc) {
                    return ChoiceChip(
                      label: Text(doc.name),
                      selected: model.selectedDocument == doc,
                      onSelected: (_) => model.setSelectedDocument(doc),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 12),
            // Acciones principales
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                ElevatedButton.icon(
                  icon: const Icon(Icons.print),
                  label: Text(model.busy ? 'Imprimiendo…' : 'Imprimir'),
                  onPressed: model.busy
                      ? null
                      : () async {
                          final bool ok = await model.printCurrentDocument();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? 'Impresión solicitada'
                                      : 'Error: ${model.error ?? 'No se pudo imprimir'}',
                                ),
                              ),
                            );
                            if (ok) {
                              if (model.printerArgs.onSuccessPrint != null) {
                                model.printerArgs.onSuccessPrint!();
                              }
                            }
                          }
                        },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    model.selected != null
                        ? 'Cambiar impresora'
                        : 'Seleccionar impresora',
                  ),
                  onPressed: model.busy
                      ? null
                      : () => model.showSelectDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Previsualización del PDF
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: model.pdfBytes != null
                    ? (model.printerArgs.pdfViewerBuilder != null
                        ? model.printerArgs.pdfViewerBuilder!(context, model.pdfBytes!)
                        : PdfPreview(
                            build: (format) => model.pdfBytes!,
                            allowPrinting: false,
                            allowSharing: false,
                            canChangePageFormat: false,
                            canChangeOrientation: false,
                          ))
                    : const Center(child: Text('PDF no disponible')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
