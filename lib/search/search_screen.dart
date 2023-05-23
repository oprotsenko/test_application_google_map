import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:test_application_google_map/.env.dart';
import 'package:test_application_google_map/map/map_screen.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _fromSearchController = TextEditingController();
  final _toSearchController = TextEditingController();

  late GooglePlace _googlePlace;
  late FocusNode _originFocusNode;
  late FocusNode _destFocusNode;

  List<AutocompletePrediction> predictions = [];
  DetailsResult? _origin;
  DetailsResult? _dest;

  @override
  void initState() {
    super.initState();
    _googlePlace = GooglePlace(googleApiKey);
    _originFocusNode = FocusNode();
    _destFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _originFocusNode.dispose();
    _destFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        TextField(
          controller: _fromSearchController,
          focusNode: _originFocusNode,
          style: const TextStyle(fontSize: 24),
          decoration: InputDecoration(
              hintText: 'from:',
              suffixIcon: _fromSearchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          predictions = [];
                          _fromSearchController.clear();
                        });
                      },
                      icon: const Icon(Icons.clear_outlined))
                  : null),
          onChanged: (value) {
            if (value.isNotEmpty) {
              _autoCompleteSearch(value);
            } else {}
          },
        ),
        TextField(
          controller: _toSearchController,
          focusNode: _destFocusNode,
          style: const TextStyle(fontSize: 24),
          decoration: InputDecoration(
              hintText: 'to:',
              suffixIcon: _toSearchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          predictions = [];
                          _toSearchController.clear();
                        });
                      },
                      icon: const Icon(Icons.clear_outlined))
                  : null),
          onChanged: (value) {
            if (value.isNotEmpty) {
              _autoCompleteSearch(value);
            } else {}
          },
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: predictions.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.pin_drop_rounded),
                ),
                title: Text(predictions[index].description.toString()),
                onTap: () async {
                  final placeId = predictions[index].placeId!;
                  final details = await _googlePlace.details.get(placeId);
                  if (_detailsResultIsValid(details)) {
                    if (_originFocusNode.hasFocus) {
                      setState(() {
                        _origin = details?.result;
                        _fromSearchController.text =
                            predictions[index].description!;
                        predictions = [];
                      });
                    } else {
                      setState(() {
                        _dest = details?.result;
                        _toSearchController.text =
                            predictions[index].description!;
                        predictions = [];
                      });
                    }
                  }
                },
              );
            }),
        Flexible(
            child: TextButton(
          onPressed: _fromToFieldsAreNotEmpty() ? _navigateToMapPage() : null,
          child: const Text('Build the road'),
        ))
      ]),
    );
  }

  _navigateToMapPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MapPage(
                  initialPosition: LatLng(_origin!.geometry!.location!.lat!,
                      _origin!.geometry!.location!.lng!),
                  dest: LatLng(_dest!.geometry!.location!.lat!,
                      _dest!.geometry!.location!.lng!),
                )));
  }

  _autoCompleteSearch(String value) async {
    var result = await _googlePlace.autocomplete.get(value);
    if (_predictionsResultIsValid(result)) {
      setState(() {
        predictions = result!.predictions!;
      });
    }
  }

  _predictionsResultIsValid(AutocompleteResponse? result) =>
      result != null && result.predictions != null && mounted;

  _detailsResultIsValid(DetailsResponse? details) =>
      details != null && details.result != null && mounted;

  bool _fromToFieldsAreNotEmpty() {
    return _fromSearchController.text.isNotEmpty &&
        _toSearchController.text.isNotEmpty;
  }
}
