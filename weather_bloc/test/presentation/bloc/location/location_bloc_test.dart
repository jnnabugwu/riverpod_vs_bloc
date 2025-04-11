import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_bloc/core/error/failures.dart';
import 'package:weather_bloc/domain/usecases/get_current_location_usecase.dart';
import 'package:weather_bloc/domain/usecases/set_location_usecase.dart';
import 'package:weather_bloc/presentation/bloc/location/location_bloc.dart';
import 'package:weather_shared/weather_shared.dart';

class MockGetCurrentLocationUsecase extends Mock
    implements GetCurrentLocationUsecase {}

class MockSetLocationUsecase extends Mock implements SetLocationUsecase {}

void main() {
  late LocationBloc locationBloc;
  late MockGetCurrentLocationUsecase mockGetCurrentLocationUsecase;
  late MockSetLocationUsecase mockSetLocationUsecase;

  setUp(() {
    mockGetCurrentLocationUsecase = MockGetCurrentLocationUsecase();
    mockSetLocationUsecase = MockSetLocationUsecase();
    locationBloc = LocationBloc(
      getCurrentLocationUsecase: mockGetCurrentLocationUsecase,
      setLocationUsecase: mockSetLocationUsecase,
    );
  });

  tearDown(() {
    locationBloc.close();
  });

  final tLocation = Location(cityName: 'Test City', lat: 1.0, lon: 1.0);

  test('initial state should be LocationInitial', () {
    expect(locationBloc.state, isA<LocationInitial>());
  });

  group('GetCurrentLocation', () {
    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationLoaded] when getting current location succeeds',
      build: () {
        when(
          () => mockGetCurrentLocationUsecase(),
        ).thenAnswer((_) async => Right(tLocation));
        return locationBloc;
      },
      act: (bloc) => bloc.add(GetCurrentLocation()),
      expect:
          () => [
            isA<LocationLoading>(),
            isA<LocationLoaded>().having(
              (state) => state.location,
              'location',
              tLocation,
            ),
          ],
    );

    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationError] when getting current location fails',
      build: () {
        when(() => mockGetCurrentLocationUsecase()).thenAnswer(
          (_) async => Left(LocationFailure(message: 'Error getting location')),
        );
        return locationBloc;
      },
      act: (bloc) => bloc.add(GetCurrentLocation()),
      expect:
          () => [
            isA<LocationLoading>(),
            isA<LocationError>().having(
              (state) => state.message,
              'message',
              'Error getting location',
            ),
          ],
    );
  });

  group('SetLocation', () {
    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationLoaded] when setting location succeeds',
      build: () {
        when(
          () => mockSetLocationUsecase(tLocation),
        ).thenAnswer((_) async => Right(tLocation));
        return locationBloc;
      },
      act: (bloc) => bloc.add(SetLocation(tLocation)),
      expect:
          () => [
            isA<LocationLoading>(),
            isA<LocationLoaded>().having(
              (state) => state.location,
              'location',
              tLocation,
            ),
          ],
    );

    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationError] when setting location fails',
      build: () {
        when(() => mockSetLocationUsecase(tLocation)).thenAnswer(
          (_) async => Left(LocationFailure(message: 'Error setting location')),
        );
        return locationBloc;
      },
      act: (bloc) => bloc.add(SetLocation(tLocation)),
      expect:
          () => [
            isA<LocationLoading>(),
            isA<LocationError>().having(
              (state) => state.message,
              'message',
              'Error setting location',
            ),
          ],
    );
  });
}
