// api_client.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'env_config.dart';
import 'network_exceptions.dart';

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
            _captureTokenFromHeaders(hdrs);
            final data = response.data;
            if (data is Map<String, dynamic>) {
              _captureTokenFromBody(data);
            } else if (data is String) {
              try {
                final parsed = jsonDecode(data);
                if (parsed is Map<String, dynamic>) {
                  _captureTokenFromBody(parsed);
                }
              } catch (_) {}
            }
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

  // ---------------------------------------------------------------------------
  // Métodos HTTP -> SIEMPRE Map<String, dynamic>
  // ---------------------------------------------------------------------------

  static Future<Json> getJson(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
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

  static Future<Json> postJson(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? query,
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

  static Future<Json> postListJson(
    String endpoint, {
    required List<dynamic> listBody,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
    bool enableAndroidRenegotiationFallback = true,
  }) {
    return postJson(
      endpoint,
      body: listBody,
      query: query,
      headers: headers,
      acceptableStatusCodes: acceptableStatusCodes,
      enableAndroidRenegotiationFallback: enableAndroidRenegotiationFallback,
    );
  }

  static Future<Json> putJson(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? query,
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

  static Future<Json> deleteJson(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? query,
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

  static bool _maybeInjectAuthHeader(Map<String, dynamic> headersOut) {
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

  static bool _containsAuthLikeHeader(Map<String, dynamic> headers) {
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

  static void _captureTokenFromHeaders(Map<String, List<String>> headers) {
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

  static void _captureTokenFromBody(Map<String, dynamic> body) {
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
      if (v is Map<String, dynamic>) {
        for (final k2 in bodyKeys) {
          final vv = v[k2];
          if (vv is String && vv.isNotEmpty) {
            _saveToken(vv, headerName: _defaultAuthHeaderName);
            return;
          }
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
        throw NetworkException.badRequest(
          'Respuesta vacía (status=${resp.statusCode})',
        );
      }
      if (data is Map<String, dynamic>) return data;

      if (data is String) {
        final parsed = jsonDecode(data);
        if (parsed is Map<String, dynamic>) return parsed;
        throw NetworkException.badRequest(
          'Se esperaba objeto JSON. String decodifica a ${parsed.runtimeType}',
        );
      }

      if (data is Map) {
        return Map<String, dynamic>.from(
          data.map((k, v) => MapEntry(k.toString(), v)),
        );
      }

      throw NetworkException.badRequest(
        'Se esperaba objeto JSON (Map). Recibido ${data.runtimeType}',
      );
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException.badRequest(
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
      throw NetworkException.badRequest(
        'HTTP ${resp.requestOptions.method} ${_composeUrl(resp.requestOptions)} '
        'status=$sc body=${text ?? "<vacío>"}',
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
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is String) return jsonDecode(decoded) as Map<String, dynamic>;
    return Map<String, dynamic>.from(decoded as Map);
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

  String fullUrlWithQuery(Map<String, dynamic>? query) {
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
NetworkException _mapDioError(DioException e) {
  final status = e.response?.statusCode;
  final method = e.requestOptions.method;
  final url = _composeUrl(e.requestOptions);
  final reason = e.message ?? '';
  final serverMsg = _extractSnippet(e.response?.data);

  final msg =
      '[$method $url] '
      'status=${status ?? "n/a"} '
      'type=${e.type} '
      '${reason.isNotEmpty ? "reason=$reason " : ""}'
      '${serverMsg != null ? "server=${serverMsg.replaceAll("\n", " ")}" : ""}';

  switch (status) {
    case 400:
      return NetworkException.badRequest(msg);
    case 401:
      return NetworkException.unauthorized();
    case 403:
      return NetworkException.forbidden();
    case 404:
      return NetworkException.notFound();
    case 408:
      return NetworkException.timeout(msg);
    case 500:
      return NetworkException.server(msg);
  }

  if (e.type == DioExceptionType.connectionTimeout) {
    return NetworkException.timeout('Connection timeout: $msg');
  }
  if (e.type == DioExceptionType.sendTimeout) {
    return NetworkException.timeout('Send timeout: $msg');
  }
  if (e.type == DioExceptionType.receiveTimeout) {
    return NetworkException.timeout('Receive timeout: $msg');
  }
  if (e.type == DioExceptionType.badCertificate) {
    return NetworkException('Bad certificate: $msg');
  }
  if (e.type == DioExceptionType.connectionError) {
    return NetworkException('Connection error: $msg');
  }
  if (e.type == DioExceptionType.cancel) {
    return NetworkException('Request cancelled: $msg');
  }
  if (e.type == DioExceptionType.badResponse) {
    return NetworkException('Bad response: $msg');
  }
  return NetworkException('Error de red: $msg');
}
