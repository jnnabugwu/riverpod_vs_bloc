import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_riverpod/application/providers/location_provider.dart';
import 'package:weather_riverpod/application/providers/service_providers.dart';
import 'package:weather_shared/weather_shared.dart';

/// A class that holds both current weather and forecast data.
class WeatherData {
  /// A class that holds both current weather and forecast data.
  WeatherData({required this.currentWeather, required this.forecast});

  /// The current weather data.
  final Weather currentWeather;

  /// The forecast data.
  final List<ForecastDay> forecast;
}

/// A provider that manages the weather state.
final weatherProvider = AsyncNotifierProvider<WeatherNotifier, WeatherData?>(
  WeatherNotifier.new,
);

/// A notifier that manages the weather state and temperature unit.
class WeatherNotifier extends AsyncNotifier<WeatherData?> {
  TemperatureUnit _currentUnit = TemperatureUnit.celsius;

  /// The current temperature unit (Celsius or Fahrenheit).
  TemperatureUnit get currentUnit => _currentUnit;

  @override
  Future<WeatherData?> build() async {
    // Get the repository from the provider
    final repository = ref.watch(weatherRepositoryProvider);

    // Get the current location from the locationProvider
    final location = await ref.watch(locationProvider.future);

    // If we have a location, fetch the weather data
    if (location != null) {
      final currentWeatherResult = await repository.getCurrentWeather(
        location,
      );
      final forecastResult = await repository.getWeatherForecast(location);

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

    final currentWeatherResult = await repository.getCurrentWeather(
      defaultLocation,
    );
    final forecastResult = await repository.getWeatherForecast(
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
      // Get the repository from the provider
      final repository = ref.watch(weatherRepositoryProvider);

      final location = await ref.watch(locationProvider.future);
      if (location == null) {
        throw Exception('No location available');
      }

      final currentWeatherResult = await repository.getCurrentWeather(location);
      final forecastResult = await repository.getWeatherForecast(location);

      if (currentWeatherResult.isLeft()) {
        throw Exception(currentWeatherResult.fold((l) => l.message, (r) => ''));
      }

      if (forecastResult.isLeft()) {
        throw Exception(forecastResult.fold((l) => l.message, (r) => ''));
      }

      return WeatherData(
        currentWeather: currentWeatherResult
            .getOrElse(() => throw Exception('Failed to get current weather')),
        forecast: forecastResult
            .getOrElse(() => throw Exception('Failed to get forecast')),
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

    // Get the repository from the provider and set the temperature unit
    ref.read(weatherRepositoryProvider).setTemperatureUnit(_currentUnit);

    // Refresh the weather data with the new unit
    fetchWeather();
  }
}
