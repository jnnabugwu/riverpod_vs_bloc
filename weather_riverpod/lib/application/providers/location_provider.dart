import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_riverpod/data/repositories/location_repo_impl.dart';
import 'package:weather_shared/weather_shared.dart';

/// A provider that manages the location state.
final locationProvider = AsyncNotifierProvider<LocationNotifier, Location?>(
  LocationNotifier.new,
);

/// A notifier that manages the location state.
class LocationNotifier extends AsyncNotifier<Location?> {
  late final LocationRepositoryImpl _repository;

  @override
  Future<Location?> build() async {
    _repository = LocationRepositoryImpl();
    // Initial state is null
    return null;
  }

  /// Gets the current device location.
  Future<void> getCurrentLocation() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _repository.getCurrentLocation();
      return result.fold(
        (failure) => throw Exception(failure.message),
        (location) => location,
      );
    });
  }

  /// Sets the current location.
  Future<void> setLocation(Location location) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _repository.setLocation(location);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (location) => location,
      );
    });
  }
}
