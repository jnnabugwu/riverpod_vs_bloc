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
  final List<ForecastDay>? forecast;

  const WeatherLoaded({required this.weather, this.forecast});

  @override
  List<Object> get props => [weather, if (forecast != null) forecast!];

  WeatherLoaded copyWith({Weather? weather, List<ForecastDay>? forecast}) {
    return WeatherLoaded(
      weather: weather ?? this.weather,
      forecast: forecast ?? this.forecast,
    );
  }
}

class WeatherForecastLoaded extends WeatherState {
  final List<ForecastDay> forecast;

  const WeatherForecastLoaded({required this.forecast});
}

class WeatherError extends WeatherState {
  final String message;

  const WeatherError(this.message);

  @override
  List<Object> get props => [message];
}

class WeatherUnitsChanged extends WeatherState {
  final TemperatureUnit unit;

  const WeatherUnitsChanged(this.unit);

  @override
  List<Object> get props => [unit];
}
