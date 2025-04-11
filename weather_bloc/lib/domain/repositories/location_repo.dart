import 'package:dartz/dartz.dart';
import 'package:weather_bloc/core/error/failures.dart';
import 'package:weather_shared/weather_shared.dart';

typedef ResultFuture<T> = Future<Either<Failure, T>>;

abstract class LocationRepository {
  /// Gets the current device location
  ResultFuture<Location> getCurrentLocation();

  /// Sets the current location
  ResultFuture<Location> setLocation(Location location);
}
