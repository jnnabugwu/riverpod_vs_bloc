import 'package:weather_riverpod/core/utils/typedef.dart';
import 'package:weather_shared/weather_shared.dart';

abstract class WeatherRepository {
  /// Get the weather for the given coordinates.
  ResultFuture<Weather> getCurrentWeather(Location location);

  /// Get the weather forecast for the given coordinates.
  ResultFuture<List<ForecastDay>> getWeatherForecast(Location location);

  /// Get the current temperature unit.
  TemperatureUnit get temperatureUnit;

  /// Set the temperature unit.
  void setTemperatureUnit(TemperatureUnit unit);
}
