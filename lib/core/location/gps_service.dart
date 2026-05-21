import 'location_service.dart';

/// GpsService: obtiene posición (simulada) del dispositivo.
/// Implementa [LocationService] siguiendo el principio de inversión de dependencias.
class GpsService implements LocationService {
  @override
  Future<(double lat, double lng)> getCurrentPosition() async {
    // TODO: Integrar con geolocator/geocoding.
    return (19.4326, -99.1332); // CDMX
  }
}

typedef MockLocationService = GpsService;
