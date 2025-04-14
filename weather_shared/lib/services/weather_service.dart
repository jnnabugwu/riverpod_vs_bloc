import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../models/forecast.dart';
import '../models/location.dart';
import 'temperature_utils.dart';
import 'package:dio/dio.dart';

class WeatherService {
  final String apiKey;
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';
  TemperatureUnit _unit;
  final http.Client _client;
  final Dio _dio;

  TemperatureUnit get currentUnit => _unit;

  WeatherService({
    required this.apiKey,
    TemperatureUnit unit = TemperatureUnit.celsius,
    http.Client? client,
    required Dio dio,
  }) : _unit = unit,
       _client = client ?? http.Client(),
       _dio = dio {
    _dio.options.baseUrl = baseUrl;
  }

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

  Future<List<ForecastDay>> getForecast(double lat, double lon) async {
    final response = await _dio.get(
      '/forecast',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'appid': apiKey,
        'units': _unit == TemperatureUnit.celsius ? 'metric' : 'imperial',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch forecast');
    }

    final List<dynamic> list = response.data['list'];

    // Group forecasts by day
    final Map<String, List<Map<String, dynamic>>> groupedForecasts = {};

    for (var item in list) {
      final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dayKey = '${date.year}-${date.month}-${date.day}';

      if (!groupedForecasts.containsKey(dayKey)) {
        groupedForecasts[dayKey] = [];
      }
      groupedForecasts[dayKey]!.add(item);
    }

    // For each day, select the forecast closest to noon
    final List<ForecastDay> forecasts =
        groupedForecasts.values
            .map((dayForecasts) {
              return dayForecasts
                  .map(
                    (f) => MapEntry(
                      DateTime.fromMillisecondsSinceEpoch(f['dt'] * 1000),
                      f,
                    ),
                  )
                  .reduce((a, b) {
                    final aNoon = (a.key.hour - 12).abs();
                    final bNoon = (b.key.hour - 12).abs();
                    return aNoon < bNoon ? a : b;
                  })
                  .value;
            })
            .map((json) => ForecastDay.fromJson(json))
            .take(5)
            .toList();

    return forecasts;
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
