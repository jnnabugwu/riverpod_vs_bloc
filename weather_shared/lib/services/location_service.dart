import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../models/location.dart';

class LocationService {
  Future<Location> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get place name from coordinates
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw Exception('Could not determine location name');
      }

      final place = placemarks.first;
      final cityName =
          place.locality ?? place.subAdministrativeArea ?? 'Unknown';

      return Location(
        cityName: cityName,
        lat: position.latitude,
        lon: position.longitude,
      );
    } catch (e) {
      throw Exception('Error getting current location: $e');
    }
  }

  Future<Location> setLocation(Location location) async {
    // For now, just return the location as is
    // In the future, we might want to save this to preferences
    return Location(
      cityName: location.cityName,
      lat: location.lat,
      lon: location.lon,
    );
  }
}
