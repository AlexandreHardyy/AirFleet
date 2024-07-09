part of 'pilot_status_bloc.dart';

@immutable
sealed class PilotStatusEvent {}

final class PilotStatusInitialized extends PilotStatusEvent {}

final class PilotStatusNotReady extends PilotStatusEvent {}

final class PilotStatusFlightsRefresh extends PilotStatusEvent {}

final class PilotStatusReady extends PilotStatusEvent {
  final Vehicle vehicle;

  PilotStatusReady({required this.vehicle});
}
