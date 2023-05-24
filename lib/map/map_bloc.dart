import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../.env.dart';

part 'map_event.dart';part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(ChooseLocationsState()) {
    on<InitMapPageEvent>(_onInitMapPage);
    on<AddMarkerEvent>(_onAddMarker);
    on<CleanMapEvent>(_onCleanMap);
  }

  Map<PolylineId, Polyline> polyLines = {};
  Map<String, Marker> markers = {};

  get polylineCoordinates => state.polylineCoordinates;

  set polylineCoordinates(newCoordinates) => newCoordinates;

  get polylinePoints => state.polylinePoints;

  get currentCameraPosition => state.currentCameraPosition;

  _onInitMapPage(InitMapPageEvent event, Emitter<MapState> emit) async {
    emit(ChooseLocationsState(markers: markers, polyLines: polyLines));
  }

  _onAddMarker(AddMarkerEvent event, Emitter<MapState> emit) async {
    if (event.poi.length == 2 && markers.isNotEmpty) {
      markers.clear();
    }
    for (var element in event.poi) {
      markers = addMarker(LatLng(element.latitude, element.longitude));
      if (markers.length == 2) {
        await getPolyline();
      }
      emit(ChooseLocationsState(markers: markers, polyLines: polyLines));
    }
  }

  _onCleanMap(CleanMapEvent event, Emitter<MapState> emit) {
    polyLines.clear();
    markers.clear();
    polylineCoordinates = [];
    emit(CleanMapState());
  }

  onMapCreated(GoogleMapController controller) {}

  Map<String, Marker> addMarker(LatLng poi) {
    Map<String, Marker> newMarkers = {};
    String id = (markers.isEmpty) ? 'origin' : 'dest';
    newMarkers.addAll(markers);
    newMarkers[id] = Marker(
      markerId: MarkerId(id),
      icon: BitmapDescriptor.defaultMarker,
      position: poi,
    );
    return newMarkers;
  }

  _addPolyLine() {
    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        width: 5,
        points: polylineCoordinates);
    polyLines[id] = polyline;
  }

  getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(markers['origin']!.position.latitude,
          markers['origin']!.position.longitude),
      PointLatLng(markers['dest']!.position.latitude,
          markers['dest']!.position.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    _addPolyLine();
  }
}
