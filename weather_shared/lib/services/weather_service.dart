import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../models/forecast.dart';
import '../models/location.dart';
import 'temperature_utils.dart';

class WeatherService {
  final String apiKey;
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';
  TemperatureUnit _unit;
  final http.Client _client;

  TemperatureUnit get currentUnit => _unit;

  WeatherService({
    required this.apiKey,
    TemperatureUnit unit = TemperatureUnit.celsius,
    http.Client? client,
  }) : _unit = unit,
       _client = client ?? http.Client();

  /// Changes the temperature unit for future API calls
  void setTemperatureUnit(TemperatureUnit unit) {
    _unit = unit;
  }

  Future<Weather> getCurrentWeather(Location location) async {
    final unitParam = _unit.apiParameter;
    final url =
        '$baseUrl/weather?lat=${location.lat}&lon=${location.lon}&appid=$apiKey${unitParam.isNotEmpty ? '&units=$unitParam' : ''}';

    try {
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // If we're using Kelvin (no units parameter), we need to convert the temperatures
        if (_unit != TemperatureUnit.kelvin && unitParam.isEmpty) {
          _convertJsonTemperatures(json, TemperatureUnit.kelvin, _unit);
        }
        return Weather.fromJson(json);
      } else {
        throw WeatherException(
          'Failed to fetch weather data: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw WeatherException('Error fetching weather data: $e');
    }
  }

  Future<List<ForecastDay>> getForecast(Location location) async {
    final unitParam = _unit.apiParameter;
    final url =
        '$baseUrl/forecast/daily?lat=${location.lat}&lon=${location.lon}&appid=$apiKey${unitParam.isNotEmpty ? '&units=$unitParam' : ''}&cnt=5';

    try {
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (_unit != TemperatureUnit.kelvin && unitParam.isEmpty) {
          for (var day in data['list']) {
            _convertJsonTemperatures(day, TemperatureUnit.kelvin, _unit);
          }
        }
        return (data['list'] as List)
            .map((day) => ForecastDay.fromJson(day))
            .toList();
      } else {
        throw WeatherException(
          'Failed to fetch forecast data: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw WeatherException('Error fetching forecast data: $e');
    }
  }

  /// Converts temperature values in a JSON object from one unit to another
  void _convertJsonTemperatures(
    Map<String, dynamic> json,
    TemperatureUnit from,
    TemperatureUnit to,
  ) {
    if (json.containsKey('main')) {
      final main = json['main'] as Map<String, dynamic>;
      main['temp'] = TemperatureUtils.convertTemperature(
        main['temp'].toDouble(),
        from,
        to,
      );
      main['feels_like'] = TemperatureUtils.convertTemperature(
        main['feels_like'].toDouble(),
        from,
        to,
      );
      main['temp_min'] = TemperatureUtils.convertTemperature(
        main['temp_min'].toDouble(),
        from,
        to,
      );
      main['temp_max'] = TemperatureUtils.convertTemperature(
        main['temp_max'].toDouble(),
        from,
        to,
      );
    } else if (json.containsKey('temp')) {
      // For forecast data
      if (json['temp'] is Map) {
        final temp = json['temp'] as Map<String, dynamic>;
        temp['min'] = TemperatureUtils.convertTemperature(
          temp['min'].toDouble(),
          from,
          to,
        );
        temp['max'] = TemperatureUtils.convertTemperature(
          temp['max'].toDouble(),
          from,
          to,
        );
      } else {
        json['temp'] = TemperatureUtils.convertTemperature(
          json['temp'].toDouble(),
          from,
          to,
        );
      }
    }
  }

  Future<List<Location>> searchLocation(String query) async {
    final url =
        'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey';

    try {
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> locations = json.decode(response.body);
        return locations
            .map((location) => Location.fromJson(location))
            .toList();
      } else {
        throw WeatherException(
          'Failed to fetch locations: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw WeatherException('Error searching locations: $e');
    }
  }
}

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);

  @override
  String toString() => message;
}
