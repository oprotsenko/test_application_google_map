part of 'map_bloc.dart';

abstract class MapState extends Equatable {}

class MapReadyState extends MapState {
  final Map<String, Marker> markers;
  final Map<PolylineId, Polyline> polyLines;
  final PolylinePoints polylinePoints = PolylinePoints();
  final CameraPosition currentCameraPosition = const CameraPosition(
    target: LatLng(50.45069258864343, 30.52373692417302),
    zoom: 11.0,
  );

  MapReadyState({required this.markers, required this.polyLines});

  @override
  List<Object> get props => [polylinePoints, markers, polyLines];
}
