import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:weather_shared/weather_shared.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/location_repo.dart';

class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<Either<Failure, Location>> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Left(LocationFailure(message: 'Location services are disabled'));
      }

      // Check for location permission
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
            message:
                'Location permissions are permanently denied, we cannot request permissions.',
          ),
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition();

      // Get placemark from coordinates
      final placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        return Left(
          LocationFailure(message: 'Could not determine location name'),
        );
      }

      return Right(
        Location(
          cityName: placemarks.first.locality ?? 'Unknown Location',
          lat: position.latitude,
          lon: position.longitude,
        ),
      );
    } catch (e) {
      return Left(LocationFailure(message: 'Failed to get location: $e'));
    }
  }

  @override
  Future<Either<Failure, Location>> setLocation(Location location) async {
    try {
      return Right(location);
    } catch (e) {
      return Left(LocationFailure(message: 'Failed to set location: $e'));
    }
  }
}

class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message;
}
