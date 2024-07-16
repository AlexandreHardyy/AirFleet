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
  final bool isModuleEnabled;
  final String? errorMessage;

  CurrentFlightState({
    required this.status,
    this.flight,
    this.flightRequest,
    this.pendingRating,
    this.isModuleEnabled = true,
    this.errorMessage,
  });

  CurrentFlightState copyWith({
    CurrentFlightStatus? status,
    Flight? flight,
    CreateFlightRequest? flightRequest,
    Rating? pendingRating,
    bool? isModuleEnabled,
    String? errorMessage,
  }) {
    return CurrentFlightState(
      status: status ?? this.status,
      flight: flight ?? this.flight,
      flightRequest: flightRequest ?? this.flightRequest,
      pendingRating: pendingRating ?? this.pendingRating,
      isModuleEnabled: isModuleEnabled ?? this.isModuleEnabled,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
