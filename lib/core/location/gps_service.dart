// Dart imports:
import 'dart:async';

// Package imports:
import 'package:geolocator/geolocator.dart';
import 'package:tomza_kit/core/location/location_service.dart';

enum GpsStatus {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  success,
  error,
}

class AppLocationService implements LocationService {
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _currentPosition;

  Position? get currentPosition => _currentPosition;

  void dispose() {
    _positionStreamSubscription?.cancel();
  }

  Future<bool> isServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<GpsStatus> checkAndRequestPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return GpsStatus.serviceDisabled;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return GpsStatus.permissionDenied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return GpsStatus.permissionDeniedForever;
    }

    return GpsStatus.success;
  }

  @override
  Future<(double lat, double lng)> getCurrentPosition({
    Duration timeLimit = const Duration(seconds: 15),
  }) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeLimit,
        ),
      );
      _currentPosition = position;
      return (position.latitude, position.longitude);
    } catch (_) {
      return (0.0, 0.0);
    }
  }

  Future<Position?> getCurrentPositionDetail({
    Duration timeLimit = const Duration(seconds: 15),
  }) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeLimit,
        ),
      );
      _currentPosition = position;
      return position;
    } catch (_) {
      return null;
    }
  }

  Future<void> startStream({
    void Function(Position position)? onPosition,
    void Function(Object error)? onError,
    int distanceFilter = 10,
  }) async {
    _positionStreamSubscription?.cancel();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position? position) {
            if (position != null) {
              _currentPosition = position;
              onPosition?.call(position);
            }
          },
          onError: (dynamic error) {
            _positionStreamSubscription?.cancel();
            onError?.call(error);
          },
        );
  }

  void stopStream() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  double distanceBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  Future<void> requestPermissionOnInit() async {
    await Geolocator.checkPermission().then((LocationPermission status) async {
      if (status == LocationPermission.denied ||
          status == LocationPermission.deniedForever) {
        await Geolocator.requestPermission();
      }
    });
  }
}
