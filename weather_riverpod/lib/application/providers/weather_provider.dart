import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_shared/weather_shared.dart';

/// A provider that manages the weather forecast state.
final weatherProvider =
    AsyncNotifierProvider<WeatherNotifier, List<ForecastDay>?>(
      WeatherNotifier.new,
    );

/// A notifier that manages the weather forecast state and temperature unit.
class WeatherNotifier extends AsyncNotifier<List<ForecastDay>?> {
  late final WeatherService _weatherService;
  TemperatureUnit _currentUnit = TemperatureUnit.celsius;

  /// The current temperature unit (Celsius or Fahrenheit).
  TemperatureUnit get currentUnit => _currentUnit;

  @override
  Future<List<ForecastDay>?> build() async {
    _weatherService = WeatherService(
      apiKey: ApiConfig.openWeatherApiKey,
      dio: Dio(),
    );
    return await _weatherService.getForecast(
      51.5074,
      -0.1278,
    ); // Default to London
  }

  /// Fetches the weather forecast for the given coordinates.
  Future<void> fetchForecast(double lat, double lon) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _weatherService.getForecast(lat, lon));
  }

  /// Toggles between Celsius and Fahrenheit temperature units.
  void toggleTemperatureUnit() {
    _currentUnit =
        _currentUnit == TemperatureUnit.celsius
            ? TemperatureUnit.fahrenheit
            : TemperatureUnit.celsius;
    _weatherService.setTemperatureUnit(_currentUnit);
    ref.notifyListeners();
  }
}
