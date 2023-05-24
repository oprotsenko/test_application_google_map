import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_place/google_place.dart';
import 'package:test_application_google_map/.env.dart';
import 'package:test_application_google_map/search/search_screen.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(InitSearchState()) {
    on<InitSearchPageEvent>(_onInitSearch);
    on<SelectOriginEvent>(_onSelectOriginPoint);
    on<SelectDestEvent>(_onSelectDestPoint);
    on<AutoCompleteEvent>(_onAutoComplete);
  }

  DetailsResult? origin;
  DetailsResult? dest;
  late final GooglePlace _googlePlace;
  late final FocusNode originFocusNode;
  late final FocusNode destFocusNode;
  late final TextEditingController originSearchController;
  late final TextEditingController destSearchController;
  List<AutocompletePrediction> predictions = [];

  _onInitSearch(InitSearchPageEvent event, Emitter<SearchState> emit) {
    _googlePlace = event.googlePlace;
    originFocusNode = event.originFocusNode;
    destFocusNode = event.destFocusNode;
    originSearchController = event.originSearchController;
    destSearchController = event.destSearchController;
    emit(InitSearchState());
  }

  _onSelectOriginPoint(SelectOriginEvent event, Emitter<SearchState> emit) {
    origin = event.origin;
    emit(SelectOriginState(origin: event.origin));
  }

  _onSelectDestPoint(SelectDestEvent event, Emitter<SearchState> emit) {
    dest = event.dest;
    emit(SelectDestState(dest: event.dest));
  }

  _onAutoComplete(AutoCompleteEvent event, Emitter<SearchState> emit) async {
    await _autoCompleteSearch(event.value);
    emit(AutoCompleteState(predictions: predictions));
  }

  Future<void> setSelectedLocation(
      int index, bool mounted, TextEditingController controller) async {
    final placeId = predictions[index].placeId!;
    final details = await _googlePlace.details.get(placeId);
    if (_detailsResultIsValid(details, mounted)) {
      if (!mounted) return;
      updateTextField(details, index, controller);
    }
  }

  void updateTextField(details, int index, TextEditingController controller) {
    if (controller is OriginController) {
      add(SelectOriginEvent(origin: details?.result));
    } else {
      add(SelectDestEvent(dest: details?.result));
    }
    controller.text = predictions[index].description!;
    predictions = [];
  }

  clearSelectedLocation(TextEditingController controller) {
    if (controller is OriginController) {
      add(const SelectOriginEvent());
    } else {
      add(const SelectDestEvent());
    }
    predictions = [];
    controller.clear();
  }

  _detailsResultIsValid(DetailsResponse? details, bool mounted) =>
      details != null && details.result != null && mounted;

  _autoCompleteSearch(String value) async {
    var result = await _googlePlace.autocomplete.get(value);
    if (_predictionsResultIsValid(result)) {
      predictions = result!.predictions!;
    }
  }

  _predictionsResultIsValid(AutocompleteResponse? result) =>
      result != null && result.predictions != null;
}
