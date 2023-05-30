import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_application_google_map/map/map_bloc.dart';
import 'package:test_application_google_map/search/search_bloc.dart';

class SearchLayout extends StatefulWidget {
  const SearchLayout({super.key});

  @override
  State<StatefulWidget> createState() => _SearchLayoutState();
}

class _SearchLayoutState extends State<SearchLayout> {
  final FocusNode originFocusNode = FocusNode();
  final FocusNode destFocusNode = FocusNode();
  final TextEditingController originSearchController = OriginController();
  final TextEditingController destSearchController = DestController();

  @override
  Widget build(BuildContext context) {
    var bloc = context.read<SearchBloc>();
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchPageState) {
            return Column(children: [
              TextField(
                controller: originSearchController,
                focusNode: originFocusNode,
                style: const TextStyle(fontSize: 24),
                decoration: InputDecoration(
                    hintText: 'from:',
                    suffixIcon: _suffixIcon(bloc, originSearchController)),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _callAutoCompleteEvent(bloc, value);
                  } else {}
                },
              ),
              TextField(
                controller: destSearchController,
                focusNode: destFocusNode,
                style: const TextStyle(fontSize: 24),
                decoration: InputDecoration(
                    hintText: 'to:',
                    suffixIcon: _suffixIcon(bloc, destSearchController)),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _callAutoCompleteEvent(bloc, value);
                  } else {}
                },
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.predictions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.pin_drop_rounded),
                        ),
                        title: Text(
                            state.predictions[index].description.toString()),
                        onTap: () {
                          if (originFocusNode.hasFocus && mounted) {
                            bloc.add(SelectOriginEvent(index: index));
                            originSearchController.text =
                                state.predictions[index].description!;
                          } else if (mounted) {
                            bloc.add(SelectDestEvent(index: index));
                            destSearchController.text =
                                state.predictions[index].description!;
                          }
                        });
                  }),
              Flexible(
                  child: TextButton(
                onPressed: () {
                  _callAddMarkerEvent(context, bloc);
                  _cleanFields(bloc);
                  Navigator.pop(context);
                },
                child: const Text('Build the road'),
              ))
            ]);
          } else {
            return const Text("Something went wrong");
          }
        },
      ),
    );
  }

  void _cleanFields(SearchBloc bloc) {
    bloc.add(const SelectOriginEvent(index: null));
    bloc.add(const SelectDestEvent(index: null));
  }

  void _callAddMarkerEvent(BuildContext context, SearchBloc bloc) {
    final state = bloc.state;
    if (state is SearchPageState) {
      context.read<MapBloc>().add(AddMarkerEvent(
            poi: [
              LatLng(state.origin!.geometry!.location!.lat!,
                  state.origin!.geometry!.location!.lng!),
              LatLng(state.dest!.geometry!.location!.lat!,
                  state.dest!.geometry!.location!.lng!)
            ],
          ));
    }
  }

  IconButton? _suffixIcon(SearchBloc bloc, TextEditingController controller) {
    return _textFieldIsNotEmpty(controller)
        ? IconButton(
            onPressed: () {
              controller.clear();
              if (controller is OriginController) {
                bloc.add(const SelectOriginEvent(index: null));
              } else {
                bloc.add(const SelectDestEvent(index: null));
              }
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
}

class OriginController extends TextEditingController {}

class DestController extends TextEditingController {}
