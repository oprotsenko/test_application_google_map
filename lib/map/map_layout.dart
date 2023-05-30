import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_application_google_map/map/map_bloc.dart';
import 'package:test_application_google_map/search/search_bloc.dart';
import 'package:test_application_google_map/search/search_screen.dart';

class MapLayout extends StatefulWidget {
  const MapLayout({super.key});

  @override
  State<MapLayout> createState() => _MapLayoutState();
}

class _MapLayoutState extends State<MapLayout> {
  @override
  Widget build(BuildContext context) {
    var bloc = context.read<MapBloc>();
    return Scaffold(
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is MapReadyState) {
            return SafeArea(
                child: Column(
              children: [
                TextButton.icon(
                    onPressed: () {
                      context.read<SearchBloc>().add(InitSearchPageEvent());
                      _navigateToSearchPage();
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Search for location')),
                // Expanded(
                //     child: ),
                Flexible(
                  flex: 1,
                  child: GoogleMap(
                    onMapCreated: (controller) {
                      bloc.onMapCreated(controller);
                    },
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    initialCameraPosition: state.currentCameraPosition,
                    markers: Set<Marker>.of(state.markers.values),
                    polylines: Set<Polyline>.of(state.polyLines.values),
                    onLongPress: (LatLng point) {
                      bloc.add(AddMarkerEvent(poi: [point]));
                    },
                    onTap: (LatLng point) {
                      bloc.add(CleanMapEvent());
                      _cleanRoute;
                    },
                  ),
                )
              ],
            ));
          } else {
            return const Text("Something went wrong");
          }
        },
      ),
    );
  }

  _cleanRoute() {}

  _navigateToSearchPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SearchPage()));
  }
}
