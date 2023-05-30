import 'package:flutter/material.dart';
import 'package:test_application_google_map/map/map_layout.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return const MapLayout();
  }
}
