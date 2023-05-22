import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:test_application_google_map/.env.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;

  Map<String, Marker> markers = {};
  Map<String, String> titles = {};
  Map<PolylineId, Polyline> polyLines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  CameraPosition _currentCameraPosition = const CameraPosition(
    target: LatLng(50.45069258864343, 30.52373692417302),
    zoom: 11.0,
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getCurrentPosition();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          elevation: 2,
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          zoomControlsEnabled: false,
          initialCameraPosition: _currentCameraPosition,
          markers: Set<Marker>.of(markers.values),
          polylines: Set<Polyline>.of(polyLines.values),
          onLongPress: _addMarker,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme
              .of(context)
              .cardColor,
          foregroundColor: Colors.black,
          onPressed: _updateCamera,
          child: const Icon(Icons.center_focus_weak_rounded),
        ),
      ),
    );
  }

  _addMarker(LatLng poi) {
    setState(() {
      if (markers.length == 2) {
        markers.clear();
        polyLines.clear();
        polylineCoordinates = [];
      } else {
        String id = (markers.isEmpty) ? 'origin' : 'dest';
        markers[id] = Marker(
          markerId: MarkerId(id),
          infoWindow: InfoWindow(title: titles[id]),
          icon: BitmapDescriptor.defaultMarker,
          position: poi,
        );
        print('add marker: $id');
        if (markers.length == 2) {
          print('points on the map: ${markers.length}');
          _getPolyline();
        }
      }
    });
  }

  _addPolyLine() {
    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        width: 5,
        points: polylineCoordinates);
    polyLines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    print(
        'origin: ${markers['origin']!.position.latitude}, ${markers['origin']!
            .position.longitude} \n'
            'dest: ${markers['dest']!.position
            .latitude}, ${markers['dest']!.position.longitude}');
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(markers['origin']!.position.latitude,
          markers['origin']!.position.longitude),
      PointLatLng(markers['dest']!.position.latitude,
          markers['dest']!.position.longitude),
      travelMode: TravelMode.driving,
    );
    print('get polylines result: ${result.points}');
    if (result.points.isNotEmpty) {
      result.points.forEach((point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  Future<void> _getCurrentPosition() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentCameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 11.0);
        _updateCamera();
      });

      _addMarker(LatLng(position.latitude, position.longitude));
      print('current position ${position.latitude}, ${position.longitude}');
    }).catchError((e) {
      print(e);
    });
  }

  _updateCamera() {
    mapController
        .animateCamera(CameraUpdate.newCameraPosition(_currentCameraPosition));
  }
}
