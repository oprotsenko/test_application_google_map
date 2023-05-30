part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();
}

class AddMarkerEvent extends MapEvent {
  final List<LatLng> poi;

  const AddMarkerEvent({required this.poi});

  @override
  List<Object> get props => [poi];
}

class CleanMapEvent extends MapEvent {
  final Map<String, Marker> markers = {};
  final Map<PolylineId, Polyline> polyLines = {};

  @override
  List<Object> get props => [markers, polyLines];
}
