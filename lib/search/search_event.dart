part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
}

class InitSearchPageEvent extends SearchEvent {
  final GooglePlace googlePlace = GooglePlace(googleApiKey);
  final FocusNode originFocusNode = FocusNode();
  final FocusNode destFocusNode = FocusNode();
  final originSearchController = OriginController();
  final destSearchController = DestController();

  @override
  List<Object?> get props => [
        googlePlace,
        originFocusNode,
        destFocusNode,
        originSearchController,
        destSearchController
      ];
}

class SelectOriginEvent extends SearchEvent {
  final DetailsResult? origin;

  const SelectOriginEvent({this.origin});

  @override
  List<Object?> get props => [origin];
}

class SelectDestEvent extends SearchEvent {
  final DetailsResult? dest;

  const SelectDestEvent({this.dest});

  @override
  List<Object?> get props => [dest];
}

class AutoCompleteEvent extends SearchEvent {
  final String value;

  const AutoCompleteEvent({required this.value});

  @override
  List<Object?> get props => [value];
}
