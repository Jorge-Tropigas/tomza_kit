import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomDialogType { error, warning, info, success }

class DialogAction {
  const DialogAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;
}

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    required this.title,
    required this.description,
    required this.type,
    required this.onAccept,
    this.actions,
  });

  final String title;
  final String description;
  final CustomDialogType type;
  final VoidCallback onAccept;
  final List<DialogAction>? actions;

  IconData _getIcon() {
    switch (type) {
      case CustomDialogType.error:
        return Icons.error_outline_rounded;
      case CustomDialogType.warning:
        return Icons.warning_amber_rounded;
      case CustomDialogType.info:
        return Icons.info_outline_rounded;
      case CustomDialogType.success:
        return Icons.check_circle_outline_rounded;
    }
  }

  Color _baseColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (type) {
      case CustomDialogType.error:
        return theme.colorScheme.error;
      case CustomDialogType.warning:
        return Colors.amber.shade800;
      case CustomDialogType.info:
        return theme.colorScheme.secondary;
      case CustomDialogType.success:
        return Colors.green.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = _baseColor(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Icon Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: base.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Icon(_getIcon(), color: base, size: 64),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                title.toUpperCase(),
                style: GoogleFonts.gabarito(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                description,
                style: GoogleFonts.gabarito(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: _buildActions(context, base),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, Color baseColor) {
    if (actions != null && actions!.isNotEmpty) {
      return Row(
        children: actions!.map((a) {
          final isLast = actions!.last == a;
          final isPrimary = a.isPrimary || isLast;
          
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 12),
              child: isPrimary 
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: baseColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: a.onPressed,
                    child: Text(
                      a.label,
                      style: GoogleFonts.gabarito(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  )
                : TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.grey.shade600,
                    ),
                    onPressed: a.onPressed,
                    child: Text(
                      a.label,
                      style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
            ),
          );
        }).toList(),
      );
    }
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: baseColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: onAccept,
        child: Text(
          'ACEPTAR',
          style: GoogleFonts.gabarito(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ),
    );
  }
}
