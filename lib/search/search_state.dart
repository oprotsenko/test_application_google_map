part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();
}

class InitSearchState extends SearchState {
  @override
  List<Object> get props => [];
}

class BuildTheRoadOnTheMapState extends SearchState {
  final DetailsResult origin;
  final DetailsResult dest;

  const BuildTheRoadOnTheMapState({required this.origin, required this.dest});

  @override
  List<Object?> get props => [origin, dest];
}

class SelectOriginState extends SearchState {
  final DetailsResult? origin;

  const SelectOriginState({this.origin});

  @override
  List<Object?> get props => [origin];
}

class SelectDestState extends SearchState {
  final DetailsResult? dest;

  const SelectDestState({this.dest});

  @override
  List<Object?> get props => [dest];
}

class AutoCompleteState extends SearchState {
  final List<AutocompletePrediction> predictions;

  const AutoCompleteState({required this.predictions});

  @override
  List<Object?> get props => [predictions];
}
