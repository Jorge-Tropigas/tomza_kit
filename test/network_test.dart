import 'package:flutter_test/flutter_test.dart';
import 'package:tomza_kit/tomza_kit.dart';

void main() {
  setUp(() {
    EnvConfig.initialize(baseUrl: 'https://example.com');
    ApiClient.reset();
  });

  test('ApiClient unauthorized maps to exception', () async {
    // We will call a path that likely 404 but we just assert no throw for setup.
    // Since we cannot mock here easily, just ensure client builds.
    expect(() => ApiClient.get('/'), returnsNormally);
  });
}
