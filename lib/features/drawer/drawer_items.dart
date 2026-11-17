import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawerItems extends StatelessWidget {
  const DrawerItems({
    super.key,
    required this.context,
    required this.title,
    required this.icon,
    required this.route,
    required this.currentRoute,
    this.onTap,
  });

  final BuildContext context;
  final String title;
  final IconData icon;
  final String route;
  final String? currentRoute;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = currentRoute == route;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        borderRadius: BorderRadius.circular(30),
        color: isSelected
            ? (isDark
                  ? Colors.blueGrey.shade700
                  : const Color.fromARGB(255, 25, 88, 139))
            : Colors.transparent,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          selected: isSelected,
          leading: Icon(
            icon,
            color: isSelected ? Colors.white : theme.iconTheme.color,
          ),
          title: Text(
            title,
            style: GoogleFonts.abyssinicaSil(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : theme.textTheme.bodyMedium?.color,
            ),
          ),
          onTap:
              onTap ??
              () {
                if (!isSelected) {
                  Navigator.pushReplacementNamed(context, route);
                } else {
                  Navigator.pop(context);
                }
              },
        ),
      ),
    );
  }
}
