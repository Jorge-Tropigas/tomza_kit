abstract class PreferencesService {
  Future<void> setString(String key, String value);
  Future<void> setBool(String key, bool value);
  Future<void> setInt(String key, int value);
  String? getString(String key);
  bool? getBool(String key);
  int? getInt(String key);
}
