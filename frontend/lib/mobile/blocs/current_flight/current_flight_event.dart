part of 'current_flight_bloc.dart';

@immutable
sealed class CurrentFlightEvent {}

final class CurrentFlightLoading extends CurrentFlightEvent {}

final class CurrentFlightInitialized extends CurrentFlightEvent {}

final class CurrentFlightSelected extends CurrentFlightEvent {
  final CreateFlightRequest flightRequest;

  CurrentFlightSelected({required this.flightRequest});
}

final class CurrentFlightLoaded extends CurrentFlightEvent {
  final Flight flight;

  CurrentFlightLoaded({required this.flight});
}

final class CurrentFlightUpdated extends CurrentFlightEvent {}

final class CurrentFlightLoadingError extends CurrentFlightEvent {
  final String errorMessage;

  CurrentFlightLoadingError({required this.errorMessage});
}

final class CurrentFlightCleared extends CurrentFlightEvent {}
