import 'package:flutter/material.dart';
import 'package:weather_riverpod/presentation/pages/forecast_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Weather App'),
      ),
      body: const Center(child: Text('Welcome to Weather App')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ForecastPage()),
          );
        },
        child: const Icon(Icons.cloud),
      ),
    );
  }
}
