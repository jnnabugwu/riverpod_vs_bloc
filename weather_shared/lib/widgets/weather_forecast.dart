import 'package:flutter/material.dart';
import 'package:weather_shared/weather_shared.dart';

class WeatherForecast extends StatelessWidget {
  final List<ForecastDay> forecast;
  final TemperatureUnit unit;

  const WeatherForecast({
    super.key,
    required this.forecast,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '5-Day Forecast',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: forecast.length,
            itemBuilder: (context, index) {
              final day = forecast[index];
              return Container(
                width: 120,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      _getDayOfWeek(day.date),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    WeatherIcon(iconCode: day.iconCode, size: 40),
                    Text(
                      '${day.tempMax.toStringAsFixed(1)}${unit.symbol}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${day.tempMin.toStringAsFixed(1)}${unit.symbol}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      day.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
}
