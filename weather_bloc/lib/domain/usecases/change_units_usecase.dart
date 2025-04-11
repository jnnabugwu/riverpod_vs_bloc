import 'package:weather_bloc/core/usecases/usecases.dart';
import 'package:weather_bloc/domain/repositories/weather_repo.dart';
import 'package:weather_shared/services/temperature_utils.dart';

class ChangeUnitsUsecase
    extends UsecaseWithParams<TemperatureUnit, TemperatureUnit> {
  final WeatherRepository _weatherRepository;

  ChangeUnitsUsecase({required WeatherRepository weatherRepository})
    : _weatherRepository = weatherRepository;

  @override
  ResultFuture<TemperatureUnit> call(TemperatureUnit unit) async =>
      _weatherRepository.changeTemperatureUnit(unit);
}
