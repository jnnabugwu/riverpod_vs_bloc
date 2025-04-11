import 'package:weather_bloc/core/usecases/usecases.dart';
import 'package:weather_bloc/domain/repositories/location_repo.dart';
import 'package:weather_shared/weather_shared.dart';

class GetCurrentLocationUsecase extends UsecaseWithoutParams<Location> {
  final LocationRepository _locationRepository;

  GetCurrentLocationUsecase({required LocationRepository locationRepository})
    : _locationRepository = locationRepository;

  @override
  ResultFuture<Location> call() async =>
      _locationRepository.getCurrentLocation();
}
