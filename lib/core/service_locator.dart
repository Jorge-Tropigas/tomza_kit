import 'auth/auth_service.dart';
import 'storage/storage_service.dart';
import 'storage/secure_storage.dart';
import 'storage/preferences_service.dart';
import 'storage/preferences.dart';
import 'location/location_service.dart';
import 'location/gps_service.dart';
import 'network/network_client.dart';
import 'network/api_client.dart';
import '../features/media/camera_service.dart';

/// TomzaKit: Localizador de servicios global para configurar e inyectar dependencias.
/// Sigue el patrón Service Locator para resolver dependencias cumpliendo el principio
/// de inversión de dependencias (SOLID).
class TomzaKit {
  TomzaKit._();
  static final TomzaKit _instance = TomzaKit._();

  AuthService _auth = InMemoryAuthService();
  StorageService _storage = SecureStorage();
  PreferencesService _preferences = Preferences();
  LocationService _location = GpsService();
  NetworkClient _network = const DioNetworkClient();
  CameraService _camera = CameraService();

  /// Retorna el servicio de autenticación activo.
  static AuthService get auth => _instance._auth;

  /// Retorna el servicio de almacenamiento seguro activo.
  static StorageService get storage => _instance._storage;

  /// Retorna el servicio de preferencias compartidas activo.
  static PreferencesService get preferences => _instance._preferences;

  /// Retorna el servicio de geolocalización activo.
  static LocationService get location => _instance._location;

  /// Retorna el cliente de red activo.
  static NetworkClient get network => _instance._network;

  /// Retorna el servicio de cámara activo.
  static CameraService get camera => _instance._camera;

  /// Configura o sobrescribe los servicios globales durante la inicialización de la app.
  static void configure({
    AuthService? auth,
    StorageService? storage,
    PreferencesService? preferences,
    LocationService? location,
    NetworkClient? network,
    CameraService? camera,
  }) {
    if (auth != null) _instance._auth = auth;
    if (storage != null) _instance._storage = storage;
    if (preferences != null) _instance._preferences = preferences;
    if (location != null) _instance._location = location;
    if (network != null) _instance._network = network;
    if (camera != null) _instance._camera = camera;
  }
}
