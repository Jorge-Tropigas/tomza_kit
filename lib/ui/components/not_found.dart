import 'package:material_ui/material_ui.dart';

import 'package:google_fonts/google_fonts.dart';

class WidgetNotFound extends StatelessWidget {
  const WidgetNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              'Página no encontrada',
              style: GoogleFonts.farro(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'La página que buscas no existe o fue movida.',
              style: GoogleFonts.farro(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Regresar'),
            ),
          ],
        ),
      ),
    );
  }
}
