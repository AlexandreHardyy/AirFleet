part of 'pilot_status_bloc.dart';

enum CurrentPilotStatus {
  initial,
  selected,
  loading,
  loaded,
  error,
}

class PilotStatusState {
  final CurrentPilotStatus status;
  final List<Vehicle>? vehicles;
  final Vehicle? selectedVehicle;
  final List<Flight>? flights;

  PilotStatusState({
    required this.status,
    this.selectedVehicle,
    this.vehicles,
    this.flights
  });

  PilotStatusState copyWith(
      {CurrentPilotStatus? status, List<Vehicle>? vehicles, Vehicle? selectedVehicle, List<Flight>? flights }) {
    return PilotStatusState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      flights: flights ?? this.flights
    );
  }

  
}
