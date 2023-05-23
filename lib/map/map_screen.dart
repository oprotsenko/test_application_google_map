import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:test_application_google_map/.env.dart';
import 'package:geolocator/geolocator.dart';
import 'package:test_application_google_map/search/search_screen.dart';

class MapPage extends StatefulWidget {
  final LatLng initialPosition;
  final LatLng? dest;

  const MapPage({super.key, required this.initialPosition, this.dest});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _mapController;

  Map<String, Marker> markers = {};
  Map<String, String> titles = {};
  Map<PolylineId, Polyline> polyLines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  late CameraPosition _currentCameraPosition;

  @override
  void initState() {
    super.initState();
    _currentCameraPosition = CameraPosition(
      target: widget.initialPosition,
      zoom: 11.0,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _mapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          TextButton.icon(
              onPressed: _navigateToSearchPage,
              icon: const Icon(Icons.search),
              label: const Text('Search for location')),
          Flexible(
            flex: 1,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              zoomControlsEnabled: false,
              initialCameraPosition: _currentCameraPosition,
              markers: Set<Marker>.of(markers.values),
              polylines: Set<Polyline>.of(polyLines.values),
              onLongPress: _addMarker,
            ),
          )
        ],
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Colors.black,
        onPressed: _updateCamera,
        child: const Icon(Icons.center_focus_weak_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (widget.dest == null) {
      _getCurrentPosition();
    } else {
      _addMarker(widget.initialPosition);
      _addMarker(widget.dest!);
    }
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
        if (markers.length == 2) {
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

  Future<void> _getCurrentPosition() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentCameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 11.0);
        _updateCamera();
      });

      _addMarker(LatLng(position.latitude, position.longitude));
    }).catchError((e) {
      print(e);
    });
  }

  _updateCamera() {
    _mapController
        .animateCamera(CameraUpdate.newCameraPosition(_currentCameraPosition));
  }

  _navigateToSearchPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SearchPage()));
  }
}
