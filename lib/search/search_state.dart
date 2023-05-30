part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();
}

class InitSearchState extends SearchState {
  @override
  List<Object> get props => [];
}

class SearchPageState extends SearchState {
  final List<AutocompletePrediction> predictions;
  final DetailsResult? origin;
  final DetailsResult? dest;

  const SearchPageState({this.predictions = const [], this.origin, this.dest });

  @override
  List<Object?> get props => [predictions, origin, dest];
}

