part of 'weather_bloc.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final Weather weather;

  const WeatherLoaded({required this.weather});
}

class WeatherForecastLoaded extends WeatherState {
  final List<ForecastDay> forecast;

  const WeatherForecastLoaded({required this.forecast});
}

class WeatherError extends WeatherState {
  final String message;

  const WeatherError(this.message);
}

class WeatherUnitsChanged extends WeatherState {
  final TemperatureUnit unit;

  const WeatherUnitsChanged(this.unit);
}
