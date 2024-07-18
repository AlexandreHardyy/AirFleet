import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/local_notification_setup.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:frontend/services/flight.dart';
import 'package:frontend/services/vehicle.dart';
import 'package:frontend/utils/ticker.dart';

part 'pilot_status_event.dart';

part 'pilot_status_state.dart';

class PilotStatusBloc extends Bloc<PilotStatusEvent, PilotStatusState> {
  final Ticker _ticker = const Ticker();
  StreamSubscription<int>? tickerSubscription;

  @override
  Future<void> close() {
    tickerSubscription?.cancel();
    return super.close();
  }

  PilotStatusBloc()
      : super(PilotStatusState(
            status: CurrentPilotStatus.loading, selectedVehicle: null)) {
    on<PilotStatusInitialized>(_onPilotStatusInitialized);
    on<PilotStatusNotReady>(_onPilotStatusNotReady);
    on<PilotStatusReady>(_onPilotStatusReady);
    on<PilotStatusFlightsRefresh>(_onPilotStatusFlightRefresh);
  }

  Future<void> _onPilotStatusInitialized(
      PilotStatusInitialized event, Emitter<PilotStatusState> emit) async {
    emit(state.copyWith(status: CurrentPilotStatus.loading));
    final vehicles = await VehicleService.getVehiclesForMe();
    final selectedVehicle =
        vehicles.firstWhereOrNull((vehicle) => vehicle.isSelected == true);

    if (selectedVehicle == null) {
      emit(
        state.copyWith(
            status: CurrentPilotStatus.loaded,
            vehicles: vehicles
                .where((vehicle) => vehicle.isVerified == true)
                .toList()),
      );
    }

    final flightRequests = await FlightService.getCurrentFlightRequests();

    emit(state.copyWith(
        status: CurrentPilotStatus.loaded,
        selectedVehicle: selectedVehicle,
        flights: flightRequests,
        vehicles:
            vehicles.where((vehicle) => vehicle.isVerified == true).toList()));

    if (selectedVehicle != null) {
      tickerSubscription?.cancel();
      tickerSubscription = _ticker
          .tick(interval: 10)
          .listen((duration) => add(PilotStatusFlightsRefresh()));
    }
  }

  Future<void> _onPilotStatusNotReady(
      PilotStatusNotReady event, Emitter<PilotStatusState> emit) async {
    emit(state.copyWith(status: CurrentPilotStatus.loading));

    final selectedVehicle = state.selectedVehicle;

    if (selectedVehicle != null) {
      selectedVehicle.isSelected = false;
      await VehicleService.updateVehicle(selectedVehicle);
    }

    tickerSubscription?.cancel();

    emit(state.copyWith(
        status: CurrentPilotStatus.loaded,
        selectedVehicle: selectedVehicle,
        vehicles: state.vehicles?.map(
          (vehicle) {
            if (vehicle.isSelected == true) {
              vehicle.isSelected = false;
            }
            return vehicle;
          },
        ).toList()));
  }

  Future<void> _onPilotStatusReady(
      PilotStatusReady event, Emitter<PilotStatusState> emit) async {
    emit(state.copyWith(status: CurrentPilotStatus.loading));

    final updatedVehicle = await VehicleService.updateVehicle(event.vehicle);
    final flightRequests = await FlightService.getCurrentFlightRequests();

    emit(
      state.copyWith(
          status: CurrentPilotStatus.loaded,
          selectedVehicle: updatedVehicle,
          flights: flightRequests,
          vehicles: state.vehicles),
    );
    tickerSubscription?.cancel();
    tickerSubscription = _ticker
        .tick(interval: 4)
        .listen((duration) => add(PilotStatusFlightsRefresh()));
  }

  Future<void> _onPilotStatusFlightRefresh(
      PilotStatusFlightsRefresh event, Emitter<PilotStatusState> emit) async {
    final flightRequests = await FlightService.getCurrentFlightRequests();

    if (flightRequests?.isNotEmpty == true &&
        flightRequests?.length != state.flights?.length) {
      LocalNotificationService().showNotification('New flight request !',
          'A new fight requests was made by a client', null);
    }

    emit(
      state.copyWith(
          status: CurrentPilotStatus.loaded, flights: flightRequests),
    );
  }
}
