import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map/map_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const LatLng defaultLocation = LatLng(50.45069258864343, 30.52373692417302);
    return MaterialApp(
      title: 'Test Application',
      theme: ThemeData(
        colorSchemeSeed: Colors.green[700],
        useMaterial3: true,
      ),
      home: const MapPage(initialPosition: defaultLocation),
    );
  }
}
