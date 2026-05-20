import 'package:flutter_test/flutter_test.dart';
import 'package:tomza_kit/tomza_kit.dart';

class CustomAuthService implements AuthService {
  @override
  String? get currentUserId => 'custom-user';
  @override
  bool get isAuthenticated => true;
  @override
  Future<bool> signIn({required String username, required String password}) async => true;
  @override
  Future<void> signOut() async {}
}

class CustomStorageService implements StorageService {
  final Map<String, String> _data = {};
  @override
  Future<void> write(String key, String value) async => _data[key] = value;
  @override
  Future<String?> read(String key) async => _data[key];
  @override
  Future<void> delete(String key) async => _data.remove(key);
}

class CustomPreferencesService implements PreferencesService {
  @override
  String? getString(String key) => 'custom-pref';
  @override
  bool? getBool(String key) => true;
  @override
  int? getInt(String key) => 42;
  @override
  Future<void> setString(String key, String value) async {}
  @override
  Future<void> setBool(String key, bool value) async {}
  @override
  Future<void> setInt(String key, int value) async {}
}

class CustomLocationService implements LocationService {
  @override
  Future<(double lat, double lng)> getCurrentPosition() async => (10.0, 20.0);
}

class CustomNetworkClient implements NetworkClient {
  @override
  Future<Map<String, dynamic>> getJson(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
  }) async => {'url': endpoint};

  @override
  Future<Map<String, dynamic>> postJson(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
    bool enableAndroidRenegotiationFallback = true,
  }) async => {};

  @override
  Future<Map<String, dynamic>> postListJson(
    String endpoint, {
    required List listBody,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
    bool enableAndroidRenegotiationFallback = true,
  }) async => {};

  @override
  Future<Map<String, dynamic>> putJson(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200},
  }) async => {};

  @override
  Future<Map<String, dynamic>> deleteJson(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes = const {200, 204},
  }) async => {};
}

class CustomCameraService implements CameraService {
  @override
  Future<List<int>> takePictureBytes() async => [1, 2, 3];
}

void main() {
  test('TomzaKit defaults are resolved correctly', () {
    expect(TomzaKit.auth, isA<AuthService>());
    expect(TomzaKit.storage, isA<StorageService>());
    expect(TomzaKit.preferences, isA<PreferencesService>());
    expect(TomzaKit.location, isA<LocationService>());
    expect(TomzaKit.network, isA<NetworkClient>());
    expect(TomzaKit.camera, isA<CameraService>());
  });

  test('TomzaKit configuration overrides defaults', () async {
    final customAuth = CustomAuthService();
    final customStorage = CustomStorageService();
    final customPrefs = CustomPreferencesService();
    final customLoc = CustomLocationService();
    final customNet = CustomNetworkClient();
    final customCam = CustomCameraService();

    TomzaKit.configure(
      auth: customAuth,
      storage: customStorage,
      preferences: customPrefs,
      location: customLoc,
      network: customNet,
      camera: customCam,
    );

    expect(TomzaKit.auth, customAuth);
    expect(TomzaKit.storage, customStorage);
    expect(TomzaKit.preferences, customPrefs);
    expect(TomzaKit.location, customLoc);
    expect(TomzaKit.network, customNet);
    expect(TomzaKit.camera, customCam);

    // Verify static redirect in ApiClient uses custom client:
    final res = await ApiClient.getJson('/test-endpoint');
    expect(res, {'url': '/test-endpoint'});
  });
}
