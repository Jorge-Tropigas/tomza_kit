import 'storage_service.dart';

/// SecureStorage: almacenamiento simulado (en memoria) para secretos.
/// Implementa [StorageService] para seguir el principio de inversión de dependencias (SOLID).
class SecureStorage implements StorageService {
  final Map<String, String> _store = {};

  @override
  Future<void> write(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }
}

typedef InMemorySecureStorage = SecureStorage;
