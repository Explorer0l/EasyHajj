import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';

import '../domain/user_location.dart';

const locationBoxName = 'user_location_box';
const currentLocationStorageKey = 'current_location';

enum LocationStatus {
  permissionGranted,
  permissionDenied,
  permissionPermanentlyDenied,
  serviceDisabled,
}

class LocationRepository {
  LocationRepository(this._box);

  final Box<UserLocation> _box;

  UserLocation? get cachedLocation => _box.get(currentLocationStorageKey);

  Future<LocationStatus> checkStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationStatus.serviceDisabled;
    }
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return LocationStatus.permissionDenied;
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationStatus.permissionPermanentlyDenied;
    }
    return LocationStatus.permissionGranted;
  }

  Future<UserLocation> refreshCurrentLocation() async {
    var status = await checkStatus();
    if (status == LocationStatus.permissionDenied) {
      final requestResult = await Geolocator.requestPermission();
      if (requestResult == LocationPermission.denied) {
        throw const LocationException(
          'Доступ к геолокации отклонён. Разрешите доступ, чтобы продолжить.',
        );
      }
      if (requestResult == LocationPermission.deniedForever) {
        throw const LocationException(
          'Геолокация заблокирована. Откройте настройки и разрешите доступ.',
        );
      }
      status = LocationStatus.permissionGranted;
    }

    if (status == LocationStatus.permissionPermanentlyDenied) {
      throw const LocationException(
        'Геолокация заблокирована. Откройте настройки и разрешите доступ.',
      );
    }
    if (status == LocationStatus.serviceDisabled) {
      throw const LocationException(
        'Службы геолокации отключены. Включите GPS или выберите город вручную.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final primary = placemarks.isNotEmpty ? placemarks.first : null;
    final city = primary?.administrativeArea?.isNotEmpty == true
        ? primary!.administrativeArea!
        : primary?.locality ?? '';
    final country = primary?.country ?? '';
    final timezone = DateTime.now().timeZoneName;
    final location = UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      city: city,
      country: country,
      timezone: timezone,
      collectedAt: DateTime.now(),
    );
    await _box.put(currentLocationStorageKey, location);
    return location;
  }
}

class LocationException implements Exception {
  const LocationException(this.message);
  final String message;

  @override
  String toString() => message;
}

