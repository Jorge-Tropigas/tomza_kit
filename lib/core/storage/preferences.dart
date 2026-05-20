import 'preferences_service.dart';

/// Preferences: preferencias simples en memoria.
/// Implementa [PreferencesService] para seguir el principio de inversión de dependencias.
class Preferences implements PreferencesService {
  final Map<String, Object?> _prefs = {};

  @override
  Future<void> setString(String key, String value) async => _prefs[key] = value;

  @override
  Future<void> setBool(String key, bool value) async => _prefs[key] = value;

  @override
  Future<void> setInt(String key, int value) async => _prefs[key] = value;

  @override
  String? getString(String key) => _prefs[key] as String?;

  @override
  bool? getBool(String key) => _prefs[key] as bool?;

  @override
  int? getInt(String key) => _prefs[key] as int?;
}

typedef InMemoryPreferences = Preferences;
