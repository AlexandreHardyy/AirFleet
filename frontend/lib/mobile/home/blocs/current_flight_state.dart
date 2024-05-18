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
  final String? errorMessage;

  CurrentFlightState({
    required this.status,
    this.flight,
    this.flightRequest,
    this.errorMessage,
  });

  CurrentFlightState copyWith({
    CurrentFlightStatus? status,
    Flight? flight,
    CreateFlightRequest? flightRequest,
    String? errorMessage,
  }) {
    return CurrentFlightState(
      status: status ?? this.status,
      flight: flight ?? this.flight,
      flightRequest: flightRequest ?? this.flightRequest,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}