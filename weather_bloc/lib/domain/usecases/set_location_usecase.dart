import 'package:weather_bloc/core/usecases/usecases.dart';
import 'package:weather_bloc/domain/repositories/location_repo.dart';
import 'package:weather_shared/weather_shared.dart';

class SetLocationUsecase extends UsecaseWithParams<Location, Location> {
  final LocationRepository _locationRepository;

  SetLocationUsecase({required LocationRepository locationRepository})
    : _locationRepository = locationRepository;

  @override
  ResultFuture<Location> call(Location location) async =>
      _locationRepository.setLocation(location);
}
