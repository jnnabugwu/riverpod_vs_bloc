import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:weather_shared/weather_shared.dart';
import 'package:weather_bloc/domain/usecases/change_units_usecase.dart';
import 'package:weather_bloc/domain/usecases/fetch_forecast_usecase.dart';
import 'package:weather_bloc/domain/usecases/fetch_weather_usecase.dart';

part 'weather_event.dart';
part 'weather_state.dart';

// TODO: Implement the logic for the WeatherBloc
// 1. Fetch the current weather
// 2. Fetch the forecast
// 3. Change the temperature unit
// 4. Handle errors
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final FetchWeatherUsecase _fetchWeatherUsecase;
  final FetchForecastUsecase _fetchForecastUsecase;
  final ChangeUnitsUsecase _changeUnitsUsecase;
  final WeatherService weatherService;

  WeatherBloc(
    this._fetchWeatherUsecase,
    this._fetchForecastUsecase,
    this._changeUnitsUsecase, {
    required this.weatherService,
  }) : super(WeatherInitial()) {
    on<FetchWeatherEvent>(_onFetchWeather);
    on<FetchForecastEvent>(_onFetchForecast);
    on<ChangeTemperatureUnit>(_onChangeUnits);
  }

  void onLocationChanged(Location location) {
    add(FetchWeatherEvent(location));
    add(FetchForecastEvent(location));
  }

  Future<void> _onFetchWeather(
    FetchWeatherEvent event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());
    final result = await _fetchWeatherUsecase(event.location);
    result.fold((failure) => emit(WeatherError(failure.message)), (weather) {
      final currentForecast =
          (state is WeatherLoaded) ? (state as WeatherLoaded).forecast : null;
      emit(WeatherLoaded(weather: weather, forecast: currentForecast));
    });
  }

  Future<void> _onFetchForecast(
    FetchForecastEvent event,
    Emitter<WeatherState> emit,
  ) async {
    final result = await _fetchForecastUsecase(event.location);
    result.fold((failure) => emit(WeatherError(failure.message)), (forecast) {
      if (state is WeatherLoaded) {
        debugPrint('forecast: ${forecast.length.toString()}');
        final currentState = state as WeatherLoaded;
        emit(currentState.copyWith(forecast: forecast));
      }
    });
  }

  Future<void> _onChangeUnits(
    ChangeTemperatureUnit event,
    Emitter<WeatherState> emit,
  ) async {
    final result = await _changeUnitsUsecase(event.unit);
    result.fold(
      (failure) => emit(WeatherError(failure.message)),
      (unit) => emit(WeatherUnitsChanged(unit)),
    );
  }
}
