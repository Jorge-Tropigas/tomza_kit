import 'location_utils.dart';

/// RoutePlanner: calcula rutas simples (mock) entre dos puntos.
class RoutePlanner {
  /// Retorna una lista de puntos intermedios simulados.
  List<(double lat, double lng)> planRoute(
    (double lat, double lng) origin,
    (double lat, double lng) dest, {
    int steps = 3,
  }) {
    steps = steps.clamp(1, 20);
    final points = <(double, double)>[];
    for (var i = 1; i <= steps; i++) {
      final t = i / (steps + 1);
      points.add((
        origin.$1 + (dest.$1 - origin.$1) * t,
        origin.$2 + (dest.$2 - origin.$2) * t,
      ));
    }
    return points;
  }

  /// Estima duración en minutos asumiendo 40km/h promedio.
  double estimateDurationMinutes(
    (double lat, double lng) origin,
    (double lat, double lng) dest,
  ) {
    final km = LocationUtils.distanceKm(origin, dest);
    const speedKmh = 40.0;
    return (km / speedKmh) * 60.0;
  }
}
