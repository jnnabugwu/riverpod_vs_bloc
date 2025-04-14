import 'package:get_it/get_it.dart';
import 'package:weather_bloc/data/repositories/location_repository_impl.dart';
import 'package:weather_bloc/data/repositories/weather_repository_impl.dart';
import 'package:weather_bloc/domain/repositories/location_repo.dart';
import 'package:weather_bloc/domain/repositories/weather_repo.dart';
import 'package:weather_bloc/domain/usecases/change_units_usecase.dart';
import 'package:weather_bloc/domain/usecases/fetch_forecast_usecase.dart';
import 'package:weather_bloc/domain/usecases/fetch_weather_usecase.dart';
import 'package:weather_bloc/domain/usecases/get_current_location_usecase.dart';
import 'package:weather_bloc/domain/usecases/set_location_usecase.dart';
import 'package:weather_bloc/presentation/bloc/location/location_bloc.dart';
import 'package:weather_bloc/presentation/bloc/weather/weather_bloc.dart';
import 'package:weather_shared/weather_shared.dart';
import 'package:dio/dio.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Blocs
  getIt.registerFactory(
    () => LocationBloc(
      getCurrentLocationUsecase: getIt(),
      setLocationUsecase: getIt(),
    ),
  );

  getIt.registerFactory(
    () => WeatherBloc(getIt(), getIt(), getIt(), weatherService: getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(
    () => GetCurrentLocationUsecase(locationRepository: getIt()),
  );
  getIt.registerLazySingleton(
    () => SetLocationUsecase(locationRepository: getIt()),
  );
  getIt.registerLazySingleton(
    () => FetchWeatherUsecase(weatherRepository: getIt()),
  );
  getIt.registerLazySingleton(
    () => FetchForecastUsecase(weatherRepository: getIt()),
  );
  getIt.registerLazySingleton(
    () => ChangeUnitsUsecase(weatherRepository: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(),
  );

  getIt.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(getIt()),
  );

  // External
  getIt.registerLazySingleton(
    () => WeatherService(apiKey: ApiConfig.openWeatherApiKey, dio: Dio()),
  );
}
