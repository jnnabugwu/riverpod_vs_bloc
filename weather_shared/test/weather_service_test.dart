import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weather_shared/weather_shared.dart';

void main() {
  group('WeatherService', () {
    late WeatherService weatherService;
    late MockClient mockClient;
    final testLocation = Location(
      cityName: 'London',
      lat: 51.5074,
      lon: -0.1278,
    );

    setUp(() {
      // Create a mock client that returns successful responses
      mockClient = MockClient((request) async {
        final uri = request.url;

        // Check if the request includes units parameter
        final isMetric = uri.queryParameters['units'] == 'metric';
        final isImperial = uri.queryParameters['units'] == 'imperial';

        // Adjust temperature based on requested units
        final temp = isMetric ? 20.0 : (isImperial ? 68.0 : 293.15);
        final feelsLike = isMetric ? 19.0 : (isImperial ? 66.2 : 292.15);
        final tempMin = isMetric ? 18.0 : (isImperial ? 64.4 : 291.15);
        final tempMax = isMetric ? 22.0 : (isImperial ? 71.6 : 295.15);

        if (uri.path.contains('weather')) {
          return http.Response(
            json.encode({
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

        if (uri.path.contains('forecast')) {
          return http.Response(
            json.encode({
              "list": [
                {
                  "dt": 1710892800, // Unix timestamp for a date
                  "temp": {
                    "min": isMetric ? 18.0 : (isImperial ? 64.4 : 291.15),
                    "max": isMetric ? 25.0 : (isImperial ? 77.0 : 298.15),
                  },
                  "weather": [
                    {"description": "sunny", "icon": "01d"},
                  ],
                },
              ],
            }),
            200,
          );
        }

        if (uri.path.contains('direct')) {
          return http.Response(
            json.encode([
              {"name": "London", "lat": 51.5074, "lon": -0.1278},
            ]),
            200,
          );
        }

        return http.Response('Not found', 404);
      });

      // Initialize the service with the mock client
      weatherService = WeatherService(
        apiKey: 'test-api-key',
        unit: TemperatureUnit.celsius,
        client: mockClient,
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
      final forecast = await weatherService.getForecast(testLocation);

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
      // Create a service with a client that always returns errors
      final errorClient = MockClient((_) async {
        return http.Response('Server error', 500);
      });

      final errorService = WeatherService(
        apiKey: 'test-api-key',
        unit: TemperatureUnit.celsius,
        client: errorClient,
      );

      expect(
        () => errorService.getCurrentWeather(testLocation),
        throwsA(isA<WeatherException>()),
      );
    });

    test('temperature unit conversion works correctly', () async {
      // Test with Fahrenheit
      final fahrenheitService = WeatherService(
        apiKey: 'test-api-key',
        unit: TemperatureUnit.fahrenheit,
        client: mockClient,
      );

      final weather = await fahrenheitService.getCurrentWeather(testLocation);
      expect(weather.temperature, closeTo(68.0, 0.1));
    });
  });
}
