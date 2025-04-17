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
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(
          LocationFailure(message: 'Location service is disabled'),
        );
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        return const Left(
          LocationFailure(message: 'Location permission is denied'),
        );
      }

      if (permission == LocationPermission.deniedForever) {
        return const Left(
          LocationFailure(message: 'Location permission is denied forever'),
        );
      }

      final position = await Geolocator.getCurrentPosition();
      final placemark = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final location = Location(
        lat: position.latitude,
        lon: position.longitude,
        cityName: placemark.first.locality ?? 'Unknown Location',
      );
      return Right(location);
    } catch (e) {
      return const Left(
        LocationFailure(message: 'Failed to get current location'),
      );
    }
  }

  @override
  ResultFuture<Location> setLocation(Location location) async {
    try {
      return Right(location);
    } catch (e) {
      return const Left(LocationFailure(message: 'Failed to set location'));
    }
  }
}
