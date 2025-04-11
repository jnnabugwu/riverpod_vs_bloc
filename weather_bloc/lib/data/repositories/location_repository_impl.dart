import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_bloc/core/error/failures.dart';
import 'package:weather_bloc/domain/repositories/location_repo.dart';
import 'package:weather_shared/weather_shared.dart';

class LocationRepositoryImpl implements LocationRepository {
  Location? _currentLocation;

  @override
  ResultFuture<Location> getCurrentLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Left(
            LocationFailure(message: 'Location permissions are denied'),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Left(
          LocationFailure(
            message: 'Location permissions are permanently denied',
          ),
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition();

      // Create location object
      final location = Location(
        cityName:
            'Current Location', // We'll update this with reverse geocoding if needed
        lat: position.latitude,
        lon: position.longitude,
      );

      _currentLocation = location;
      return Right(location);
    } catch (e) {
      return Left(LocationFailure(message: 'Failed to get location: $e'));
    }
  }

  @override
  ResultFuture<Location> setLocation(Location location) async {
    try {
      _currentLocation = location;
      return Right(location);
    } catch (e) {
      return Left(LocationFailure(message: 'Failed to set location: $e'));
    }
  }
}
