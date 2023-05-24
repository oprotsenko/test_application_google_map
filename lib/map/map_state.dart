part of 'map_bloc.dart';

abstract class MapState extends Equatable {
  final List<LatLng> polylineCoordinates = [];
  final PolylinePoints polylinePoints = PolylinePoints();
  final CameraPosition currentCameraPosition = const CameraPosition(
    target: LatLng(50.45069258864343, 30.52373692417302),
    zoom: 11.0,
  );
}

class ChooseLocationsState extends MapState {
  final Map<String, Marker> markers;
  final Map<PolylineId, Polyline> polyLines;

  ChooseLocationsState({this.markers = const {}, this.polyLines = const {}});

  @override
  List<Object> get props => [markers, polyLines];
}

class CleanMapState extends MapState {
  @override
  List<Object> get props => [];
}
