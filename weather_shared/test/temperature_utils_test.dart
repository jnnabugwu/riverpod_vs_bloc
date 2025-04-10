import 'package:flutter_test/flutter_test.dart';
import 'package:weather_shared/weather_shared.dart';

void main() {
  group('TemperatureUtils', () {
    test('converts Kelvin to Celsius correctly', () {
      expect(TemperatureUtils.kelvinToCelsius(273.15), closeTo(0.0, 0.01));
      expect(TemperatureUtils.kelvinToCelsius(373.15), closeTo(100.0, 0.01));
      expect(TemperatureUtils.kelvinToCelsius(0), closeTo(-273.15, 0.01));
    });

    test('converts Kelvin to Fahrenheit correctly', () {
      expect(TemperatureUtils.kelvinToFahrenheit(273.15), closeTo(32.0, 0.01));
      expect(TemperatureUtils.kelvinToFahrenheit(373.15), closeTo(212.0, 0.01));
      expect(TemperatureUtils.kelvinToFahrenheit(0), closeTo(-459.67, 0.01));
    });

    test('converts Celsius to Fahrenheit correctly', () {
      expect(TemperatureUtils.celsiusToFahrenheit(0), closeTo(32.0, 0.01));
      expect(TemperatureUtils.celsiusToFahrenheit(100), closeTo(212.0, 0.01));
      expect(TemperatureUtils.celsiusToFahrenheit(-40), closeTo(-40.0, 0.01));
    });

    test('converts Fahrenheit to Celsius correctly', () {
      expect(TemperatureUtils.fahrenheitToCelsius(32), closeTo(0.0, 0.01));
      expect(TemperatureUtils.fahrenheitToCelsius(212), closeTo(100.0, 0.01));
      expect(TemperatureUtils.fahrenheitToCelsius(-40), closeTo(-40.0, 0.01));
    });
  });

  group('TemperatureUnit', () {
    test('returns correct API parameter', () {
      expect(TemperatureUnit.celsius.apiParameter, equals('metric'));
      expect(TemperatureUnit.fahrenheit.apiParameter, equals('imperial'));
      expect(TemperatureUnit.kelvin.apiParameter, equals(''));
    });

    test('returns correct symbol', () {
      expect(TemperatureUnit.celsius.symbol, equals('°C'));
      expect(TemperatureUnit.fahrenheit.symbol, equals('°F'));
      expect(TemperatureUnit.kelvin.symbol, equals('K'));
    });
  });

  group('Temperature Conversions', () {
    test('convertTemperature handles all unit combinations', () {
      // Test conversion from each unit to every other unit
      final testTemp = 300.0; // 300K = 26.85°C = 80.33°F

      // Kelvin to others
      expect(
        TemperatureUtils.convertTemperature(
          testTemp,
          TemperatureUnit.kelvin,
          TemperatureUnit.celsius,
        ),
        closeTo(26.85, 0.01),
      );

      expect(
        TemperatureUtils.convertTemperature(
          testTemp,
          TemperatureUnit.kelvin,
          TemperatureUnit.fahrenheit,
        ),
        closeTo(80.33, 0.01),
      );

      // Celsius to others
      final celsiusTemp = 25.0; // 25°C = 298.15K = 77°F
      expect(
        TemperatureUtils.convertTemperature(
          celsiusTemp,
          TemperatureUnit.celsius,
          TemperatureUnit.kelvin,
        ),
        closeTo(298.15, 0.01),
      );

      expect(
        TemperatureUtils.convertTemperature(
          celsiusTemp,
          TemperatureUnit.celsius,
          TemperatureUnit.fahrenheit,
        ),
        closeTo(77.0, 0.01),
      );

      // Same unit conversion should return same value
      expect(
        TemperatureUtils.convertTemperature(
          testTemp,
          TemperatureUnit.kelvin,
          TemperatureUnit.kelvin,
        ),
        equals(testTemp),
      );
    });
  });
}
