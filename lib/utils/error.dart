import 'package:flutter/material.dart';

import 'package:tomza_kit/core/network/failures.dart';
import 'package:tomza_kit/utils/animated_snack_content.dart';

class ErrorNotifier {
  const ErrorNotifier._();

  static GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  static void Function(String message, IconData icon, Color color)?
  showCallback;

  /// Colores configurables (no dependen de Theme)
  static Color primaryColor = Colors.blue;
  static Color errorColor = Colors.red;
  static Color successColor = Colors.green;
  static Color infoColor = Colors.blue;

  static void initialize({
    GlobalKey<ScaffoldMessengerState>? messengerKey,
    void Function(String, IconData, Color)? callback,
    Color? primary,
    Color? error,
    Color? success,
    Color? info,
  }) {
    scaffoldMessengerKey = messengerKey ?? scaffoldMessengerKey;
    showCallback = callback ?? showCallback;

    if (primary != null) primaryColor = primary;
    if (error != null) errorColor = error;
    if (success != null) successColor = success;
    if (info != null) infoColor = info;
  }

  // ----------------- API pública -----------------

  static void showFailure(Failure failure) {
    final String msg = _mapFailureMessage(failure);
    final IconData icon = _mapFailureIcon(failure);
    final Color color = _mapFailureColor(failure);
    _show(msg, icon: icon, color: color);
  }

  static void showInfo(String message) {
    _show(message, icon: Icons.info_outline, color: infoColor);
  }

  static void showSuccess(String message) {
    _show(message, icon: Icons.check_circle, color: successColor);
  }

  static void showError(String message) {
    _show(message, icon: Icons.error_outline, color: errorColor);
  }

  // ----------------- Internos -----------------

  static void _show(
    String message, {
    required IconData icon,
    required Color color,
  }) {
    // Si hay callback personalizado, úsalo.
    if (showCallback != null) {
      showCallback!(message, icon, color);
      return;
    }

    final snack = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: color.withValues(alpha: 0.94),
      elevation: 5,
      content: AnimatedSnackContent(
        icon: icon,
        color: Colors.white,
        text: message,
      ),
      duration: const Duration(seconds: 3),
    );

    // Usa el ScaffoldMessenger global si está configurado.
    final messenger = scaffoldMessengerKey?.currentState;
    if (messenger != null) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(snack);
      return;
    }

    // Último recurso: log en consola (evita fallar silenciosamente).
    // ignore: avoid_print
    print('[TomzaKit] $message');
  }

  static String _mapFailureMessage(Failure f) {
    if (f is NetworkFailure) {
      return f.message.isNotEmpty ? f.message : 'Sin conexión a internet';
    }
    if (f is TimeoutFailure) return f.message;
    if (f is AuthFailure) {
      return f.message.isNotEmpty ? f.message : 'Sesión expirada';
    }
    if (f is AuthorizationFailure) {
      return f.message.isNotEmpty ? f.message : 'Acceso denegado';
    }
    if (f is ValidationFailure) {
      // Nota: en tu código original aquí decía "Recurso no encontrado".
      return f.message.isNotEmpty ? f.message : 'Validación fallida';
    }
    if (f is UnexpectedFailure) {
      // si lo tienes
      return f.message.isNotEmpty ? f.message : 'Recurso no encontrado';
    }
    if (f is UnexpectedFailure) return f.message;
    if (f is FormatFailure) return f.message;
    if (f is ServerFailure) {
      return f.message.isNotEmpty ? f.message : 'Error de servidor';
    }
    return f.message;
  }

  static IconData _mapFailureIcon(Failure f) {
    if (f is NetworkFailure) return Icons.wifi_off_rounded;
    if (f is TimeoutFailure) return Icons.timer_off_outlined;
    if (f is AuthFailure) return Icons.lock_outline;
    if (f is AuthorizationFailure) return Icons.block_rounded;
    if (f is UnexpectedFailure) return Icons.search_off_rounded; // si existe
    if (f is ValidationFailure) return Icons.rule_folder_outlined;
    if (f is FormatFailure) return Icons.description_outlined;
    if (f is ServerFailure) return Icons.dns_rounded;
    if (f is UnexpectedFailure) return Icons.warning_amber_rounded;
    return Icons.error_outline;
  }

  static Color _mapFailureColor(Failure f) {
    if (f is NetworkFailure) return errorColor;
    if (f is TimeoutFailure) return errorColor;
    if (f is AuthFailure) return errorColor;
    if (f is AuthorizationFailure) return errorColor;
    if (f is UnexpectedFailure) {
      return errorColor; // o primaryColor si prefieres
    }
    if (f is ValidationFailure) return Colors.amber.shade700;
    if (f is FormatFailure) return Colors.deepPurple;
    if (f is ServerFailure) return errorColor;
    if (f is UnexpectedFailure) return errorColor;
    return errorColor;
  }
}

/// Extensión opcional (azúcar sintáctico). No usa [context] internamente.
extension ErrorNotifierContext on BuildContext {
  void showFailure(Failure f) => ErrorNotifier.showFailure(f);
  void showInfoMsg(String m) => ErrorNotifier.showInfo(m);
  void showSuccessMsg(String m) => ErrorNotifier.showSuccess(m);
  void showErrorMsg(String m) => ErrorNotifier.showError(m);
}
