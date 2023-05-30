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
  late GoogleMapController _mapController;

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
          _setMapFitToTour(Set.of(_polyLines.values));
          emit(MapReadyState(markers: _markers, polyLines: _polyLines));
        }
      }
    }
  }

  void _setMapFitToTour(Set<Polyline> polyline) {
    double minLat = polyline.first.points.first.latitude;
    double minLong = polyline.first.points.first.longitude;
    double maxLat = polyline.first.points.first.latitude;
    double maxLong = polyline.first.points.first.longitude;
    for (var poly in polyline) {
      for (var point in poly.points) {
        if(point.latitude < minLat) minLat = point.latitude;
        if(point.latitude > maxLat) maxLat = point.latitude;
        if(point.longitude < minLong) minLong = point.longitude;
        if(point.longitude > maxLong) maxLong = point.longitude;
      }
    }
    _mapController.moveCamera(CameraUpdate.newLatLngBounds(LatLngBounds(
        southwest: LatLng(minLat, minLong),
        northeast: LatLng(maxLat,maxLong)
    ), 20));
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
      pointsAmount == 2 && _markers.isNotEmpty;

  void _onCleanMapEvent(CleanMapEvent event, Emitter<MapState> emit) {
    final currentState = state;
    if (currentState is MapReadyState) {
      emit(MapReadyState(markers: event.markers, polyLines: event.polyLines));
    }
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

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
