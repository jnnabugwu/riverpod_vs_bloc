import 'package:dartz/dartz.dart';
import 'package:weather_riverpod/core/error/failures.dart';
import 'package:weather_riverpod/core/utils/typedef.dart';
import 'package:weather_riverpod/domain/repositories/location_repo.dart';
import 'package:weather_shared/weather_shared.dart';

/// This is the implementation of the LocationRepository interface.
/// It is used to get the current location of the user.
/// It is also used to get the location of a city by latitude and longitude.

class LocationRepositoryImpl extends LocationRepository {
  final LocationService _locationService;

  LocationRepositoryImpl(this._locationService);

  @override

  /// This is the implementation of the getCurrentLocation method.
  ResultFuture<Location> getCurrentLocation() async {
    try {
      final location = await _locationService.getCurrentLocation();
      return Right(location);
    } catch (e) {
      return Left(LocationFailure(message: 'Failed to get location: $e'));
    }
  }

  @override
  ResultFuture<Location> setLocation(Location location) async {
    try {
      final updatedLocation = await _locationService.setLocation(location);
      return Right(updatedLocation);
    } catch (e) {
      return Left(LocationFailure(message: 'Failed to set location: $e'));
    }
  }
}
