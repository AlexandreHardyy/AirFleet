part of 'current_flight_bloc.dart';

enum CurrentFlightStatus {
  initial,
  selected,
  loading,
  loaded,
  error,
}

class CurrentFlightState {
  final CurrentFlightStatus status;
  final Flight? flight;
  final CreateFlightRequest? flightRequest;
  final Rating? pendingRating;
  final String? errorMessage;

  CurrentFlightState({
    required this.status,
    this.flight,
    this.flightRequest,
    this.pendingRating,
    this.errorMessage,
  });

  CurrentFlightState copyWith({
    CurrentFlightStatus? status,
    Flight? flight,
    CreateFlightRequest? flightRequest,
    Rating? pendingRating,
    String? errorMessage,
  }) {
    return CurrentFlightState(
      status: status ?? this.status,
      flight: flight ?? this.flight,
      flightRequest: flightRequest ?? this.flightRequest,
      pendingRating: pendingRating ?? this.pendingRating,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
