/// EnvConfig: configuración global de red para tomza_kit.
/// Debe inicializarse desde la app consumidora antes de primeras llamadas.
class EnvConfig {
  EnvConfig._internal({
    required this.baseUrl,
    required this.isDevelopment,
    required this.insecureSsl,
    required this.connectTimeout,
    required this.receiveTimeout,
    Map<String, String>? defaultHeaders,
    // --- NUEVO: configuración de fallback nativo (opcional) ---
    this.enableNativeFallback = false,
    this.nativeChannelName,
  }) : defaultHeaders = defaultHeaders ?? const {};

  static EnvConfig? _instance;
  static EnvConfig get instance {
    final inst = _instance;
    if (inst == null) {
      throw StateError(
        'EnvConfig no inicializado. Llama EnvConfig.initialize(...) antes.',
      );
    }
    return inst;
  }

  final String baseUrl;
  final bool isDevelopment;
  final bool insecureSsl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Map<String, String> defaultHeaders;

  // --- NUEVO: opciones para canal nativo Android (MethodChannel) ---
  /// Habilita el fallback nativo Android para errores SSL tipo NO_RENEGOTIATION.
  final bool enableNativeFallback;

  /// Nombre del canal nativo. Si `enableNativeFallback` es true, este valor
  /// DEBE venir configurado por la app. Ejemplo: 'com.miapp.core/native_http'.
  final String? nativeChannelName;

  static void initialize({
    required String baseUrl,
    bool isDevelopment = false,
    bool insecureSsl = false,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 15),
    Map<String, String>? defaultHeaders,
    // --- NUEVO: configuración de fallback nativo (opcional) ---
    bool enableNativeFallback = false,
    String? nativeChannelName,
  }) {
    _instance = EnvConfig._internal(
      baseUrl: baseUrl,
      isDevelopment: isDevelopment,
      insecureSsl: insecureSsl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      defaultHeaders: defaultHeaders,
      enableNativeFallback: enableNativeFallback,
      nativeChannelName: nativeChannelName,
    );
  }
}
