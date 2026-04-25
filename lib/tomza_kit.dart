/// tomza_kit: Librería interna modular para apps Flutter de TOMZA.
///
/// Este archivo centraliza las exportaciones públicas del paquete.
library;

// Core - Auth
export 'core/auth/auth_service.dart';
export 'core/auth/device_validator.dart';
export 'core/auth/session_manager.dart';

// Core - Network
export 'core/network/api_client.dart';
export 'core/network/network_exceptions.dart';
export 'core/network/failures.dart';
export 'core/network/env_config.dart';

// Core - Storage
export 'core/storage/secure_storage.dart';
export 'core/storage/preferences.dart';

// Core - Location
export 'core/location/gps_service.dart';
export 'core/location/location_utils.dart';
export 'core/location/route_planner.dart';

// Features - Media
export 'features/media/camera_service.dart';
export 'features/media/image_utils.dart';

// Features - Reports
export 'features/reports/report_service.dart';
export 'features/reports/kpi_calculator.dart';

// Features - Notifications
export 'features/notifications/push_service.dart';
export 'features/notifications/local_notifications.dart';

// Features - Printing
export 'features/printing/escpos_converter.dart';
export 'features/printing/native_bixolon.dart';
export 'features/printing/print_models.dart';
export 'features/printing/print_manager.dart';
export 'features/printing/thermal_optimizer.dart';
export 'features/printing/thermal_pdf_generator.dart';
export 'features/printing/widgets/print_button.dart';
export 'features/printing/widgets/ticket_preview.dart';

// UI - Components & Themes
export 'ui/components/tomza_button.dart';
export 'ui/components/tomza_card.dart';
export 'ui/components/tomza_dialog.dart';
export 'ui/components/custom_date_picker.dart';
export 'ui/components/image/tomza_image.dart';
export 'ui/themes/colors.dart';
export 'ui/themes/typography.dart';

// Utils
export 'utils/constants.dart';
export 'utils/validators.dart';
export 'utils/formatters.dart';
export 'utils/notifier.dart';
export 'utils/unauthorized_handler.dart';
export 'utils/network_check.dart';
