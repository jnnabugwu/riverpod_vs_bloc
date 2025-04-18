import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:weather_riverpod/core/error/failures.dart';
import 'package:weather_riverpod/core/utils/typedef.dart';
import 'package:weather_riverpod/domain/repositories/location_repo.dart';
import 'package:weather_shared/weather_shared.dart';

/// This is the implementation of the LocationRepository interface.
/// It is used to get the current location of the user.
/// It is also used to get the location of a city by latitude and longitude.

class LocationRepositoryImpl extends LocationRepository {
  @override
  /// This is the implementation of the getCurrentLocation method.
  ResultFuture<Location> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(
          LocationFailure(message: 'Location services are disabled'),
        );
      }

      // Check for location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const Left(
            LocationFailure(message: 'Location permissions are denied'),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const Left(
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
        return const Left(
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
  ResultFuture<Location> setLocation(Location location) async {
    try {
      return Right(location);
    } catch (e) {
      return Left(LocationFailure(message: 'Failed to set location: $e'));
    }
  }
}
