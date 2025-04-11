import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_bloc/core/utils/injection.dart' as di;
import 'package:weather_bloc/presentation/bloc/location/location_bloc.dart';
import 'package:weather_bloc/presentation/bloc/weather/weather_bloc.dart';

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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Location: ${state.location.cityName}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Temperature: ${weatherState.weather.temperature}°C',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
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
}
