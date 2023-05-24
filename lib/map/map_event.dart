part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();
}

class InitMapPageEvent extends MapEvent {
  final CameraPosition currentCameraPosition;

  const InitMapPageEvent({required this.currentCameraPosition});

  @override
  List<Object> get props => [currentCameraPosition];
}

class AddMarkerEvent extends MapEvent {
  final List<LatLng> poi;

  const AddMarkerEvent({required this.poi});

  @override
  List<Object> get props => [poi];
}

class CleanMapEvent extends MapEvent {
  @override
  List<Object> get props => [];
}
