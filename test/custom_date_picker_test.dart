import 'package:material_ui/material_ui.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:tomza_kit/ui/components/custom_date_picker.dart';

void main() {
  setUpAll(() async {
    // Initialize date formatting for Spanish locale
    await initializeDateFormatting('es_ES', null);
  });

  group('CustomDatePicker', () {
    testWidgets('should display title and store code', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es', 'ES'),
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) => CustomDatePicker(
                        onDateChanged: (DateTime date) {},
                        title: 'Test Title',
                        storeCode: 'STORE001',
                        titleStore: 'Test Store',
                        icon: Icons.store,
                      ),
                    );
                  },
                  child: const Text('Show Picker'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('STORE001'), findsOneWidget);
    });

    testWidgets('should call onDateChanged when date is selected', (
      WidgetTester tester,
    ) async {
      DateTime? selectedDate;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es', 'ES'),
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) => CustomDatePicker(
                        onDateChanged: (DateTime date) {
                          selectedDate = date;
                        },
                        titleStore: 'Test Store',
                        icon: Icons.store,
                      ),
                    );
                  },
                  child: const Text('Show Picker'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      // Tap on the first available date (today or next day)
      final DateTime today = DateTime.now();
      final String dayToTap = today.day.toString();
      await tester.tap(find.text(dayToTap).first);
      await tester.pump();

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(selectedDate, isNotNull);
    });

    testWidgets('should close dialog when cancel is pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es', 'ES'),
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) => CustomDatePicker(
                        onDateChanged: (DateTime date) {},
                        titleStore: '',
                        icon: Icons.store,
                      ),
                    );
                  },
                  child: const Text('Show Picker'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      expect(find.text('Seleccionar Fecha'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Seleccionar Fecha'), findsNothing);
    });
  });
}
