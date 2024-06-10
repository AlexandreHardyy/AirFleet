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

  PilotStatusState({
    required this.status,
    this.selectedVehicle,
    this.vehicles,
  });

  PilotStatusState copyWith(
      {CurrentPilotStatus? status, List<Vehicle>? vehicles, Vehicle? selectedVehicle}) {
    return PilotStatusState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
    );
  }

  
}
