import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_riverpod/application/providers/location_provider.dart';
import 'package:weather_riverpod/application/providers/service_providers.dart';
import 'package:weather_riverpod/application/providers/weather_provider.dart';
import 'package:weather_riverpod/core/error/failures.dart';
import 'package:weather_riverpod/data/repositories/weather_repo_impl.dart';
import 'package:weather_shared/weather_shared.dart';

class MockWeatherRepositoryImpl extends Mock implements WeatherRepositoryImpl {}

class MockLocation extends Mock implements Location {}

// Override the location notifier for testing
class TestLocationNotifier extends LocationNotifier {
  @override
  Future<Location?> build() async => MockLocation();
}

void main() {
  late MockWeatherRepositoryImpl mockRepository;
  late MockLocation mockLocation;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      Location(
        cityName: 'Test City',
        lat: 0,
        lon: 0,
      ),
    );
    registerFallbackValue(TemperatureUnit.celsius);
  });

  setUp(() {
    mockRepository = MockWeatherRepositoryImpl();
    mockLocation = MockLocation();

    when(() => mockLocation.lat).thenReturn(51.5074);
    when(() => mockLocation.lon).thenReturn(-0.1278);
    when(() => mockLocation.cityName).thenReturn('London');

    // Create a test provider container with overrides
    container = ProviderContainer(
      overrides: [
        // Override the location provider
        locationProvider.overrideWith(() => TestLocationNotifier()),

        // Override the weather repository provider with our mock
        weatherRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('WeatherProvider', () {
    test('initial state should be loading', () {
      final state = container.read(weatherProvider);
      expect(state, isA<AsyncLoading>());
    });

    test('fetchWeather updates state with weather data', () async {
      // Arrange
      final weather = Weather(
        temperature: 20,
        feelsLike: 19,
        tempMin: 18,
        tempMax: 22,
        description: 'Sunny',
        humidity: 50,
        windSpeed: 10,
        iconCode: '01d',
      );
      final forecast = [
        ForecastDay(
          date: DateTime.now(),
          tempMax: 22,
          tempMin: 18,
          description: 'Sunny',
          iconCode: '01d',
        ),
      ];

      when(() => mockRepository.getCurrentWeather(any()))
          .thenAnswer((_) async => Right(weather));
      when(() => mockRepository.getWeatherForecast(any()))
          .thenAnswer((_) async => Right(forecast));
      when(() => mockRepository.setTemperatureUnit(any())).thenReturn(null);

      // Act
      await container.read(weatherProvider.notifier).fetchWeather();

      // Assert
      final state = container.read(weatherProvider);
      expect(state.hasValue, isTrue);
      expect(
        state.value,
        isA<WeatherData>()
            .having((w) => w.currentWeather, 'currentWeather', weather)
            .having((w) => w.forecast, 'forecast', forecast),
      );
    });

    test('fetchWeather handles errors correctly', () async {
      // Arrange
      when(() => mockRepository.getCurrentWeather(any())).thenAnswer(
        (_) async => const Left(WeatherFailure(message: 'API Error')),
      );
      when(() => mockRepository.getWeatherForecast(any())).thenAnswer(
        (_) async => const Left(WeatherFailure(message: 'API Error')),
      );

      // Act
      await container.read(weatherProvider.notifier).fetchWeather();

      // Assert
      final state = container.read(weatherProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<Exception>());
      expect(state.error.toString(), contains('API Error'));
    });

    test('toggleTemperatureUnit switches between Celsius and Fahrenheit',
        () async {
      // Arrange
      when(() => mockRepository.setTemperatureUnit(any())).thenReturn(null);
      when(() => mockRepository.getCurrentWeather(any())).thenAnswer(
        (_) async => Right(Weather(
          temperature: 20,
          feelsLike: 19,
          tempMin: 18,
          tempMax: 22,
          description: 'Sunny',
          humidity: 50,
          windSpeed: 10,
          iconCode: '01d',
        )),
      );
      when(() => mockRepository.getWeatherForecast(any())).thenAnswer(
        (_) async => Right([
          ForecastDay(
            date: DateTime.now(),
            tempMax: 22,
            tempMin: 18,
            description: 'Sunny',
            iconCode: '01d',
          ),
        ]),
      );

      // Act
      final notifier = container.read(weatherProvider.notifier);

      // Initial unit should be Celsius
      expect(notifier.currentUnit, equals(TemperatureUnit.celsius));

      // Toggle to Fahrenheit
      notifier.toggleTemperatureUnit();

      // Assert
      expect(notifier.currentUnit, equals(TemperatureUnit.fahrenheit));
      verify(() =>
              mockRepository.setTemperatureUnit(TemperatureUnit.fahrenheit))
          .called(1);

      // Toggle back to Celsius
      notifier.toggleTemperatureUnit();

      // Assert
      expect(notifier.currentUnit, equals(TemperatureUnit.celsius));
      verify(() => mockRepository.setTemperatureUnit(TemperatureUnit.celsius))
          .called(1);
    });
  });
}
