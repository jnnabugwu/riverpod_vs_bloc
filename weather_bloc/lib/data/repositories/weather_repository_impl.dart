import 'package:dartz/dartz.dart';
import 'package:weather_shared/weather_shared.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/weather_repo.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherService _weatherService;
  TemperatureUnit _currentUnit;

  WeatherRepositoryImpl(this._weatherService)
    : _currentUnit = TemperatureUnit.fahrenheit;

  @override
  ResultFuture<Weather> getCurrentWeather(Location location) async {
    try {
      final weather = await _weatherService.getCurrentWeather(location);
      return Right(weather);
    } on WeatherException catch (e) {
      return Left(WeatherFailure.fromException(e));
    } catch (e) {
      return Left(NetworkFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  ResultFuture<List<ForecastDay>> getForecast(Location location) async {
    try {
      final forecast = await _weatherService.getForecast(
        location.lat,
        location.lon,
      );
      return Right(forecast);
    } on WeatherException catch (e) {
      return Left(WeatherFailure.fromException(e));
    } catch (e) {
      return Left(NetworkFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  @override
  ResultFuture<TemperatureUnit> changeTemperatureUnit(
    TemperatureUnit temperatureUnit,
  ) async {
    try {
      _weatherService.setTemperatureUnit(temperatureUnit);
      _currentUnit = temperatureUnit;
      return right(temperatureUnit);
    } catch (e) {
      return Left(
        WeatherFailure(message: 'Failed to change temperature unit: $e'),
      );
    }
  }

  @override
  TemperatureUnit getCurrentUnit() => _currentUnit;

  @override
  ResultFuture<List<Location>> searchLocation(String query) async {
    try {
      final locations = await _weatherService.searchLocation(query);
      return Right(locations);
    } on WeatherException catch (e) {
      return Left(WeatherFailure.fromException(e));
    } catch (e) {
      return Left(LocationFailure(message: 'Failed to search locations: $e'));
    }
  }
}
