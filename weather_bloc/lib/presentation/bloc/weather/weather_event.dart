part of 'weather_bloc.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class FetchCurrentWeather extends WeatherEvent {
  final Location location;

  const FetchCurrentWeather(this.location);

  @override
  List<Object> get props => [location];
}

class FetchForecast extends WeatherEvent {
  final Location location;

  const FetchForecast(this.location);

  @override
  List<Object> get props => [location];
}

class ChangeTemperatureUnit extends WeatherEvent {
  final TemperatureUnit unit;

  const ChangeTemperatureUnit(this.unit);

  @override
  List<Object> get props => [unit];
}
