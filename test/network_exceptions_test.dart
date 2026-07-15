import 'package:flutter_test/flutter_test.dart';
import 'package:tomza_kit/tomza_kit.dart';

void main() {
  test('UnauthorizedException has code 401 and a default Spanish message', () {
    final e = UnauthorizedException();
    expect(e, isA<AppException>());
    expect(e.code, 401);
    expect(e.message, isNotEmpty);
  });

  test('ForbiddenException has code 403', () {
    expect(ForbiddenException().code, 403);
  });

  test('NotFoundException has code 404', () {
    expect(NotFoundException().code, 404);
  });

  test('BadRequestException defaults to code 400', () {
    final e = BadRequestException();
    expect(e.code, 400);
  });

  test('BadRequestPayloadException exposes the raw payload', () {
    final payload = {'field': 'email', 'reason': 'invalid'};
    final e = BadRequestPayloadException('Datos inválidos', payload);
    expect(e, isA<BadRequestException>());
    expect(e.payload, payload);
    expect(e.toString(), contains('payload='));
  });

  test('ServerException carries the given status code', () {
    final e = ServerException('Error interno', code: 500);
    expect(e.code, 500);
  });

  test('NetworkException represents connectivity issues without a code', () {
    final e = NetworkException('Sin conexión a internet');
    expect(e.code, isNull);
    expect(e.toString(), 'Sin conexión a internet');
  });
}
