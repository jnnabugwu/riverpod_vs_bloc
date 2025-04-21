// ignore_for_file: lines_longer_than_80_chars

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_riverpod/application/providers/service_providers.dart';
import 'package:weather_riverpod/data/repositories/weather_repo_impl.dart';
import 'package:weather_shared/weather_shared.dart';

class MockDio extends Mock implements Dio {}

class MockWeatherService extends Mock implements WeatherService {}

class MockLocationService extends Mock implements LocationService {}

void main() {
  late ProviderContainer container;
  late MockDio mockDio;
  late MockWeatherService mockWeatherService;
  late MockLocationService mockLocationService;

  setUp(() {
    mockDio = MockDio();
    mockWeatherService = MockWeatherService();
    mockLocationService = MockLocationService();

    // Setup default behavior for mocks
    when(() => mockDio.options).thenReturn(BaseOptions());
    when(() => mockWeatherService.currentUnit)
        .thenReturn(TemperatureUnit.celsius);

    container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(mockDio),
        weatherServiceProvider.overrideWithValue(mockWeatherService),
        locationServiceProvider.overrideWithValue(mockLocationService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ServiceProviders', () {
    test('dioProvider should provide the correct Dio instance', () {
      final dio = container.read(dioProvider);
      expect(dio, equals(mockDio));
      verifyNever(() => mockDio.options); // Verify no unexpected calls
    });

    test(
        'weatherServiceProvider should provide the correct WeatherService instance',
        () {
      final weatherService = container.read(weatherServiceProvider);
      expect(weatherService, equals(mockWeatherService));
      expect(weatherService.currentUnit, equals(TemperatureUnit.celsius));
    });

    test(
        'locationServiceProvider should provide the correct LocationService instance',
        () {
      final locationService = container.read(locationServiceProvider);
      expect(locationService, equals(mockLocationService));
    });

    test(
        'weatherRepositoryProvider should provide a WeatherRepositoryImpl instance',
        () {
      final repository = container.read(weatherRepositoryProvider);
      expect(repository, isA<WeatherRepositoryImpl>());
    });

    test('weatherRepositoryProvider should use the provided WeatherService',
        () async {
      // Arrange
      final location = Location(cityName: 'Test', lat: 0, lon: 0);
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

      when(() => mockWeatherService.getCurrentWeather(location))
          .thenAnswer((_) async => weather);

      // Act
      final repository = container.read(weatherRepositoryProvider);
      final result = await repository.getCurrentWeather(location);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('Should not return left'),
        (r) => expect(r, equals(weather)),
      );
      verify(() => mockWeatherService.getCurrentWeather(location)).called(1);
    });

    test('weatherServiceProvider should use the provided Dio instance', () {
      // Arrange
      final testContainer = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(mockDio),
        ],
      );

      // Act
      final weatherService = testContainer.read(weatherServiceProvider);

      // Assert
      expect(weatherService, isA<WeatherService>());
      verify(() => mockDio.options).called(1);

      testContainer.dispose();
    });
  });
}
