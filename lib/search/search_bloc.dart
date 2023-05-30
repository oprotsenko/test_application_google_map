import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_place/google_place.dart';
import 'package:test_application_google_map/.env.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(const SearchPageState()) {
    on<InitSearchPageEvent>(_onInitSearch);
    on<SelectOriginEvent>(_onSelectOriginPoint);
    on<SelectDestEvent>(_onSelectDestPoint);
    on<AutoCompleteEvent>(_onAutoComplete);
  }

  late final GooglePlace _googlePlace;

  List<AutocompletePrediction> predictions = [];

  void _onInitSearch(InitSearchPageEvent event, Emitter<SearchState> emit) {
    _googlePlace = GooglePlace(googleApiKey);
    emit(const SearchPageState());
  }

  void _onSelectOriginPoint(
      SelectOriginEvent event, Emitter<SearchState> emit) async {
    final currentState = state;
    if (currentState is SearchPageState) {
      var origin =
          event.index != null ? await _setSelectedLocation(event.index!) : null;
      predictions.clear();
      emit(SearchPageState(
          predictions: predictions, origin: origin, dest: currentState.dest));
    }
  }

  void _onSelectDestPoint(
      SelectDestEvent event, Emitter<SearchState> emit) async {
    final currentState = state;
    if (currentState is SearchPageState) {
      var dest =
          event.index != null ? await _setSelectedLocation(event.index!) : null;
      predictions.clear();
      emit(SearchPageState(
          predictions: predictions, origin: currentState.origin, dest: dest));
    }
  }

  void _onAutoComplete(
      AutoCompleteEvent event, Emitter<SearchState> emit) async {
    await _autoCompleteSearch(event.value);
    final currentState = state;
    if (currentState is SearchPageState) {
      emit(SearchPageState(
          predictions: predictions,
          origin: currentState.origin,
          dest: currentState.dest));
    }
  }

  Future<DetailsResult?> _setSelectedLocation(int index) async {
    final currentState = state;
    if (currentState is SearchPageState) {
      final placeId = currentState.predictions[index].placeId!;
      final details = await _googlePlace.details.get(placeId);
      if (_detailsResultIsValid(details)) {
        return details?.result;
      }
    }
    return null;
  }

  bool _detailsResultIsValid(DetailsResponse? details) =>
      details != null && details.result != null;

  Future<void> _autoCompleteSearch(String value) async {
    var result = await _googlePlace.autocomplete.get(value);
    if (_predictionsResultIsValid(result)) {
      predictions = result!.predictions!;
    }
  }

  bool _predictionsResultIsValid(AutocompleteResponse? result) =>
      result != null && result.predictions != null;
}
