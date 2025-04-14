import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_shared/weather_shared.dart';
import 'package:dio/dio.dart' as dio;

void main() {
  group('WeatherService', () {
    late WeatherService weatherService;
    late dio.Dio dioClient;
    final testLocation = Location(
      cityName: 'London',
      lat: 51.5074,
      lon: -0.1278,
    );

    setUp(() {
      dioClient = dio.Dio();
      dioClient.interceptors.add(
        dio.InterceptorsWrapper(
          onRequest: (options, handler) async {
            final uri = options.uri;
            final isMetric = uri.queryParameters['units'] == 'metric';
            final isImperial = uri.queryParameters['units'] == 'imperial';
            final temp = isMetric ? 20.0 : (isImperial ? 68.0 : 293.15);
            final feelsLike = isMetric ? 19.0 : (isImperial ? 66.2 : 292.15);
            final tempMin = isMetric ? 18.0 : (isImperial ? 64.4 : 291.15);
            final tempMax = isMetric ? 22.0 : (isImperial ? 71.6 : 295.15);

            if (uri.path.contains('weather')) {
              return handler.resolve(
                dio.Response(
                  requestOptions: options,
                  data: {
                    "weather": [
                      {"description": "clear sky", "icon": "01d"},
                    ],
                    "main": {
                      "temp": temp,
                      "feels_like": feelsLike,
                      "temp_min": tempMin,
                      "temp_max": tempMax,
                      "humidity": 70,
                    },
                    "wind": {"speed": 3.5},
                  },
                ),
              );
            }

            if (uri.path.contains('forecast')) {
              return handler.resolve(
                dio.Response(
                  requestOptions: options,
                  data: {
                    "list": [
                      {
                        "dt": 1710892800,
                        "temp": {
                          "min": isMetric ? 18.0 : (isImperial ? 64.4 : 291.15),
                          "max": isMetric ? 25.0 : (isImperial ? 77.0 : 298.15),
                        },
                        "weather": [
                          {"description": "sunny", "icon": "01d"},
                        ],
                      },
                    ],
                  },
                ),
              );
            }

            if (uri.path.contains('direct')) {
              return handler.resolve(
                dio.Response(
                  requestOptions: options,
                  data: [
                    {"name": "London", "lat": 51.5074, "lon": -0.1278},
                  ],
                ),
              );
            }

            return handler.reject(
              dio.DioException(requestOptions: options, error: 'Not found'),
            );
          },
        ),
      );

      weatherService = WeatherService(
        apiKey: 'test-api-key',
        unit: TemperatureUnit.celsius,
        dio: dioClient,
      );
    });

    test('getCurrentWeather returns weather data', () async {
      final weather = await weatherService.getCurrentWeather(testLocation);

      expect(weather, isNotNull);
      expect(weather.temperature, closeTo(20.0, 0.1));
      expect(weather.description, equals('clear sky'));
      expect(weather.iconCode, equals('01d'));
    });

    test('getForecast returns forecast data', () async {
      final forecast = await weatherService.getForecast(
        testLocation.lat,
        testLocation.lon,
      );

      expect(forecast, isNotNull);
      expect(forecast.length, equals(1));
      expect(forecast.first.description, equals('sunny'));
      expect(forecast.first.iconCode, equals('01d'));
      expect(forecast.first.tempMin, closeTo(18.0, 0.1));
      expect(forecast.first.tempMax, closeTo(25.0, 0.1));
    });

    test('searchLocation returns location data', () async {
      final locations = await weatherService.searchLocation('London');

      expect(locations, isNotNull);
      expect(locations.length, equals(1));
      expect(locations.first.cityName, equals('London'));
      expect(locations.first.lat, equals(51.5074));
      expect(locations.first.lon, equals(-0.1278));
    });

    test('handles API errors appropriately', () async {
      final errorDio = dio.Dio();
      errorDio.interceptors.add(
        dio.InterceptorsWrapper(
          onRequest: (options, handler) async {
            return handler.reject(
              dio.DioException(requestOptions: options, error: 'Server error'),
            );
          },
        ),
      );

      final errorService = WeatherService(
        apiKey: 'test-api-key',
        unit: TemperatureUnit.celsius,
        dio: errorDio,
      );

      expect(
        () => errorService.getCurrentWeather(testLocation),
        throwsA(isA<WeatherException>()),
      );
    });

    test('temperature unit conversion works correctly', () async {
      final fahrenheitService = WeatherService(
        apiKey: 'test-api-key',
        unit: TemperatureUnit.fahrenheit,
        dio: dioClient,
      );

      final weather = await fahrenheitService.getCurrentWeather(testLocation);
      expect(weather.temperature, closeTo(68.0, 0.1));
    });
  });
}
