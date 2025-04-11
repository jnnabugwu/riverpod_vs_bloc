part of 'location_bloc.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

class GetCurrentLocation extends LocationEvent {}

class SetLocation extends LocationEvent {
  final Location location;

  const SetLocation(this.location);

  @override
  List<Object> get props => [location];
}
