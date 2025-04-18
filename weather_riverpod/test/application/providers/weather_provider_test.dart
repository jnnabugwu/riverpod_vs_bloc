import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_riverpod/application/providers/location_provider.dart';
import 'package:weather_riverpod/application/providers/weather_provider.dart';
import 'package:weather_riverpod/data/repositories/weather_repo_impl.dart';
import 'package:weather_shared/weather_shared.dart';
import 'package:dio/dio.dart';

class MockWeatherService extends Mock implements WeatherService {}

class MockLocation extends Mock implements Location {}

class TestWeatherNotifier extends WeatherNotifier {
  TestWeatherNotifier(this._mockRepository);
  final WeatherRepositoryImpl _mockRepository;

  WeatherRepositoryImpl get _repository => _mockRepository;
}

class TestLocationNotifier extends LocationNotifier {
  @override
  Future<Location?> build() async => MockLocation();
}

void main() {
  late MockWeatherService mockWeatherService;
  late MockLocation mockLocation;
  late ProviderContainer container;
  late WeatherRepositoryImpl mockRepository;

  setUp(() {
    mockWeatherService = MockWeatherService();
    mockLocation = MockLocation();
    mockRepository = WeatherRepositoryImpl(mockWeatherService);

    when(() => mockLocation.lat).thenReturn(51.5074);
    when(() => mockLocation.lon).thenReturn(-0.1278);
    when(() => mockLocation.cityName).thenReturn('London');

    container = ProviderContainer(
      overrides: [
        locationProvider.overrideWith(() => TestLocationNotifier()),
        weatherProvider.overrideWith(() => TestWeatherNotifier(mockRepository)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('WeatherProvider', () {
    test('initial state is AsyncLoading', () {
      final state = container.read(weatherProvider);
      expect(state, const AsyncValue<WeatherData?>.loading());
    });

    test('fetchWeather updates state with weather data', () async {
      // Arrange
      final weather = Weather(
        temperature: 20.0,
        feelsLike: 19.0,
        tempMin: 18.0,
        tempMax: 22.0,
        description: 'Sunny',
        humidity: 50.0,
        windSpeed: 10.0,
        iconCode: '01d',
      );
      final forecast = [
        ForecastDay(
          date: DateTime.now(),
          tempMax: 22.0,
          tempMin: 18.0,
          description: 'Sunny',
          iconCode: '01d',
        ),
      ];

      when(() => mockWeatherService.getCurrentWeather(any()))
          .thenAnswer((_) async => weather);
      when(() => mockWeatherService.getForecast(any(), any()))
          .thenAnswer((_) async => forecast);

      // Act
      await container.read(weatherProvider.notifier).fetchWeather();

      // Assert
      final state = container.read(weatherProvider);
      expect(
        state.value,
        isA<WeatherData>()
            .having((w) => w.currentWeather, 'currentWeather', weather)
            .having((w) => w.forecast, 'forecast', forecast),
      );
    });

    test('fetchWeather handles errors', () async {
      // Arrange
      when(() => mockWeatherService.getCurrentWeather(any()))
          .thenThrow(Exception('Failed to fetch weather'));
      when(() => mockWeatherService.getForecast(any(), any()))
          .thenThrow(Exception('Failed to fetch forecast'));

      // Act
      await container.read(weatherProvider.notifier).fetchWeather();

      // Assert
      final state = container.read(weatherProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<Exception>());
    });

    test('toggleTemperatureUnit updates the unit', () {
      // Arrange
      when(() => mockWeatherService.setTemperatureUnit(any())).thenReturn(null);

      // Act
      final notifier = container.read(weatherProvider.notifier);
      notifier.toggleTemperatureUnit();

      // Assert
      expect(notifier.currentUnit, equals(TemperatureUnit.fahrenheit));
      verify(() =>
              mockWeatherService.setTemperatureUnit(TemperatureUnit.fahrenheit))
          .called(1);
    });
  });
}
