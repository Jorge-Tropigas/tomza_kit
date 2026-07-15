// api_client.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'env_config.dart';
import 'network_exceptions.dart';
import 'network_client.dart';
import '../service_locator.dart';

typedef Json = Map<String, dynamic>;

class ApiClient {
  ApiClient._();

  // ---------------------------------------------------------------------------
  // Configuración / inyección
  // ---------------------------------------------------------------------------
  static Dio? _dio;

  /// Handler opcional para manejar 401 centralizadamente (refresh/logout).
  static Future<bool> Function(Object error)? unauthorizedHandler;

  /// Callbacks opcionales para integrarte con tu store (persistir/leer token).
  static String? Function()? _externalTokenValueProvider;
  static String? Function()? _externalTokenHeaderNameProvider;
  static Future<void> Function(String token)? _externalTokenValueSaver;
  static Future<void> Function(String? headerName)?
  _externalTokenHeaderNameSaver;

  /// Fallback nativo Android (no depende de EnvConfig).
  static bool _nativeFallbackEnabled = false;
  static String? _nativeChannelName;

  /// Estrategia de inyección por defecto cuando no se conoce el nombre de header.
  static String _defaultAuthHeaderName = 'Authorization';
  static bool _defaultPrependBearer = true;

  /// Estado interno (por si no registras providers/savers externos).
  static final _TokenState _token = _TokenState();

  static void registerUnauthorizedHandler(
    Future<bool> Function(Object error)? handler,
  ) {
    unauthorizedHandler = handler;
  }

  /// Registra acceso externo a token/encabezado (ej. SecureStorage).
  static void registerTokenAccess({
    String? Function()? getTokenValue,
    String? Function()? getTokenHeaderName,
    Future<void> Function(String token)? saveTokenValue,
    Future<void> Function(String? headerName)? saveTokenHeaderName,
  }) {
    _externalTokenValueProvider = getTokenValue;
    _externalTokenHeaderNameProvider = getTokenHeaderName;
    _externalTokenValueSaver = saveTokenValue;
    _externalTokenHeaderNameSaver = saveTokenHeaderName;
  }

  /// Configura cómo inyectar el token cuando no conocemos el nombre de header.
  /// Por defecto: header "Authorization" y se antepone "Bearer " si no está.
  static void configureAuthInjection({
    String defaultHeaderName = 'Authorization',
    bool prependBearerIfMissing = true,
  }) {
    _defaultAuthHeaderName = defaultHeaderName;
    _defaultPrependBearer = prependBearerIfMissing;
  }

  /// Activa/desactiva fallback nativo Android y define el canal.
  static void configureNativeFallback({
    required bool enable,
    String? channelName,
  }) {
    _nativeFallbackEnabled = enable;
    _nativeChannelName = channelName;
    if (enable && (channelName == null || channelName.trim().isEmpty)) {
      throw ArgumentError(
        'Para habilitar el fallback nativo debes proporcionar un native channel name.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Cliente Dio
  // ---------------------------------------------------------------------------
  static Dio get _client {
    final cfg = EnvConfig.instance;
    if (_dio != null) return _dio!;

    final options = BaseOptions(
      baseUrl: cfg.baseUrl,
      connectTimeout: cfg.connectTimeout,
      receiveTimeout: cfg.receiveTimeout,
      headers: {...cfg.defaultHeaders, 'Content-Type': 'application/json'},
      responseType: ResponseType.json,
    );

    final dio = Dio(options);

    // TLS flexible en dev / insecure
    dio.httpClientAdapter = IOHttpClientAdapter()
      ..createHttpClient = () {
        final client = HttpClient();
        if (cfg.isDevelopment || cfg.insecureSsl) {
          client.badCertificateCallback = (cert, host, port) => true;
        }
        return client;
      };

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Inyectar token si existe (nullable-aware)
          final injected = _maybeInjectAuthHeader(options.headers);
          if (cfg.isDevelopment) {
            debugPrint(
              '[ApiClient][REQ] injectAuth=$injected headerName=$_currentHeaderName',
            );
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          // Captura de token si vino en headers/body
          try {
            final hdrs = _normalizeHeaders(response.headers);
            ApiClient._tryCaptureTokenFromHeaders(hdrs);
            final data = response.data;
            ApiClient._tryCaptureTokenFromBody(data);
          } catch (_) {}
          handler.next(response);
        },
        onError: (e, handler) async {
          try {
            if (e.response?.statusCode == 401 && unauthorizedHandler != null) {
              await unauthorizedHandler!(e);
            }
          } catch (_) {}
          handler.next(e);
        },
      ),
    );

    if (cfg.isDevelopment) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }

    _dio = dio;
    return dio;
  }

  /// Si cambias entorno/baseUrl/headers globales, llama a reset().
  static void reset() {
    _dio = null;
  }

  /// Convierte un [DioException] al [AppException] tipado correspondiente
  /// (según código de estado, con mensajes por defecto en español). Útil para
  /// apps consumidoras que mantienen su propia instancia de `Dio` fuera de
  /// [ApiClient] y quieren el mismo mapeo de errores sin duplicarlo.
  static AppException mapDioException(DioException error) => _mapDioError(error);

  // ---------------------------------------------------------------------------
  // Redirecciones Estáticas para Retrocompatibilidad
  // ---------------------------------------------------------------------------
  static Future<Json> get(
    String endpoint, {
    Json? data,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
  }) => TomzaKit.network.get(
    endpoint,
    data: data,
    query: query,
    headers: headers,
    acceptableStatusCodes: acceptableStatusCodes,
  );

  static Future<Json> post(
    String endpoint, {
    Object? body,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
    bool enableAndroidRenegotiationFallback = true,
  }) => TomzaKit.network.post(
    endpoint,
    body: body,
    query: query,
    headers: headers,
    acceptableStatusCodes: acceptableStatusCodes,
    enableAndroidRenegotiationFallback: enableAndroidRenegotiationFallback,
  );

  static Future<Json> postListJson(
    String endpoint, {
    required List<dynamic> listBody,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
    bool enableAndroidRenegotiationFallback = true,
  }) => TomzaKit.network.postListJson(
    endpoint,
    listBody: listBody,
    query: query,
    headers: headers,
    acceptableStatusCodes: acceptableStatusCodes,
    enableAndroidRenegotiationFallback: enableAndroidRenegotiationFallback,
  );

  static Future<Json> put(
    String endpoint, {
    Object? body,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
  }) => TomzaKit.network.put(
    endpoint,
    body: body,
    query: query,
    headers: headers,
    acceptableStatusCodes: acceptableStatusCodes,
  );

  static Future<Json> deleteJson(
    String endpoint, {
    Object? body,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200, 204},
  }) => TomzaKit.network.deleteJson(
    endpoint,
    body: body,
    query: query,
    headers: headers,
    acceptableStatusCodes: acceptableStatusCodes,
  );

  // ---------------------------------------------------------------------------
  // Implementación Interna de Métodos de Red (Dio)
  // ---------------------------------------------------------------------------
  static Future<Json> _getImpl(
    String endpoint, {
    Json? data,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
  }) async {
    try {
      final req = _resolveRequest(endpoint);
      final resp = await _client.get<dynamic>(
        req.pathForDio,
        data: data,
        queryParameters: query,
        options: _mergeHeaders(headers),
      );
      _ensureAcceptable(resp, acceptableStatusCodes);
      // Si el cuerpo viene vacío pero el estatus es exitoso, retorna {}.
      final respData = resp.data;
      if (respData == null || (respData is String && respData.trim().isEmpty)) {
        return <String, dynamic>{};
      }
      return _asJson(respData, resp);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static Future<Json> _postImpl(
    String endpoint, {
    Object? body,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
    bool enableAndroidRenegotiationFallback = true,
  }) async {
    final req = _resolveRequest(endpoint);
    try {
      final resp = await _client.post<dynamic>(
        req.pathForDio,
        data: body,
        queryParameters: query,
        options: _mergeHeaders(headers),
      );
      _ensureAcceptable(resp, acceptableStatusCodes);
      final respData = resp.data;
      if (respData == null || (respData is String && respData.trim().isEmpty)) {
        return <String, dynamic>{};
      }
      return _asJson(respData, resp);
    } on DioException catch (e) {
      if (_shouldDoNativeFallback(e) &&
          _nativeFallbackEnabled &&
          enableAndroidRenegotiationFallback &&
          Platform.isAndroid) {
        final raw = await _nativePost(
          fullUrl: req.fullUrlWithQuery(query),
          headers: _finalHeaders(headers),
          body: body,
        );
        return raw;
      }
      throw _mapDioError(e);
    }
  }

  static Future<Json> _postListJsonImpl(
    String endpoint, {
    required List<dynamic> listBody,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
    bool enableAndroidRenegotiationFallback = true,
  }) {
    return _postImpl(
      endpoint,
      body: listBody,
      query: query,
      headers: headers,
      acceptableStatusCodes: acceptableStatusCodes,
      enableAndroidRenegotiationFallback: enableAndroidRenegotiationFallback,
    );
  }

  static Future<Json> _putImpl(
    String endpoint, {
    Object? body,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
  }) async {
    try {
      final req = _resolveRequest(endpoint);
      final resp = await _client.put<dynamic>(
        req.pathForDio,
        data: body,
        queryParameters: query,
        options: _mergeHeaders(headers),
      );
      _ensureAcceptable(resp, acceptableStatusCodes);
      final respData = resp.data;
      if (respData == null || (respData is String && respData.trim().isEmpty)) {
        return <String, dynamic>{};
      }
      return _asJson(respData, resp);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static Future<Json> _deleteJsonImpl(
    String endpoint, {
    Object? body,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200, 204},
  }) async {
    try {
      final req = _resolveRequest(endpoint);
      final resp = await _client.delete<dynamic>(
        req.pathForDio,
        data: body,
        queryParameters: query,
        options: _mergeHeaders(headers),
      );
      _ensureAcceptable(resp, acceptableStatusCodes);
      if ((resp.statusCode ?? 0) == 204 ||
          resp.data == null ||
          (resp.data is String && (resp.data as String).trim().isEmpty)) {
        return <String, dynamic>{};
      }
      return _asJson(resp.data, resp);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Token: captura e inyección (nullable-aware, conserva el nombre del header)
  // ---------------------------------------------------------------------------

  static bool _maybeInjectAuthHeader(Json headersOut) {
    // Si el caller ya puso Authorization / x-token / etc., no inyectamos.
    if (_containsAuthLikeHeader(headersOut)) return false;

    // Token actual (externo o interno)
    final tokenValue = _currentTokenValue;
    if (tokenValue == null || tokenValue.isEmpty) return false;

    final headerName = _currentHeaderName ?? _defaultAuthHeaderName;

    // Si vamos a usar Authorization y no tiene "Bearer " y queremos anteponerlo.
    final value =
        (headerName.toLowerCase() == 'authorization' &&
            _defaultPrependBearer &&
            !tokenValue.toLowerCase().startsWith('bearer '))
        ? 'Bearer $tokenValue'
        : tokenValue;

    headersOut[headerName] = value;
    return true;
  }

  static bool _containsAuthLikeHeader(Json headers) {
    const cands = [
      'authorization',
      'x-token',
      'x-auth-token',
      'token',
      'x-api-key',
    ];
    final keys = headers.keys.map((e) => e.toString().toLowerCase());
    return keys.any(cands.contains);
  }

  static String? get _currentTokenValue =>
      _externalTokenValueProvider?.call() ?? _token.value;

  static String? get _currentHeaderName =>
      _externalTokenHeaderNameProvider?.call() ?? _token.headerName;

  static Future<void> _saveToken(String value, {String? headerName}) async {
    _token.value = value;
    if (headerName != null) _token.headerName = headerName;
    if (_externalTokenValueSaver != null) {
      await _externalTokenValueSaver!(value);
    }
    if (_externalTokenHeaderNameSaver != null) {
      await _externalTokenHeaderNameSaver!(headerName ?? _token.headerName);
    }
  }

  static void _tryCaptureTokenFromHeaders(Map<String, List<String>> headers) {
    const candidates = <String>[
      'authorization',
      'Authorization',
      'x-token',
      'X-Token',
      'x-auth-token',
      'X-Auth-Token',
      'token',
      'Token',
      'set-cookie', // como último recurso
      'Set-Cookie',
    ];

    for (final key in candidates) {
      final values = headers[key];
      if (values == null || values.isEmpty) continue;
      final raw = values.first.trim();
      if (raw.isEmpty) continue;

      if (key.toLowerCase() == 'set-cookie') {
        // si viene en cookie=token..., no tenemos headerName válido para reenvío
        // extraer el token y usaremos el defaultHeaderName para inyectar.
        final token = _extractTokenFromCookie(raw);
        if (token != null && token.isNotEmpty) {
          _saveToken(token, headerName: _defaultAuthHeaderName);
        }
        return;
      }

      // Para encabezados explícitos (Authorization/X-Auth-Token/etc.), guardamos el mismo nombre
      _saveToken(raw, headerName: key);
      return;
    }
  }

  static String? _extractTokenFromCookie(String cookie) {
    // busca token=...;
    final parts = cookie.split(';');
    for (final p in parts) {
      final kv = p.split('=');
      if (kv.length == 2 && kv[0].trim().toLowerCase() == 'token') {
        return kv[1].trim();
      }
    }
    return null;
  }

  static void _tryCaptureTokenFromBody(Json body) {
    const bodyKeys = [
      'token',
      'access_token',
      'accessToken',
      'jwt',
      'authorization',
    ];
    for (final k in bodyKeys) {
      if (!body.containsKey(k)) continue;
      final v = body[k];
      if (v is String && v.isNotEmpty) {
        // al venir desde body no sabemos headerName → usamos el default
        _saveToken(v, headerName: _defaultAuthHeaderName);
        return;
      }
      for (final k2 in bodyKeys) {
        final vv = v[k2];
        if (vv is String && vv.isNotEmpty) {
          _saveToken(vv, headerName: _defaultAuthHeaderName);
          return;
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers comunes
  // ---------------------------------------------------------------------------

  static Json _asJson(dynamic data, Response resp) {
    try {
      if (data == null) {
        throw BadRequestException(
          'Respuesta vacía (status=${resp.statusCode})',
        );
      }
      return data;
    } catch (e) {
      if (e is AppException) rethrow;
      throw BadRequestException(
        'No se pudo parsear la respuesta a Map<String,dynamic>: $e',
      );
    }
  }

  static Options? _mergeHeaders(Map<String, String>? headers) {
    if (headers == null || headers.isEmpty) return null;
    final merged = {
      ..._client.options.headers.map((k, v) => MapEntry(k.toString(), v)),
      ...headers,
    };
    return Options(headers: merged);
  }

  static Map<String, String> _finalHeaders(Map<String, String>? headers) {
    final merged = <String, String>{};
    _client.options.headers.forEach((k, v) {
      if (v != null) merged[k.toString()] = v.toString();
    });
    if (headers != null) merged.addAll(headers);
    merged.putIfAbsent('Content-Type', () => 'application/json');

    // Inyectar auth si procede
    _maybeInjectAuthHeader(merged);
    return merged;
  }

  static void _ensureAcceptable<T>(
    Response<T> resp,
    Set<int> acceptableStatusCodes,
  ) {
    final sc = resp.statusCode ?? 0;
    if (!acceptableStatusCodes.contains(sc)) {
      final text = _extractSnippet(resp.data);
      throw UnexpectedAppException(
        'HTTP ${resp.requestOptions.method} ${_composeUrl(resp.requestOptions)} '
        'status=$sc body=${text ?? "<vacío>"}',
        code: sc,
      );
    }
  }

  static bool _shouldDoNativeFallback(DioException e) {
    final msg = (e.message ?? '').toUpperCase();
    return msg.contains('NO_RENEGOTIATION') || msg.contains('RENEGOTIATION');
  }

  static Future<Json> _nativePost({
    required String fullUrl,
    required Map<String, String> headers,
    Object? body,
  }) async {
    if (!_nativeFallbackEnabled ||
        _nativeChannelName == null ||
        _nativeChannelName!.trim().isEmpty) {
      throw NetworkException(
        'Fallback nativo está deshabilitado o el channel no fue configurado.',
      );
    }

    final String payload;
    if (body == null) {
      payload = '{}';
    } else if (body is String) {
      payload = body;
    } else {
      payload = jsonEncode(body);
    }

    final channel = MethodChannel(_nativeChannelName!);
    final result = await channel.invokeMethod<String>(
      'nativePost',
      <String, dynamic>{'url': fullUrl, 'headers': headers, 'body': payload},
    );

    if (result == null || result.isEmpty) {
      throw NetworkException('Respuesta nativa vacía');
    }
    final decoded = jsonDecode(result);
    return decoded;
  }
}

// -----------------------------------------------------------------------------
// Utilidades compartidas
// -----------------------------------------------------------------------------

class _ResolvedRequest {
  _ResolvedRequest(this._endpoint);
  final String _endpoint;

  bool get isAbsolute =>
      _endpoint.startsWith('http://') || _endpoint.startsWith('https://');

  String get pathForDio {
    if (!isAbsolute) return _cleanRelative(_endpoint);
    try {
      final uri = Uri.parse(_endpoint);
      return _cleanRelative(uri.path);
    } catch (_) {
      return _endpoint;
    }
  }

  String fullUrlWithQuery(Json? query) {
    if (isAbsolute) {
      final uri = Uri.parse(_endpoint);
      return uri
          .replace(
            queryParameters: {
              ...uri.queryParameters,
              if (query != null)
                ...query.map((k, v) => MapEntry(k, v?.toString() ?? '')),
            },
          )
          .toString();
    }
    final base = EnvConfig.instance.baseUrl;
    final baseClean = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final path = _cleanRelative(_endpoint);
    final uri = Uri.parse('$baseClean/$path').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v?.toString() ?? '')),
    );
    return uri.toString();
  }

  String _cleanRelative(String input) =>
      input.startsWith('/') ? input.substring(1) : input;
}

_ResolvedRequest _resolveRequest(String endpoint) => _ResolvedRequest(endpoint);

String _composeUrl(RequestOptions o) {
  final b = o.baseUrl;
  final p = o.path;
  if (p.startsWith('http')) return p;
  if (b.endsWith('/') && p.startsWith('/')) return b + p.substring(1);
  if (!b.endsWith('/') && !p.startsWith('/')) return '$b/$p';
  return '$b$p';
}

String? _extractSnippet(dynamic data, {int max = 600}) {
  if (data == null) return null;
  try {
    if (data is String) {
      return data.length > max
          ? '${data.substring(0, max)}...<truncated>'
          : data;
    }
    final s = jsonEncode(data);
    return s.length > max ? '${s.substring(0, max)}...<truncated>' : s;
  } catch (_) {
    final s = data.toString();
    return s.length > max ? '${s.substring(0, max)}...<truncated>' : s;
  }
}

Map<String, List<String>> _normalizeHeaders(Headers hdrs) {
  final out = <String, List<String>>{};
  hdrs.map.forEach((k, v) {
    out[k] = v.map((e) => e.toString()).toList();
  });
  return out;
}

// -----------------------------------------------------------------------------
// Token state interno
// -----------------------------------------------------------------------------
class _TokenState {
  String? value; // puede ser null → no se inyecta
  String? headerName; // si null, se usa _defaultAuthHeaderName
}

// -----------------------------------------------------------------------------
// Mapeo de errores
// -----------------------------------------------------------------------------

/// Mensaje por defecto en español para un código de estado HTTP dado, usado
/// cuando el servidor no envía un mensaje propio o cuando el texto disponible
/// es en realidad texto interno de Dio (no apto para mostrar al usuario).
String _spanishMessageForCode(int code) {
  switch (code) {
    case 400:
      return 'La solicitud contiene datos inválidos.';
    case 401:
      return 'Sesión expirada o credenciales inválidas. Por favor, inicie sesión nuevamente.';
    case 403:
      return 'No tiene permisos para realizar esta acción.';
    case 404:
      return 'El recurso solicitado no fue encontrado.';
    case 408:
      return 'Tiempo de espera agotado. Intente nuevamente.';
    case 409:
      return 'Conflicto con el estado actual del recurso.';
    case 422:
      return 'Los datos enviados no son válidos.';
    case 500:
      return 'Error interno del servidor. Intente más tarde.';
    case 502:
      return 'El servidor no está disponible en este momento.';
    case 503:
      return 'Servicio temporalmente no disponible. Intente más tarde.';
    default:
      if (code >= 500) return 'Error del servidor ($code). Intente más tarde.';
      if (code >= 400) {
        return 'Error en la solicitud ($code). Verifique los datos.';
      }
      return 'Error de conexión ($code).';
  }
}

bool _isDioInternalMessage(String message) {
  return message.contains('validateStatus') ||
      message.contains('status code of') ||
      message.contains('DioException') ||
      message.contains('RequestOptions') ||
      message.contains('Http status error');
}

/// Intenta extraer un mensaje legible del cuerpo de una respuesta de error.
String? _extractServerMessage(dynamic data) {
  if (data is Map) {
    if (data.containsKey('message')) return data['message']?.toString();
    if (data.containsKey('mensaje')) return data['mensaje']?.toString();
    if (data.containsKey('errors')) return data['errors'].toString();
    return data.toString();
  }
  if (data is String && data.isNotEmpty) return data;
  return null;
}

/// El payload JSON de la respuesta, si viene como Map o como String
/// serializado, para exponerlo en [BadRequestPayloadException].
Json? _extractPayloadMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is String) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
  }
  return null;
}

AppException _mapDioError(DioException e) {
  final int? status = e.response?.statusCode;
  final String? serverMsg = _extractServerMessage(e.response?.data);
  String message = serverMsg ?? e.message ?? 'Error de conexión';

  if (_isDioInternalMessage(message) && status != null) {
    message = _spanishMessageForCode(status);
  }

  if (EnvConfig.instance.isDevelopment) {
    debugPrint(
      '[ApiClient][_mapDioError] ${e.requestOptions.method} '
      '${_composeUrl(e.requestOptions)} status=${status ?? "n/a"} '
      'type=${e.type} message=$message',
    );
  }

  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    return NetworkException(
      'No hay mucha señal de internet. Tiempo de conexión agotado.',
    );
  }
  if (e.type == DioExceptionType.connectionError) {
    return NetworkException(
      'No hay mucha señal de internet. Verifique su conexión.',
    );
  }

  switch (status) {
    case 400:
    case 422:
      final payload = _extractPayloadMap(e.response?.data);
      if (payload != null) {
        return BadRequestPayloadException(
          _extractServerMessage(payload) ?? _spanishMessageForCode(status!),
          payload,
        );
      }
      return BadRequestException(message, status!);
    case 401:
      return UnauthorizedException(
        _isDioInternalMessage(message) ? _spanishMessageForCode(401) : message,
      );
    case 403:
      return ForbiddenException(
        _isDioInternalMessage(message) ? _spanishMessageForCode(403) : message,
      );
    case 404:
      return NotFoundException(
        _isDioInternalMessage(message) ? _spanishMessageForCode(404) : message,
      );
    case 408:
      return NetworkException(_spanishMessageForCode(408));
    case 409:
      return UnexpectedAppException(message, code: 409);
  }

  if (status != null && status >= 500) {
    return ServerException(
      _isDioInternalMessage(message) ? _spanishMessageForCode(status) : message,
      code: status,
    );
  }
  if (status != null) {
    return UnexpectedAppException(message, code: status);
  }
  return NetworkException(
    _isDioInternalMessage(message) ? 'Error de red. Verifique su conexión.' : message,
  );
}

// -----------------------------------------------------------------------------
// Cliente de Red Concreto (Dio)
// -----------------------------------------------------------------------------
class DioNetworkClient implements NetworkClient {
  const DioNetworkClient();

  @override
  Future<Json> get(
    String endpoint, {
    Json? data,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
  }) {
    return ApiClient._getImpl(
      endpoint,
      data: data,
      query: query,
      headers: headers,
      acceptableStatusCodes: acceptableStatusCodes,
    );
  }

  @override
  Future<Json> post(
    String endpoint, {
    Object? body,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
    bool enableAndroidRenegotiationFallback = true,
  }) {
    return ApiClient._postImpl(
      endpoint,
      body: body,
      query: query,
      headers: headers,
      acceptableStatusCodes: acceptableStatusCodes,
      enableAndroidRenegotiationFallback: enableAndroidRenegotiationFallback,
    );
  }

  @override
  Future<Json> postListJson(
    String endpoint, {
    required List<dynamic> listBody,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
    bool enableAndroidRenegotiationFallback = true,
  }) {
    return ApiClient._postListJsonImpl(
      endpoint,
      listBody: listBody,
      query: query,
      headers: headers,
      acceptableStatusCodes: acceptableStatusCodes,
      enableAndroidRenegotiationFallback: enableAndroidRenegotiationFallback,
    );
  }

  @override
  Future<Json> put(
    String endpoint, {
    Object? body,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
  }) {
    return ApiClient._putImpl(
      endpoint,
      body: body,
      query: query,
      headers: headers,
      acceptableStatusCodes: acceptableStatusCodes,
    );
  }

  @override
  Future<Json> deleteJson(
    String endpoint, {
    Object? body,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200, 204},
  }) {
    return ApiClient._deleteJsonImpl(
      endpoint,
      body: body,
      query: query,
      headers: headers,
      acceptableStatusCodes: acceptableStatusCodes,
    );
  }
}
