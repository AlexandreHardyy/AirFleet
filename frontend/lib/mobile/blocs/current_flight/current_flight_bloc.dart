import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/local_notification_setup.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/models/rating.dart';
import 'package:frontend/services/flight.dart';
import 'package:frontend/services/module.dart';
import 'package:frontend/services/rating.dart';

part 'current_flight_event.dart';
part 'current_flight_state.dart';

class CurrentFlightBloc extends Bloc<CurrentFlightEvent, CurrentFlightState> {
  CurrentFlightBloc() : super(CurrentFlightState(status: CurrentFlightStatus.initial)) {
    on<CurrentFlightInitialized>(_onCurrentFlightInitialized);
    on<CurrentFlightSelected>(_onCurrentFlightSelected);
    on<CurrentFlightLoading>(_onCurrentFlightLoading);
    on<CurrentFlightLoaded>(_onCurrentFlightLoaded);
    on<CurrentFlightUpdated>(_onCurrentFlightUpdated);
    on<CurrentFlightCleared>(_onCurrentFlightCleared);
    on<CurrentFlightLoadingError>(_onCurrentFlightLoadingError);
  }

  Future<void> _onCurrentFlightInitialized(CurrentFlightInitialized event, Emitter<CurrentFlightState> emit) async {
    emit(state.copyWith(status: CurrentFlightStatus.loading));

    final module = await ModuleService.getModuleByName("flight");
    if (!module.isEnabled) {
      emit(state.copyWith(status: CurrentFlightStatus.loaded, isModuleEnabled: false));
      return;
    }

    final flight = await FlightService.getCurrentFlight();

    if (flight == null) {
      final pendingRating = await RatingService.getRatingByUserIDAndStatus("waiting_for_review");

      return emit(CurrentFlightState(
        status: CurrentFlightStatus.loaded,
        flight: null,
        flightRequest: null,
        pendingRating: pendingRating,
        isModuleEnabled: module.isEnabled,
        errorMessage: null
      ));
    }

    emit(state.copyWith(
      status: CurrentFlightStatus.loaded,
      flight: flight,
      isModuleEnabled: module.isEnabled,
    ));
  }

  void _onCurrentFlightSelected(CurrentFlightSelected event, Emitter<CurrentFlightState> emit) {
    emit(state.copyWith(
      status: CurrentFlightStatus.selected,
      flightRequest: event.flightRequest,
    ));
  }

  Future<void> _onCurrentFlightUpdated(CurrentFlightUpdated event, Emitter<CurrentFlightState> emit) async {
    final flight = await FlightService.getCurrentFlight();

    if (flight == null) {
      final pendingRating = await RatingService.getRatingByUserIDAndStatus("waiting_for_review");

      return emit(CurrentFlightState(
        status: CurrentFlightStatus.loaded,
        flight: null,
        flightRequest: null,
        pendingRating: pendingRating,
        errorMessage: null
      ));
    }

    if (flight.status == "waiting_proposal_approval" && state.flight?.status == "waiting_pilot") {
      Map<String, dynamic> payload = {
        'routeName': '/home',
        'arguments': null,
      };

      LocalNotificationService().showNotification('An offer has been made !', 'A pilot has made an offer for your flight. Check it out !', jsonEncode(payload));
    }

    emit(state.copyWith(
      status: CurrentFlightStatus.loaded,
      flight: flight,
    ));
  }

  void _onCurrentFlightLoading(CurrentFlightLoading event, Emitter<CurrentFlightState> emit) {
    emit(state.copyWith(
        status: CurrentFlightStatus.loading
    ));
  }

  void _onCurrentFlightLoaded(CurrentFlightLoaded event, Emitter<CurrentFlightState> emit) {
    emit(state.copyWith(
      status: CurrentFlightStatus.loaded,
      flight: event.flight,
      flightRequest: null,
    ));
  }

  void _onCurrentFlightCleared(CurrentFlightCleared event, Emitter<CurrentFlightState> emit) {
    emit(CurrentFlightState(
        status: CurrentFlightStatus.loaded,
        flight: null,
        flightRequest: null,
        errorMessage: null
    ));
  }

  void _onCurrentFlightLoadingError(CurrentFlightLoadingError event, Emitter<CurrentFlightState> emit) {
    emit(state.copyWith(
      status: CurrentFlightStatus.error,
      errorMessage: event.errorMessage,
    ));
  }

}
