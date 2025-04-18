// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_riverpod/application/providers/service_providers.dart';
import 'package:weather_riverpod/main.dart';
import 'package:weather_shared/weather_shared.dart';

class MockWeatherService extends Mock implements WeatherService {}

class MockLocationService extends Mock implements LocationService {}

void main() {
  late MockWeatherService mockWeatherService;
  late MockLocationService mockLocationService;
  late ProviderContainer container;

  setUp(() {
    mockWeatherService = MockWeatherService();
    mockLocationService = MockLocationService();
    container = ProviderContainer(
      overrides: [
        weatherServiceProvider.overrideWithValue(mockWeatherService),
        locationServiceProvider.overrideWithValue(mockLocationService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  testWidgets('HomePage smoke test', (WidgetTester tester) async {
    // Mock the initial weather data
    final tWeather = Weather(
      temperature: 20.0,
      feelsLike: 19.0,
      tempMin: 18.0,
      tempMax: 22.0,
      description: 'clear sky',
      humidity: 50.0,
      windSpeed: 10.0,
      iconCode: '01d',
    );
    final tForecast = [
      ForecastDay(
        date: DateTime.now(),
        tempMax: 25.0,
        tempMin: 15.0,
        description: 'sunny',
        iconCode: '01d',
      ),
    ];
    final tLocation = Location(cityName: 'Test City', lat: 1.0, lon: 1.0);

    when(() => mockWeatherService.getCurrentWeather(any()))
        .thenAnswer((_) async => tWeather);
    when(() => mockWeatherService.getForecast(any(), any()))
        .thenAnswer((_) async => tForecast);
    when(() => mockLocationService.getCurrentLocation())
        .thenAnswer((_) async => tLocation);

    // Build our app and trigger a frame
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MyApp(),
      ),
    );

    // Verify that the app title is displayed
    expect(find.text('Weather App'), findsOneWidget);

    // Verify that the location is displayed
    expect(find.text('Test City'), findsOneWidget);

    // Verify that the current weather is displayed
    expect(find.text('20.0°'), findsOneWidget);
    expect(find.text('clear sky'), findsOneWidget);

    // Verify that the forecast section is displayed
    expect(find.text('5-Day Forecast'), findsOneWidget);
    expect(find.text('View All'), findsOneWidget);

    // Tap the refresh button
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    // Verify that the weather service was called again
    verify(() => mockWeatherService.getCurrentWeather(any())).called(2);
    verify(() => mockWeatherService.getForecast(any(), any())).called(2);

    // Tap the temperature unit toggle button
    await tester.tap(find.byIcon(Icons.thermostat));
    await tester.pump();

    // Verify that the temperature unit was toggled
    verify(() => mockWeatherService.setTemperatureUnit(any())).called(1);

    // Tap the "View All" button
    await tester.tap(find.text('View All'));
    await tester.pumpAndSettle();

    // Verify that the forecast page is displayed
    expect(find.text('5-Day Forecast'), findsOneWidget);
  });
}
