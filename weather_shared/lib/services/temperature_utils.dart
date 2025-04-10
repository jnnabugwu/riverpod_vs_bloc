enum TemperatureUnit {
  celsius,
  fahrenheit,
  kelvin;

  String get symbol {
    switch (this) {
      case TemperatureUnit.celsius:
        return '°C';
      case TemperatureUnit.fahrenheit:
        return '°F';
      case TemperatureUnit.kelvin:
        return 'K';
    }
  }

  String get apiParameter {
    switch (this) {
      case TemperatureUnit.celsius:
        return 'metric';
      case TemperatureUnit.fahrenheit:
        return 'imperial';
      case TemperatureUnit.kelvin:
        return ''; // OpenWeatherMap uses Kelvin by default
    }
  }
}

class TemperatureUtils {
  static double kelvinToCelsius(double kelvin) {
    return kelvin - 273.15;
  }

  static double kelvinToFahrenheit(double kelvin) {
    return (kelvin - 273.15) * 9 / 5 + 32;
  }

  static double celsiusToFahrenheit(double celsius) {
    return celsius * 9 / 5 + 32;
  }

  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  static double convertTemperature(
    double temperature,
    TemperatureUnit from,
    TemperatureUnit to,
  ) {
    if (from == to) return temperature;

    // First convert to Kelvin if not already
    double kelvin;
    switch (from) {
      case TemperatureUnit.kelvin:
        kelvin = temperature;
        break;
      case TemperatureUnit.celsius:
        kelvin = temperature + 273.15;
        break;
      case TemperatureUnit.fahrenheit:
        kelvin = (temperature - 32) * 5 / 9 + 273.15;
        break;
    }

    // Then convert from Kelvin to target unit
    switch (to) {
      case TemperatureUnit.kelvin:
        return kelvin;
      case TemperatureUnit.celsius:
        return kelvinToCelsius(kelvin);
      case TemperatureUnit.fahrenheit:
        return kelvinToFahrenheit(kelvin);
    }
  }
}
