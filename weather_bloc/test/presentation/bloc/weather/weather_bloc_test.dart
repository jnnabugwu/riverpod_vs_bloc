import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_bloc/core/error/failures.dart';
import 'package:weather_bloc/domain/usecases/change_units_usecase.dart';
import 'package:weather_bloc/domain/usecases/fetch_forecast_usecase.dart';
import 'package:weather_bloc/domain/usecases/fetch_weather_usecase.dart';
import 'package:weather_bloc/presentation/bloc/weather/weather_bloc.dart';
import 'package:weather_shared/weather_shared.dart';

class MockFetchWeatherUsecase extends Mock implements FetchWeatherUsecase {}

class MockFetchForecastUsecase extends Mock implements FetchForecastUsecase {}

class MockChangeUnitsUsecase extends Mock implements ChangeUnitsUsecase {}

class MockWeatherService extends Mock implements WeatherService {}

void main() {
  late WeatherBloc weatherBloc;
  late MockFetchWeatherUsecase mockFetchWeatherUsecase;
  late MockFetchForecastUsecase mockFetchForecastUsecase;
  late MockChangeUnitsUsecase mockChangeUnitsUsecase;
  late MockWeatherService mockWeatherService;

  setUp(() {
    mockFetchWeatherUsecase = MockFetchWeatherUsecase();
    mockFetchForecastUsecase = MockFetchForecastUsecase();
    mockChangeUnitsUsecase = MockChangeUnitsUsecase();
    mockWeatherService = MockWeatherService();

    weatherBloc = WeatherBloc(
      mockFetchWeatherUsecase,
      mockFetchForecastUsecase,
      mockChangeUnitsUsecase,
      weatherService: mockWeatherService,
    );
  });

  tearDown(() {
    weatherBloc.close();
  });

  final tLocation = Location(cityName: 'Test City', lat: 1.0, lon: 1.0);
  final tWeather = Weather(
    temperature: 20.0,
    feelsLike: 19.0,
    tempMin: 18.0,
    tempMax: 22.0,
    description: 'clear sky',
    humidity: 50.0,
    windSpeed: 10.0,
    iconCode: '01d',
  );
  final tForecast = [
    ForecastDay(
      date: DateTime.now(),
      tempMax: 25.0,
      tempMin: 15.0,
      description: 'sunny',
      iconCode: '01d',
    ),
  ];

  test('initial state should be WeatherInitial', () {
    expect(weatherBloc.state, isA<WeatherInitial>());
  });

  group('FetchWeather', () {
    blocTest<WeatherBloc, WeatherState>(
      'emits [WeatherLoading, WeatherLoaded] when fetching weather succeeds',
      build: () {
        when(
          () => mockFetchWeatherUsecase(tLocation),
        ).thenAnswer((_) async => Right(tWeather));
        return weatherBloc;
      },
      act: (bloc) => bloc.add(FetchWeatherEvent(tLocation)),
      expect:
          () => [
            isA<WeatherLoading>(),
            isA<WeatherLoaded>().having(
              (state) => state.weather,
              'weather',
              tWeather,
            ),
          ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'emits [WeatherLoading, WeatherError] when fetching weather fails',
      build: () {
        when(() => mockFetchWeatherUsecase(tLocation)).thenAnswer(
          (_) async => Left(WeatherFailure(message: 'Error fetching weather')),
        );
        return weatherBloc;
      },
      act: (bloc) => bloc.add(FetchWeatherEvent(tLocation)),
      expect:
          () => [
            isA<WeatherLoading>(),
            isA<WeatherError>().having(
              (state) => state.message,
              'message',
              'Error fetching weather',
            ),
          ],
    );
  });

  group('FetchForecast', () {
    blocTest<WeatherBloc, WeatherState>(
      'emits [WeatherLoading, WeatherForecastLoaded] when fetching forecast succeeds',
      build: () {
        when(
          () => mockFetchForecastUsecase(tLocation),
        ).thenAnswer((_) async => Right(tForecast));
        return weatherBloc;
      },
      act: (bloc) => bloc.add(FetchForecastEvent(tLocation)),
      expect:
          () => [
            isA<WeatherLoading>(),
            isA<WeatherForecastLoaded>().having(
              (state) => state.forecast,
              'forecast',
              tForecast,
            ),
          ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'emits [WeatherLoading, WeatherError] when fetching forecast fails',
      build: () {
        when(() => mockFetchForecastUsecase(tLocation)).thenAnswer(
          (_) async => Left(WeatherFailure(message: 'Error fetching forecast')),
        );
        return weatherBloc;
      },
      act: (bloc) => bloc.add(FetchForecastEvent(tLocation)),
      expect:
          () => [
            isA<WeatherLoading>(),
            isA<WeatherError>().having(
              (state) => state.message,
              'message',
              'Error fetching forecast',
            ),
          ],
    );
  });

  group('ChangeTemperatureUnit', () {
    blocTest<WeatherBloc, WeatherState>(
      'emits [WeatherUnitsChanged] when changing units succeeds',
      build: () {
        when(
          () => mockChangeUnitsUsecase(TemperatureUnit.celsius),
        ).thenAnswer((_) async => Right(TemperatureUnit.celsius));
        return weatherBloc;
      },
      act: (bloc) => bloc.add(ChangeTemperatureUnit(TemperatureUnit.celsius)),
      expect:
          () => [
            isA<WeatherUnitsChanged>().having(
              (state) => state.unit,
              'unit',
              TemperatureUnit.celsius,
            ),
          ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'emits [WeatherError] when changing units fails',
      build: () {
        when(() => mockChangeUnitsUsecase(TemperatureUnit.celsius)).thenAnswer(
          (_) async => Left(WeatherFailure(message: 'Error changing units')),
        );
        return weatherBloc;
      },
      act: (bloc) => bloc.add(ChangeTemperatureUnit(TemperatureUnit.celsius)),
      expect:
          () => [
            isA<WeatherError>().having(
              (state) => state.message,
              'message',
              'Error changing units',
            ),
          ],
    );
  });
}
