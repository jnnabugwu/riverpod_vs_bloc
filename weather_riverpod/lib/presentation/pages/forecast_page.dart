import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_riverpod/application/providers/weather_provider.dart';
import 'package:weather_shared/weather_shared.dart';

/// A page that displays a 5-day weather forecast.
class ForecastPage extends ConsumerWidget {
  const ForecastPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('5-Day Forecast'),
      ),
      body: weatherState.when(
        data: (weatherData) {
          if (weatherData == null || weatherData.forecast.isEmpty) {
            return const Center(child: Text('No forecast data available'));
          }

          final currentUnit = ref.read(weatherProvider.notifier).currentUnit;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: weatherData.forecast.length,
            itemBuilder: (context, index) {
              final day = weatherData.forecast[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      WeatherIcon(iconCode: day.iconCode, size: 64),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(day.date),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              day.description,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                Text(
                                  ' ${day.tempMax.toStringAsFixed(1)}${currentUnit.symbol}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.arrow_downward,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                Text(
                                  ' ${day.tempMin.toStringAsFixed(1)}${currentUnit.symbol}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    return '${_getDayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)}';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
}
