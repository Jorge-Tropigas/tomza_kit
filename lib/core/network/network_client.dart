abstract class NetworkClient {
  Future<Map<String, dynamic>> getJson(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes,
  });

  Future<Map<String, dynamic>> postJson(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes,
    bool enableAndroidRenegotiationFallback,
  });

  Future<Map<String, dynamic>> postListJson(
    String endpoint, {
    required List<dynamic> listBody,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes,
    bool enableAndroidRenegotiationFallback,
  });

  Future<Map<String, dynamic>> putJson(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes,
  });

  Future<Map<String, dynamic>> deleteJson(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    Set<int> acceptableStatusCodes,
  });
}
