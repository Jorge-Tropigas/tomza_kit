import 'package:flutter/material.dart';

import 'package:tomza_kit/core/network/network_exceptions.dart';

/// Shows a modal dialog when the provided [error] indicates an unauthorized
/// condition (session invalid / logged in elsewhere). If the user accepts,
/// `onLogout` is executed to let the host app clear session and navigate.
Future<bool> handleUnauthorizedFailure(
  BuildContext context,
  Object error,
  VoidCallback onLogout,
) async {
  try {
    bool isUnauthorized = false;

    if (error is UnauthorizedException) {
      isUnauthorized = true;
    } else if (error is Exception) {
      final msg = error.toString().toLowerCase();
      if (msg.contains('unauthorized') ||
          msg.contains('no autorizado') ||
          msg.contains('401')) {
        isUnauthorized = true;
      }
    } else if (error is String) {
      final msg = error.toLowerCase();
      if (msg.contains('unauthorized') ||
          msg.contains('no autorizado') ||
          msg.contains('401')) {
        isUnauthorized = true;
      }
    }

    if (!isUnauthorized) return false;

    // Mostrar diálogo informando inicio de sesión en otro dispositivo
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return AlertDialog(
          title: const Text('Sesión inválida'),
          content: const Text(
            'Se detectó que su cuenta inició sesión en otro dispositivo. Debe volver a iniciar sesión.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(c).pop();
                onLogout();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );

    return true;
  } catch (_) {
    return false;
  }
}
