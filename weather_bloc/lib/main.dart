import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_bloc/core/utils/injection.dart' as di;
import 'package:weather_bloc/presentation/bloc/location/location_bloc.dart';
import 'package:weather_bloc/presentation/bloc/weather/weather_bloc.dart';
import 'package:weather_shared/weather_shared.dart';
import 'package:weather_bloc/presentation/pages/forecast_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.getIt<LocationBloc>()..add(GetCurrentLocation()),
        ),
        BlocProvider(create: (_) => di.getIt<WeatherBloc>()),
      ],
      child: MaterialApp(
        title: 'Weather App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Weather App'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForecastPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<LocationBloc>().add(GetCurrentLocation());
            },
          ),
        ],
      ),
      body: BlocListener<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is LocationLoaded) {
            context.read<WeatherBloc>().onLocationChanged(state.location);
          }
        },
        child: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            if (state is LocationLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is LocationError) {
              return Center(child: Text(state.message));
            }
            if (state is LocationLoaded) {
              return BlocBuilder<WeatherBloc, WeatherState>(
                builder: (context, weatherState) {
                  if (weatherState is WeatherLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (weatherState is WeatherError) {
                    return Center(child: Text(weatherState.message));
                  }
                  if (weatherState is WeatherLoaded) {
                    final currentUnit =
                        context.read<WeatherBloc>().weatherService.currentUnit;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              state.location.cityName,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            WeatherIcon(
                              iconCode: weatherState.weather.iconCode,
                              size: 100,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${weatherState.weather.temperature.toStringAsFixed(1)}${currentUnit.symbol}',
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              weatherState.weather.description,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildWeatherDetail(
                                  context,
                                  Icons.thermostat,
                                  'Feels like',
                                  '${weatherState.weather.feelsLike.toStringAsFixed(1)}${currentUnit.symbol}',
                                ),
                                _buildWeatherDetail(
                                  context,
                                  Icons.water_drop,
                                  'Humidity',
                                  '${weatherState.weather.humidity}%',
                                ),
                                _buildWeatherDetail(
                                  context,
                                  Icons.air,
                                  'Wind',
                                  '${weatherState.weather.windSpeed} m/s',
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Min: ${weatherState.weather.tempMin.toStringAsFixed(1)}${currentUnit.symbol}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Max: ${weatherState.weather.tempMax.toStringAsFixed(1)}${currentUnit.symbol}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                final newUnit =
                                    currentUnit == TemperatureUnit.celsius
                                        ? TemperatureUnit.fahrenheit
                                        : TemperatureUnit.celsius;
                                context.read<WeatherBloc>().add(
                                  ChangeTemperatureUnit(newUnit),
                                );
                              },
                              icon: const Icon(Icons.thermostat),
                              label: Text(
                                'Switch to ${currentUnit == TemperatureUnit.celsius ? 'Fahrenheit' : 'Celsius'}',
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (weatherState.forecast != null)
                              WeatherForecast(
                                forecast: weatherState.forecast!,
                                unit: currentUnit,
                              ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const Center(child: Text('No weather data'));
                },
              );
            }
            return const Center(child: Text('No location data'));
          },
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
