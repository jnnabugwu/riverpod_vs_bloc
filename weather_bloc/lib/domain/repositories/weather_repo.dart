import 'package:dartz/dartz.dart';
import 'package:weather_shared/weather_shared.dart';
import '../../core/error/failures.dart';

typedef ResultFuture<T> = Future<Either<Failure, T>>;

abstract class WeatherRepository {
  /// Fetches current weather for a given location
  ResultFuture<Weather> getCurrentWeather(Location location);

  /// Fetches 5-day forecast for a given location
  ResultFuture<List<ForecastDay>> getForecast(Location location);

  /// Changes the temperature unit for future weather fetches
  ResultFuture<TemperatureUnit> changeTemperatureUnit(TemperatureUnit unit);

  /// Gets the current temperature unit setting
  TemperatureUnit getCurrentUnit();

  /// Searches for locations by query string
  ResultFuture<List<Location>> searchLocation(String query);
}
