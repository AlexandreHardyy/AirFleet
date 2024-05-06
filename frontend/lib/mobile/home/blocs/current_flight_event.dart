part of 'current_flight_bloc.dart';

@immutable
sealed class CurrentFlightEvent {}

final class CurrentFlightLoaded extends CurrentFlightEvent {
  final Flight flight;

  CurrentFlightLoaded({required this.flight});
}

final class CurrentFlightLoadingError extends CurrentFlightEvent {
  final String errorMessage;

  CurrentFlightLoadingError({required this.errorMessage});
}

final class CurrentFlightCleared extends CurrentFlightEvent {}

final class CurrentFlightLoading extends CurrentFlightEvent {}