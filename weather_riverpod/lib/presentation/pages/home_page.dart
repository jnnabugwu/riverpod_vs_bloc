import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_riverpod/application/providers/weather_provider.dart';
import 'package:weather_riverpod/application/providers/location_provider.dart';
import 'package:weather_riverpod/presentation/pages/forecast_page.dart';
import 'package:weather_shared/weather_shared.dart';

/// A page that displays the current weather and forecast data.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherProvider);
    final locationState = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(weatherProvider.notifier).fetchWeather(),
          ),
          IconButton(
            icon: const Icon(Icons.thermostat),
            onPressed:
                () =>
                    ref.read(weatherProvider.notifier).toggleTemperatureUnit(),
          ),
        ],
      ),
      body: weatherState.when(
        data: (weatherData) {
          if (weatherData == null) {
            return const Center(child: Text('No weather data available'));
          }

          final currentWeather = weatherData.currentWeather;
          final forecast = weatherData.forecast;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Location Display
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: locationState.when(
                    data: (location) {
                      if (location == null) {
                        return const Text(
                          'Location not available',
                          style: TextStyle(fontSize: 18),
                        );
                      }
                      return Text(
                        location.cityName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error:
                        (error, stack) => Text(
                          'Error: ${error.toString()}',
                          style: const TextStyle(color: Colors.red),
                        ),
                  ),
                ),
                // Current Weather Card
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        WeatherIcon(
                          iconCode: currentWeather.iconCode,
                          size: 100,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${currentWeather.temperature.toStringAsFixed(1)}°',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentWeather.description,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildWeatherDetail(
                              context,
                              'Feels Like',
                              '${currentWeather.feelsLike.toStringAsFixed(1)}°',
                            ),
                            _buildWeatherDetail(
                              context,
                              'Humidity',
                              '${currentWeather.humidity}%',
                            ),
                            _buildWeatherDetail(
                              context,
                              'Wind',
                              '${currentWeather.windSpeed} km/h',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Forecast Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '5-Day Forecast',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForecastPage(),
                            ),
                          );
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 170,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: forecast.length,
                    itemBuilder: (context, index) {
                      final day = forecast[index];
                      return _buildForecastItem(context, day);
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(child: Text('Error: ${error.toString()}')),
      ),
    );
  }

  Widget _buildWeatherDetail(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }

  Widget _buildForecastItem(BuildContext context, ForecastDay day) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getDayName(day.date),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 2),
              WeatherIcon(iconCode: day.iconCode, size: 32),
              const SizedBox(height: 2),
              Text(
                '${day.tempMax.toStringAsFixed(1)}°',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                '${day.tempMin.toStringAsFixed(1)}°',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayName(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
