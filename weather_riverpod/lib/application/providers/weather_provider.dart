import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_riverpod/application/providers/location_provider.dart';
import 'package:weather_riverpod/application/providers/service_providers.dart';
import 'package:weather_riverpod/data/repositories/weather_repo_impl.dart';
import 'package:weather_shared/weather_shared.dart';

/// A class that holds both current weather and forecast data.
class WeatherData {
  final Weather currentWeather;
  final List<ForecastDay> forecast;

  WeatherData({required this.currentWeather, required this.forecast});
}

/// A provider that manages the weather state.
final weatherProvider = AsyncNotifierProvider<WeatherNotifier, WeatherData?>(
  WeatherNotifier.new,
);

/// A notifier that manages the weather state and temperature unit.
class WeatherNotifier extends AsyncNotifier<WeatherData?> {
  late final WeatherRepositoryImpl _repository;
  TemperatureUnit _currentUnit = TemperatureUnit.celsius;

  /// The current temperature unit (Celsius or Fahrenheit).
  TemperatureUnit get currentUnit => _currentUnit;

  @override
  Future<WeatherData?> build() async {
    _repository = WeatherRepositoryImpl(ref.watch(weatherServiceProvider));

    // Get the current location from the locationProvider
    final location = await ref.watch(locationProvider.future);

    // If we have a location, fetch the weather data
    if (location != null) {
      final currentWeatherResult = await _repository.getCurrentWeather(
        location,
      );
      final forecastResult = await _repository.getWeatherForecast(location);

      return currentWeatherResult.fold(
        (failure) => throw Exception(failure.message),
        (currentWeather) => forecastResult.fold(
          (failure) => throw Exception(failure.message),
          (forecast) =>
              WeatherData(currentWeather: currentWeather, forecast: forecast),
        ),
      );
    }

    // If no location is available, use London as default
    final defaultLocation = Location(
      cityName: 'London',
      lat: 51.5074,
      lon: -0.1278,
    );

    final currentWeatherResult = await _repository.getCurrentWeather(
      defaultLocation,
    );
    final forecastResult = await _repository.getWeatherForecast(
      defaultLocation,
    );

    return currentWeatherResult.fold(
      (failure) => throw Exception(failure.message),
      (currentWeather) => forecastResult.fold(
        (failure) => throw Exception(failure.message),
        (forecast) =>
            WeatherData(currentWeather: currentWeather, forecast: forecast),
      ),
    );
  }

  /// Fetches the weather data for the current location.
  Future<void> fetchWeather() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final location = await ref.watch(locationProvider.future);
      if (location == null) {
        throw Exception('No location available');
      }

      final currentWeatherResult = await _repository.getCurrentWeather(
        location,
      );
      final forecastResult = await _repository.getWeatherForecast(location);

      return currentWeatherResult.fold(
        (failure) => throw Exception(failure.message),
        (currentWeather) => forecastResult.fold(
          (failure) => throw Exception(failure.message),
          (forecast) =>
              WeatherData(currentWeather: currentWeather, forecast: forecast),
        ),
      );
    });
  }

  /// Toggles between Celsius and Fahrenheit temperature units.
  void toggleTemperatureUnit() {
    if (_currentUnit == TemperatureUnit.celsius) {
      _currentUnit = TemperatureUnit.fahrenheit;
    } else {
      _currentUnit = TemperatureUnit.celsius;
    }
    print('Current unit: $_currentUnit');
    _repository.setTemperatureUnit(_currentUnit);

    // Refresh the weather data with the new unit
    fetchWeather();
  }
}
