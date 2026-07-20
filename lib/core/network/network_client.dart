import 'package:tomza_kit/core/network/api_client.dart';

abstract class NetworkClient {
  Future<Json> get(
    String endpoint, {
    Json? data,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes,
  });

  Future<Json> post(
    String endpoint, {
    Object? body,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes,
    bool enableAndroidRenegotiationFallback,
  });

  /// Como [post], pero sin forzar el cuerpo de la respuesta a
  /// `Map<String, dynamic>`. Úsalo cuando el endpoint puede responder con un
  /// arreglo JSON plano (`[...]`) en vez de un objeto envuelto.
  Future<dynamic> postDynamic(
    String endpoint, {
    Object? body,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes,
    bool enableAndroidRenegotiationFallback,
  });

  Future<Json> postListJson(
    String endpoint, {
    required List<dynamic> listBody,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes,
    bool enableAndroidRenegotiationFallback,
  });

  Future<Json> put(
    String endpoint, {
    Object? body,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes,
  });

  Future<Json> deleteJson(
    String endpoint, {
    Object? body,
    Json? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes,
  });
}
