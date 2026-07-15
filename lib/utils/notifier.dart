import 'package:flutter/material.dart';

import 'package:tomza_kit/core/network/network_exceptions.dart';
import 'package:tomza_kit/utils/error.dart';

/// Top-level convenience functions so consumers can call
/// `showException`, `showInfo` and `showSuccess` directly without
/// referencing the `ErrorNotifier` class.
///
/// All functions accept an optional [BuildContext]. If `null`, the
/// library will try to use the configured `ErrorNotifier.scaffoldMessengerKey`
/// or `ErrorNotifier.showCallback` (see `ErrorNotifier.initialize`).
void showException(AppException exception) =>
    ErrorNotifier.showException(exception);

void showInfo(String message) => ErrorNotifier.showInfo(message);

void showSuccess(String message) => ErrorNotifier.showSuccess(message);

void showError(String message) => ErrorNotifier.showError(message);
