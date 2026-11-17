import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tomza_kit/ui/components/image/tomza_image.dart';

void main() {
  testWidgets('TomzaImage shows placeholder when no source', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
      body: Center(child: TomzaImage.memory(null)),
        ),
      ),
    );
  // Placeholder should be present (Icon image)
  expect(find.byIcon(Icons.image), findsOneWidget);
  });

  testWidgets('TomzaImage shows network image placeholder while loading', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TomzaImage.network(
            'https://example.com/nonexistent.png',
            width: 100,
            height: 100,
            // Provide a deterministic placeholder for test
            placeholder: SizedBox(key: Key('test-placeholder')),
            errorWidget: SizedBox(key: Key('test-error')),
          ),
        ),
      ),
    );

  // The provided placeholder should be present in the widget tree
  expect(find.byKey(Key('test-placeholder')), findsOneWidget);
  });
}
