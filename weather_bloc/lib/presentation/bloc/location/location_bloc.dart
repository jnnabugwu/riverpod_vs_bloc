import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:weather_shared/weather_shared.dart';
import 'package:weather_bloc/domain/usecases/get_current_location_usecase.dart';
import 'package:weather_bloc/domain/usecases/set_location_usecase.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetCurrentLocationUsecase _getCurrentLocationUsecase;
  final SetLocationUsecase _setLocationUsecase;

  LocationBloc({
    required GetCurrentLocationUsecase getCurrentLocationUsecase,
    required SetLocationUsecase setLocationUsecase,
  }) : _getCurrentLocationUsecase = getCurrentLocationUsecase,
       _setLocationUsecase = setLocationUsecase,
       super(LocationInitial()) {
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<SetLocation>(_onSetLocation);
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    final result = await _getCurrentLocationUsecase();
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (location) => emit(LocationLoaded(location: location)),
    );
  }

  Future<void> _onSetLocation(
    SetLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    final result = await _setLocationUsecase(event.location);
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (location) => emit(LocationLoaded(location: location)),
    );
  }
}
