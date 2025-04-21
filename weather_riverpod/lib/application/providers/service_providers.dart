import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_riverpod/data/repositories/weather_repo_impl.dart';
import 'package:weather_shared/weather_shared.dart';

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

/// Provider for the WeatherRepository
final weatherRepositoryProvider = Provider<WeatherRepositoryImpl>((ref) {
  final weatherService = ref.watch(weatherServiceProvider);
  return WeatherRepositoryImpl(weatherService);
});
