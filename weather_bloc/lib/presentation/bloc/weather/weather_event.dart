part of 'weather_bloc.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class FetchWeatherEvent extends WeatherEvent {
  final Location location;

  const FetchWeatherEvent(this.location);

  @override
  List<Object> get props => [location];
}

class FetchForecastEvent extends WeatherEvent {
  final Location location;

  const FetchForecastEvent(this.location);

  @override
  List<Object> get props => [location];
}

class ChangeTemperatureUnit extends WeatherEvent {
  final TemperatureUnit unit;

  const ChangeTemperatureUnit(this.unit);

  @override
  List<Object> get props => [unit];
}
