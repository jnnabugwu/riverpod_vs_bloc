import 'package:weather_riverpod/core/utils/typedef.dart';
import 'package:weather_shared/weather_shared.dart';

/// This is the interface for the LocationRepository.
/// It is used to get the current location of the user.
abstract class LocationRepository {
  /// Get the current location of the user.
  ResultFuture<Location> getCurrentLocation();

  /// Set the location of the user.
  ResultFuture<Location> setLocation(Location location);
}
