import 'package:flutter/material.dart';

import 'package:tomza_kit/core/network/network_exceptions.dart';
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

  static void showException(AppException exception) {
    final String msg = _mapExceptionMessage(exception);
    final IconData icon = _mapExceptionIcon(exception);
    final Color color = _mapExceptionColor(exception);
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
      duration: const Duration(seconds: 5),
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

  static String _mapExceptionMessage(AppException e) {
    if (e is NetworkException) {
      return e.message.isNotEmpty ? e.message : 'Sin conexión a internet';
    }
    if (e is UnauthorizedException) {
      return e.message.isNotEmpty ? e.message : 'Sesión expirada';
    }
    if (e is ForbiddenException) {
      return e.message.isNotEmpty ? e.message : 'Acceso denegado';
    }
    if (e is BadRequestException) {
      return e.message.isNotEmpty ? e.message : 'Validación fallida';
    }
    if (e is NotFoundException) {
      return e.message.isNotEmpty ? e.message : 'Recurso no encontrado';
    }
    if (e is ServerException) {
      return e.message.isNotEmpty ? e.message : 'Error de servidor';
    }
    return e.message;
  }

  static IconData _mapExceptionIcon(AppException e) {
    if (e is NetworkException) return Icons.wifi_off_rounded;
    if (e is UnauthorizedException) return Icons.lock_outline;
    if (e is ForbiddenException) return Icons.block_rounded;
    if (e is NotFoundException) return Icons.search_off_rounded;
    if (e is BadRequestException) return Icons.rule_folder_outlined;
    if (e is ServerException) return Icons.dns_rounded;
    if (e is UnexpectedAppException) return Icons.warning_amber_rounded;
    return Icons.error_outline;
  }

  static Color _mapExceptionColor(AppException e) {
    if (e is BadRequestException) return Colors.amber.shade700;
    return errorColor;
  }
}

/// Extensión opcional (azúcar sintáctico). No usa [context] internamente.
extension ErrorNotifierContext on BuildContext {
  void showException(AppException e) => ErrorNotifier.showException(e);
  void showInfoMsg(String m) => ErrorNotifier.showInfo(m);
  void showSuccessMsg(String m) => ErrorNotifier.showSuccess(m);
  void showErrorMsg(String m) => ErrorNotifier.showError(m);
}
