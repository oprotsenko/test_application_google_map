import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../.env.dart';

part 'map_event.dart';

part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapReadyState(markers: {}, polyLines: {})) {
    on<AddMarkerEvent>(_onAddMarkerEvent);
    on<CleanMapEvent>(_onCleanMapEvent);
  }

  Map<String, Marker> _markers = {};
  Map<PolylineId, Polyline> _polyLines = {};
  final List<LatLng> _polylineCoordinates = [];

  void _onAddMarkerEvent(AddMarkerEvent event, Emitter<MapState> emit) async {
    final currentState = state;
    if (currentState is MapReadyState) {
      _markers = currentState.markers;
      _polyLines = currentState.polyLines;
      if (_isPointsFromSearchPage(event.poi.length)) {
        _markers.clear();
        _polyLines.clear();
        _polylineCoordinates.clear();
      }
      for (var element in event.poi) {
        _markers.addAll(addMarker(LatLng(element.latitude, element.longitude)));
        if (_markers.length == 2) {
          await drawThePath();
        }
        emit(MapReadyState(markers: _markers, polyLines: _polyLines));
      }
    }
  }

  Future<void> drawThePath() async {
    var res = await getPolyline();
    _polyLines[res.polylineId] = res;
    if (res.points.isNotEmpty) {
      for (var point in res.points) {
        _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
  }

  bool _isPointsFromSearchPage(int pointsAmount) =>
      pointsAmount == 2 &&_markers.isNotEmpty;

  void _onCleanMapEvent(CleanMapEvent event, Emitter<MapState> emit) {
    final currentState = state;
    if (currentState is MapReadyState) {
      emit(MapReadyState(markers: event.markers, polyLines: event.polyLines));
    }
  }

  void onMapCreated(GoogleMapController controller) {}

  Map<String, Marker> addMarker(LatLng poi) {
    Map<String, Marker> newMarkers = {};
    final currentState = state;
    if (currentState is MapReadyState) {
      String id = (currentState.markers.isEmpty) ? 'origin' : 'dest';
      newMarkers[id] = Marker(
        markerId: MarkerId(id),
        icon: BitmapDescriptor.defaultMarker,
        position: poi,
      );
    }
    return newMarkers;
  }

  Future<Polyline> getPolyline() async {
    final List<LatLng> polylineCoordinates = [];
    final currentState = state;
    if (currentState is MapReadyState) {
      PolylineResult polylineResult =
          await currentState.polylinePoints.getRouteBetweenCoordinates(
        googleApiKey,
        PointLatLng(currentState.markers['origin']!.position.latitude,
            currentState.markers['origin']!.position.longitude),
        PointLatLng(currentState.markers['dest']!.position.latitude,
            currentState.markers['dest']!.position.longitude),
        travelMode: TravelMode.driving,
      );
      if (polylineResult.points.isNotEmpty) {
        for (var point in polylineResult.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }
    }
    return _addPolyLine(polylineCoordinates);
  }

  Polyline _addPolyLine(List<LatLng> polylineCoordinates) {
    return Polyline(
        polylineId: const PolylineId('poly'),
        color: Colors.red,
        width: 5,
        points: polylineCoordinates);
  }
}
