/// Excepciones de red/dominio estandarizadas para tomza_kit.
///
/// `ApiClient` lanza directamente el subtipo correspondiente a partir del
/// código de estado HTTP, para que las apps consumidoras puedan atrapar
/// (`try/catch`) el tipo concreto sin tener que reimplementar su propio
/// mapeo de errores de Dio.
library;

/// Excepción base para todo tipo de error conocido de red/dominio.
abstract class AppException implements Exception {
  AppException(this.message, {this.code});

  /// Mensaje descriptivo, listo para mostrar al usuario.
  final String message;

  /// Código de estado HTTP asociado, si aplica.
  final int? code;

  @override
  String toString() => message;
}

/// Error genérico del servidor (5xx).
class ServerException extends AppException {
  ServerException(super.message, {super.code});
}

/// Error por falta de conexión o problemas de red locales (timeouts, sin
/// señal, certificado inválido, request cancelado, etc.).
class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}

/// Error por credenciales inválidas o sesión expirada (401).
class UnauthorizedException extends AppException {
  UnauthorizedException([
    super.message =
        'Sesión expirada o credenciales inválidas. Por favor, inicie sesión nuevamente.',
  ]) : super(code: 401);
}

/// Error por acceso denegado (403).
class ForbiddenException extends AppException {
  ForbiddenException([
    super.message = 'No tiene permisos para realizar esta acción.',
  ]) : super(code: 403);
}

/// Error por datos inválidos (400 / 422).
class BadRequestException extends AppException {
  BadRequestException([
    super.message = 'La solicitud contiene datos inválidos.',
    int code = 400,
  ]) : super(code: code);
}

/// Bad request que incluye un payload JSON del servidor (p. ej. errores de
/// validación o un documento codificado en base64). Permite a capas
/// superiores acceder al payload crudo sin forzar a `ApiClient` a decodificar
/// binarios grandes.
class BadRequestPayloadException extends BadRequestException {
  BadRequestPayloadException(super.message, this.payload);

  final Map<String, dynamic> payload;

  @override
  String toString() => '$message payload=${payload.keys.toList()}';
}

/// Excepción para recursos no encontrados (404).
class NotFoundException extends AppException {
  NotFoundException([
    super.message = 'El recurso solicitado no fue encontrado.',
  ]) : super(code: 404);
}

/// Excepción para conflictos de datos u otros errores no clasificados
/// (409 y demás casos no cubiertos por los tipos anteriores).
class UnexpectedAppException extends AppException {
  UnexpectedAppException(super.message, {super.code});
}
