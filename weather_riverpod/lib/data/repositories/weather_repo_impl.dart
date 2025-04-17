import 'package:dartz/dartz.dart';
import 'package:weather_riverpod/core/error/failures.dart';
import 'package:weather_riverpod/core/utils/typedef.dart';
import 'package:weather_riverpod/domain/repositories/weather_repo.dart';
import 'package:weather_shared/models/weather.dart';
import 'package:weather_shared/services/temperature_utils.dart';
import 'package:weather_shared/weather_shared.dart';
import 'package:weather_shared/widgets/weather_forecast.dart';

/// A repository that manages the weather data.
class WeatherRepositoryImpl extends WeatherRepository {
  WeatherRepositoryImpl(this._weatherService)
    : _currentUnit = TemperatureUnit.celsius;
  final WeatherService _weatherService;
  TemperatureUnit _currentUnit;

  @override
  ResultFuture<Weather> getCurrentWeather(Location location) async {
    try {
      final weather = await _weatherService.getCurrentWeather(location);
      return Right(weather);
    } catch (e) {
      return Left(WeatherFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<ForecastDay>> getWeatherForecast(Location location) async {
    try {
      final weatherForecast = await _weatherService.getForecast(
        location.lat,
        location.lon,
      );
      return Right(weatherForecast);
    } catch (e) {
      return Left(WeatherFailure(message: e.toString()));
    }
  }

  @override
  void setTemperatureUnit(TemperatureUnit unit) {
    _currentUnit = unit;
  }

  @override
  TemperatureUnit get temperatureUnit => _currentUnit;
}
