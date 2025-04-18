import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_shared/weather_shared.dart';
import 'package:dio/dio.dart';

/// Provider for Dio instance
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

/// Provider for the WeatherService
final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService(
    apiKey: const String.fromEnvironment('WEATHER_API_KEY'),
    dio: ref.watch(dioProvider),
  );
});

/// Provider for the LocationService
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
