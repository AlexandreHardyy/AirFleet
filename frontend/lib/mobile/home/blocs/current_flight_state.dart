part of 'current_flight_bloc.dart';

enum CurrentFlightStatus {
  initial,
  loading,
  loaded,
  error,
}

class CurrentFlightState {
  final CurrentFlightStatus status;
  final Flight? flight;
  final String? errorMessage;

  CurrentFlightState({
    required this.status,
    this.flight,
    this.errorMessage,
  });

  CurrentFlightState copyWith({
    CurrentFlightStatus? status,
    Flight? flight,
    String? errorMessage,
  }) {
    return CurrentFlightState(
      status: status ?? this.status,
      flight: flight ?? this.flight,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}