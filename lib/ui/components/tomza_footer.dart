import 'package:material_ui/material_ui.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:tomza_kit/utils/responsive.dart';

class TomzaFooter extends StatelessWidget {
  const TomzaFooter({
    super.key,
    required this.totalCorporations,
    required this.totalAmount,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.currencySymbol,
  });

  final double totalCorporations;
  final double totalAmount;
  final String title;
  final String subtitle;
  final IconData icon;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final double fontSize = isTablet ? 22 : 18;
    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: isTablet ? 24 : 12,
      vertical: isTablet ? 14 : 10,
    );
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyMedium?.color;

    String money(BuildContext context, double v, String symbol) {
      final locale = Localizations.localeOf(context).toString();
      final format = NumberFormat.currency(locale: locale, symbol: symbol);
      return format.format(v);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business, size: 22, color: theme.iconTheme.color),
              const SizedBox(width: 4),
              Text(
                '$title $totalCorporations',
                style: GoogleFonts.titilliumWeb(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(icon, size: 22, color: theme.iconTheme.color),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: GoogleFonts.titilliumWeb(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  money(context, totalAmount, currencySymbol),
                  textAlign: TextAlign.right,
                  style: GoogleFonts.titilliumWeb(
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.w900,
                    color: (totalAmount >= 0
                        ? Colors.green[700]
                        : Colors.red[700]),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
