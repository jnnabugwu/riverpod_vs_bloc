import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;

  const WeatherIcon({super.key, required this.iconCode, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://openweathermap.org/img/wn/$iconCode@2x.png',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          _getFallbackIcon(),
          size: size,
          color: Theme.of(context).colorScheme.primary,
        );
      },
    );
  }

  IconData _getFallbackIcon() {
    // Map OpenWeatherMap icon codes to Material Icons
    switch (iconCode.substring(0, 2)) {
      case '01': // clear sky
        return Icons.wb_sunny;
      case '02': // few clouds
        return Icons.cloud_queue;
      case '03': // scattered clouds
      case '04': // broken clouds
        return Icons.cloud;
      case '09': // shower rain
        return Icons.grain;
      case '10': // rain
        return Icons.beach_access;
      case '11': // thunderstorm
        return Icons.flash_on;
      case '13': // snow
        return Icons.ac_unit;
      case '50': // mist
        return Icons.blur_on;
      default:
        return Icons.wb_sunny;
    }
  }
}
