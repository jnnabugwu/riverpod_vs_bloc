import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_shared/weather_shared.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('WeatherService', () {
    late WeatherService weatherService;
    late dio.Dio dioClient;
    late http.Client mockHttpClient;
    final testLocation = Location(
      cityName: 'London',
      lat: 51.5074,
      lon: -0.1278,
    );

    setUp(() {
      // Set up HTTP mock client
      mockHttpClient = MockClient((request) async {
        final uri = Uri.parse(request.url.toString());
        final isMetric = uri.queryParameters['units'] == 'metric';
        final isImperial = uri.queryParameters['units'] == 'imperial';
        final temp = isMetric ? 20.0 : (isImperial ? 68.0 : 293.15);
        final feelsLike = isMetric ? 19.0 : (isImperial ? 66.2 : 292.15);
        final tempMin = isMetric ? 18.0 : (isImperial ? 64.4 : 291.15);
        final tempMax = isMetric ? 22.0 : (isImperial ? 71.6 : 295.15);

        if (uri.path.contains('weather')) {
          return http.Response(
            jsonEncode({
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
            }),
            200,
          );
        }

        if (uri.path.contains('direct')) {
          return http.Response(
            jsonEncode([
              {"name": "London", "lat": 51.5074, "lon": -0.1278},
            ]),
            200,
          );
        }

        return http.Response('Not found', 404);
      });

      // Set up Dio mock client
      dioClient = dio.Dio();
      dioClient.options.baseUrl = 'https://api.openweathermap.org/data/2.5';
      dioClient.interceptors.add(
        dio.InterceptorsWrapper(
          onRequest: (options, handler) async {
            return handler.resolve(
              dio.Response(
                requestOptions: options,
                data: _getMockResponse(
                  options.uri.path,
                  options.queryParameters,
                ),
                statusCode: 200,
              ),
            );
          },
        ),
      );

      weatherService = WeatherService(
        apiKey: 'test-api-key',
        unit: TemperatureUnit.celsius,
        client: mockHttpClient,
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
      expect(forecast.first.tempMax, closeTo(22.0, 0.1));
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
      final errorHttpClient = MockClient((_) async {
        return http.Response('Server error', 500);
      });

      errorDio.interceptors.add(
        dio.InterceptorsWrapper(
          onRequest: (options, handler) async {
            return handler.reject(
              dio.DioException(
                requestOptions: options,
                error: 'Server error',
                response: dio.Response(
                  requestOptions: options,
                  statusCode: 500,
                  data: 'Server error',
                ),
              ),
            );
          },
        ),
      );

      final errorService = WeatherService(
        apiKey: 'test-api-key',
        unit: TemperatureUnit.celsius,
        client: errorHttpClient,
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
        client: mockHttpClient,
        dio: dioClient,
      );

      final weather = await fahrenheitService.getCurrentWeather(testLocation);
      expect(weather.temperature, closeTo(68.0, 0.1));
    });
  });
}

dynamic _getMockResponse(String path, Map<String, dynamic> params) {
  final isMetric = params['units'] == 'metric';
  final isImperial = params['units'] == 'imperial';
  final temp = isMetric ? 20.0 : (isImperial ? 68.0 : 293.15);
  final feelsLike = isMetric ? 19.0 : (isImperial ? 66.2 : 292.15);
  final tempMin = isMetric ? 18.0 : (isImperial ? 64.4 : 291.15);
  final tempMax = isMetric ? 22.0 : (isImperial ? 71.6 : 295.15);

  if (path.contains('forecast')) {
    return {
      "list": [
        {
          "dt": 1710892800,
          "main": {
            "temp": temp,
            "feels_like": feelsLike,
            "temp_min": tempMin,
            "temp_max": tempMax,
            "humidity": 70,
          },
          "weather": [
            {"description": "sunny", "icon": "01d"},
          ],
          "wind": {"speed": 3.5},
        },
      ],
    };
  }

  throw dio.DioException(
    requestOptions: dio.RequestOptions(path: path),
    error: 'Not found',
  );
}
