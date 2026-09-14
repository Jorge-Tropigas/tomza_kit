import 'dart:developer' as dev;
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:tomza_kit/utils/notifier.dart';

/// Firma para reportar un evento de rendimiento de red hacia el proveedor
/// de analítica que use la app consumidora (Firebase Analytics, etc.).
/// tomza_kit no depende de ningún paquete de analítica en particular.
typedef ConnectivityAnalyticsLogger =
    void Function(String eventName, Map<String, Object?> parameters);

/// ConnectivityHandler: verificación reutilizable de calidad de conexión.
///
/// Es agnóstico a la app que lo consume: el endpoint de fallback, los
/// umbrales de latencia, el ambiente reportado y el destino de los eventos
/// de analítica se configuran desde la app mediante [configure], típicamente
/// junto a la inicialización de `EnvConfig`.
class ConnectivityHandler {
  ConnectivityHandler._();

  static Uri _fallbackUri = Uri.parse(
    'https://clients3.google.com/generate_204',
  );
  static Duration _fallbackTimeout = const Duration(seconds: 5);
  static int _slowLatencyThresholdMs = 1200; // Umbral típico de latencia 2G/3G
  static String _environment = 'unknown';
  static ConnectivityAnalyticsLogger? _analyticsLogger;
  static bool _showSlowConnectionWarning = true;

  /// Configura el comportamiento global de [ConnectivityHandler].
  ///
  /// Debe llamarse una sola vez al iniciar la app, antes de la primera
  /// llamada a [hasExcellentSignal].
  ///
  /// - [fallbackUri]: endpoint usado para medir latencia real (por defecto
  ///   `https://clients3.google.com/generate_204`).
  /// - [fallbackTimeout]: tiempo máximo de espera para esa verificación.
  /// - [slowLatencyThresholdMs]: latencia (ms) a partir de la cual se
  ///   considera la conexión "lenta".
  /// - [environment]: valor reportado en el parámetro `environment` del
  ///   evento de analítica (por ejemplo el flavor de la app).
  /// - [analyticsLogger]: callback invocado con cada evento
  ///   `network_performance_check`. Si es `null`, no se reporta analítica.
  /// - [showSlowConnectionWarning]: si es `true`, muestra un aviso al
  ///   usuario (vía `showInfo`) cuando la conexión es lenta.
  static void configure({
    Uri? fallbackUri,
    Duration? fallbackTimeout,
    int? slowLatencyThresholdMs,
    String? environment,
    ConnectivityAnalyticsLogger? analyticsLogger,
    bool showSlowConnectionWarning = true,
  }) {
    if (fallbackUri != null) _fallbackUri = fallbackUri;
    if (fallbackTimeout != null) _fallbackTimeout = fallbackTimeout;
    if (slowLatencyThresholdMs != null) {
      _slowLatencyThresholdMs = slowLatencyThresholdMs;
    }
    if (environment != null) _environment = environment;
    _analyticsLogger = analyticsLogger;
    _showSlowConnectionWarning = showSlowConnectionWarning;
  }

  static Future<bool> hasExcellentSignal() async {
    final List<ConnectivityResult> connectivity = await Connectivity()
        .checkConnectivity();

    if (connectivity.isEmpty ||
        connectivity.every((r) => r == ConnectivityResult.none)) {
      dev.log('[ConnectivityHandler] Sin conexión de red detectada');

      _logEvent({
        'network_type': 'none',
        'is_excellent_signal': 0,
        'throughput_mbps': 0.0,
      });
      return false;
    }

    final String networkType = connectivity.contains(ConnectivityResult.wifi)
        ? 'wifi'
        : 'mobile_data';

    // Perform a quick ping to measure actual RTT latency
    final stopwatch = Stopwatch()..start();
    final bool hasInternet = await _checkFallbackInternet();
    stopwatch.stop();

    final int latencyMs = stopwatch.elapsedMilliseconds;

    if (!hasInternet) {
      dev.log(
        '[ConnectivityHandler] Sin conexión real a internet detectada ($networkType).',
      );
      return false;
    }

    final bool isSlow = latencyMs > _slowLatencyThresholdMs;

    if (isSlow) {
      dev.log(
        '[ConnectivityHandler] Conexión lenta detectada ($networkType). '
        'Latencia: ${latencyMs}ms. Mostrando advertencia.',
      );
      if (_showSlowConnectionWarning) {
        showInfo('Conexión lenta detectada. El proceso podría tardar más.');
      }
    } else {
      dev.log(
        '[ConnectivityHandler] Conexión rápida activa ($networkType). '
        'Latencia: ${latencyMs}ms. Permitiendo continuar.',
      );
    }

    _logEvent({
      'network_type': networkType,
      'is_excellent_signal': isSlow ? 0 : 1,
      'throughput_mbps': -1.0,
      'latency_ms': latencyMs,
    });

    return true;
  }

  static void _logEvent(Map<String, Object?> parameters) {
    final logger = _analyticsLogger;
    if (logger == null) return;
    logger('network_performance_check', {
      ...parameters,
      'environment': _environment,
    });
  }

  static Future<bool> _checkFallbackInternet() async {
    final HttpClient client = HttpClient()
      ..connectionTimeout = _fallbackTimeout;
    try {
      final HttpClientRequest request = await client
          .getUrl(_fallbackUri)
          .timeout(_fallbackTimeout);
      final HttpClientResponse response = await request.close().timeout(
        _fallbackTimeout,
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      dev.log('[ConnectivityHandler] Fallo al verificar internet: $e');
      return false;
    } finally {
      client.close(force: true);
    }
  }
}
