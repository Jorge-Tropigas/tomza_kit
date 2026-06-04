import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../printer_bloc.dart';
import '../../../utils/responsive.dart';

class PrinterLayout extends StatefulWidget {
  const PrinterLayout({super.key});

  @override
  State<PrinterLayout> createState() => _PrinterLayoutState();
}

class _PrinterLayoutState extends State<PrinterLayout> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = AppResponsiveExtension(context).isMobile;
    final theme = Theme.of(context);

    return Consumer<PrinterBloc>(
      builder: (BuildContext context, PrinterBloc model, Widget? child) {
        final bool isConnected = model.selected != null;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20.0 : 40.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Status Header Premium
                _buildStatusHeader(isConnected, model.selected?.name),
                
                const SizedBox(height: 24),

                // Multi-document selection (if applicable)
                if (model.printerArgs.documents.length > 1) ...[
                  _buildDocumentSelector(model),
                  const SizedBox(height: 16),
                ],

                // Actions Premium
                _buildActionButtons(context, model),
                
                const SizedBox(height: 24),

                // PDF Preview Section
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: model.pdfBytes != null
                        ? PdfPreview(
                            build: (format) => model.pdfBytes!,
                            allowPrinting: false,
                            allowSharing: false,
                            canChangePageFormat: false,
                            canChangeOrientation: false,
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusHeader(bool isConnected, String? printerName) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConnected 
            ? theme.colorScheme.secondary.withValues(alpha: 0.08)
            : theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isConnected ? theme.colorScheme.secondary : theme.colorScheme.primary).withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.print_rounded : Icons.print_disabled_rounded,
            color: isConnected ? theme.colorScheme.secondary : theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? 'Impresora Lista' : 'Configurar Impresora',
                  style: GoogleFonts.gabarito(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isConnected ? theme.colorScheme.secondary : theme.colorScheme.primary,
                  ),
                ),
                Text(
                  printerName ?? 'No se ha detectado dispositivo',
                  style: GoogleFonts.gabarito(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isConnected)
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Widget _buildDocumentSelector(PrinterBloc model) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: model.printerArgs.documents.map((doc) {
          final isSelected = model.selectedDocument == doc;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(doc.name),
              selected: isSelected,
              onSelected: (_) => model.setSelectedDocument(doc),
              selectedColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
              labelStyle: GoogleFonts.gabarito(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.grey,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, PrinterBloc model) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildActionButton(
            label: model.busy ? 'IMPRIMIENDO...' : 'IMPRIMIR',
            icon: Icons.print_rounded,
            color: theme.colorScheme.primary,
            onPressed: model.busy ? null : () async {
              final ok = await model.printCurrentDocument();
              if (context.mounted && ok) {
                 if (model.printerArgs.onSuccessPrint != null) {
                    model.printerArgs.onSuccessPrint!();
                  }
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: 'AJUSTAR',
            icon: Icons.settings_rounded,
            color: theme.colorScheme.secondary,
            onPressed: model.busy ? null : () => model.showSelectDialog(context),
            isSecondary: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    bool isSecondary = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isSecondary ? color.withValues(alpha: 0.1) : color,
          borderRadius: BorderRadius.circular(12),
          border: isSecondary ? Border.all(color: color.withValues(alpha: 0.2)) : null,
          boxShadow: !isSecondary && onPressed != null ? [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isSecondary ? color : Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.gabarito(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSecondary ? color : Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
