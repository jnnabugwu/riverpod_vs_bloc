import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:weather_shared/weather_shared.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherService weatherService;

  WeatherBloc({required this.weatherService}) : super(WeatherInitial());

  // TODO: Implement the logic for the WeatherBloc
  // 1. Fetch the current weather
  // 2. Fetch the forecast
  // 3. Change the temperature unit
  // 4. Handle errors
}
