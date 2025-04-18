import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_riverpod/application/providers/location_provider.dart';
import 'package:weather_riverpod/application/providers/service_providers.dart';
import 'package:weather_shared/weather_shared.dart';

class MockLocationService extends Mock implements LocationService {}

void main() {
  late MockLocationService mockLocationService;
  late ProviderContainer container;

  setUp(() {
    mockLocationService = MockLocationService();
    container = ProviderContainer(
      overrides: [
        locationServiceProvider.overrideWithValue(mockLocationService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final tLocation = Location(cityName: 'Test City', lat: 1.0, lon: 1.0);

  test('initial state should be AsyncLoading', () {
    expect(container.read(locationProvider), isA<AsyncLoading>());
  });

  group('getCurrentLocation', () {
    test('should update state with location when successful', () async {
      when(
        () => mockLocationService.getCurrentLocation(),
      ).thenAnswer((_) async => tLocation);

      final notifier = container.read(locationProvider.notifier);
      await notifier.getCurrentLocation();

      expect(
        container.read(locationProvider),
        isA<AsyncData>().having((state) => state.value, 'value', tLocation),
      );
    });

    test('should update state with error when location fetch fails', () async {
      when(
        () => mockLocationService.getCurrentLocation(),
      ).thenThrow(Exception('Error getting location'));

      final notifier = container.read(locationProvider.notifier);
      await notifier.getCurrentLocation();

      expect(
        container.read(locationProvider),
        isA<AsyncError>().having(
          (state) => state.error,
          'error',
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Error getting location'),
          ),
        ),
      );
    });
  });

  group('setLocation', () {
    test('should update state with location when successful', () async {
      when(
        () => mockLocationService.setLocation(tLocation),
      ).thenAnswer((_) async => tLocation);

      final notifier = container.read(locationProvider.notifier);
      await notifier.setLocation(tLocation);

      expect(
        container.read(locationProvider),
        isA<AsyncData>().having((state) => state.value, 'value', tLocation),
      );
    });

    test(
      'should update state with error when setting location fails',
      () async {
        when(
          () => mockLocationService.setLocation(tLocation),
        ).thenThrow(Exception('Error setting location'));

        final notifier = container.read(locationProvider.notifier);
        await notifier.setLocation(tLocation);

        expect(
          container.read(locationProvider),
          isA<AsyncError>().having(
            (state) => state.error,
            'error',
            isA<Exception>().having(
              (error) => error.toString(),
              'message',
              contains('Error setting location'),
            ),
          ),
        );
      },
    );
  });
}
