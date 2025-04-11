import 'package:weather_bloc/core/usecases/usecases.dart';
import 'package:weather_bloc/domain/repositories/weather_repo.dart';
import 'package:weather_shared/weather_shared.dart';

class FetchWeatherUsecase extends UsecaseWithParams<Weather, Location> {
  final WeatherRepository _weatherRepository;

  FetchWeatherUsecase({required WeatherRepository weatherRepository})
    : _weatherRepository = weatherRepository;

  @override
  ResultFuture<Weather> call(Location location) async =>
      _weatherRepository.getCurrentWeather(location);
}
