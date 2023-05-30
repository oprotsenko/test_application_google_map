part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
}

class InitSearchPageEvent extends SearchEvent {
  @override
  List<Object?> get props => [];
}

class SelectOriginEvent extends SearchEvent {
  final int? index;

  const SelectOriginEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

class SelectDestEvent extends SearchEvent {
  final int? index;

  const SelectDestEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

class AutoCompleteEvent extends SearchEvent {
  final String value;

  const AutoCompleteEvent({required this.value});

  @override
  List<Object?> get props => [value];
}
