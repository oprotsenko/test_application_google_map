import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_application_google_map/map/map_bloc.dart';
import 'package:test_application_google_map/map/map_screen.dart';
import 'package:test_application_google_map/search/search_bloc.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    var bloc = context.read<SearchBloc>();
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          return Column(children: [
            TextField(
              controller: bloc.originSearchController,
              focusNode: bloc.originFocusNode,
              style: const TextStyle(fontSize: 24),
              decoration: InputDecoration(
                  hintText: 'from:',
                  suffixIcon: _suffixIcon(bloc, bloc.originSearchController)),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _callAutoCompleteEvent(bloc, value);
                } else {}
              },
            ),
            TextField(
              controller: bloc.destSearchController,
              focusNode: bloc.destFocusNode,
              style: const TextStyle(fontSize: 24),
              decoration: InputDecoration(
                  hintText: 'to:',
                  suffixIcon: _suffixIcon(bloc, bloc.destSearchController)),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _callAutoCompleteEvent(bloc, value);
                } else {}
              },
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: bloc.predictions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.pin_drop_rounded),
                    ),
                    title: Text(bloc.predictions[index].description.toString()),
                    onTap: () async {
                      final TextEditingController controller =
                          bloc.originFocusNode.hasFocus
                              ? bloc.originSearchController
                              : bloc.destSearchController;
                      await bloc.setSelectedLocation(
                          index, context.mounted, controller);
                    },
                  );
                }),
            Flexible(
                child: TextButton(
              onPressed: () {
                _callAddMarkerEvent(context, bloc);
                _cleanFields(bloc);
                _navigateToMapPage();
              },
              child: const Text('Build the road'),
            ))
          ]);
        },
      ),
    );
  }

  void _cleanFields(SearchBloc bloc) {
    bloc.clearSelectedLocation(bloc.originSearchController);
    bloc.clearSelectedLocation(bloc.destSearchController);
  }

  void _callAddMarkerEvent(BuildContext context, SearchBloc bloc) {
    context.read<MapBloc>().add(AddMarkerEvent(
          poi: [
            LatLng(bloc.origin!.geometry!.location!.lat!,
                bloc.origin!.geometry!.location!.lng!),
            LatLng(bloc.dest!.geometry!.location!.lat!,
                bloc.dest!.geometry!.location!.lng!)
          ],
        ));
  }

  IconButton? _suffixIcon(SearchBloc bloc, TextEditingController controller) {
    return _textFieldIsNotEmpty(controller)
        ? IconButton(
            onPressed: () {
              bloc.clearSelectedLocation(controller);
            },
            icon: const Icon(Icons.clear_outlined))
        : null;
  }

  bool _textFieldIsNotEmpty(TextEditingController controller) {
    return controller.text.isNotEmpty;
  }

  void _callAutoCompleteEvent(SearchBloc bloc, String value) {
    bloc.add(AutoCompleteEvent(value: value));
  }

  _navigateToMapPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MapPage()));
  }
}

class OriginController extends TextEditingController {}

class DestController extends TextEditingController {}
