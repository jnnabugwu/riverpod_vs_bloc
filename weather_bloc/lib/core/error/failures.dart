import 'package:equatable/equatable.dart';
import 'package:weather_shared/services/weather_service.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message, required this.statusCode});

  final String message;
  final dynamic statusCode;

  String get errorMessage =>
      '$statusCode${statusCode is String ? '' : ' Error'}: $message';

  @override
  List<dynamic> get props => [message, statusCode];
}

class WeatherFailure extends Failure {
  const WeatherFailure({required super.message})
    : super(statusCode: 'WEATHER_ERROR');

  factory WeatherFailure.fromException(WeatherException exception) {
    return WeatherFailure(message: exception.message);
  }
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message})
    : super(statusCode: 'NETWORK_ERROR');
}

class LocationFailure extends Failure {
  const LocationFailure({required super.message})
    : super(statusCode: 'LOCATION_ERROR');
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message})
    : super(statusCode: 'CACHE_ERROR');
}
