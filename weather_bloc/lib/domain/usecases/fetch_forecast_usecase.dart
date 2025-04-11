import 'package:weather_bloc/core/usecases/usecases.dart';
import 'package:weather_bloc/domain/repositories/weather_repo.dart';
import 'package:weather_shared/weather_shared.dart';

class FetchForecastUsecase
    extends UsecaseWithParams<List<ForecastDay>, Location> {
  final WeatherRepository _weatherRepository;

  FetchForecastUsecase({required WeatherRepository weatherRepository})
    : _weatherRepository = weatherRepository;

  @override
  ResultFuture<List<ForecastDay>> call(Location location) async =>
      _weatherRepository.getForecast(location);
}
