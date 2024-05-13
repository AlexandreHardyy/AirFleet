import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/flight.dart';

part 'current_flight_event.dart';
part 'current_flight_state.dart';

class CurrentFlightBloc extends Bloc<CurrentFlightEvent, CurrentFlightState> {
  CurrentFlightBloc() : super(CurrentFlightState(status: CurrentFlightStatus.initial)) {
    on<CurrentFlightLoaded>(_onCurrentFlightLoaded);
    on<CurrentFlightCleared>(_onCurrentFlightCleared);
    on<CurrentFlightLoadingError>(_onCurrentFlightLoadingError);
  }

  // void _onLoadCurrentFlight(CurrentFlightLoaded event, Emitter<CurrentFlightState> emit) {
  //   emit(CurrentFlightState(status: CurrentFlightStatus.loading));
  // }

  void _onCurrentFlightLoaded(CurrentFlightLoaded event, Emitter<CurrentFlightState> emit) {
    emit(state.copyWith(
      status: CurrentFlightStatus.loaded,
      flight: event.flight,
    ));
  }

  void _onCurrentFlightCleared(CurrentFlightCleared event, Emitter<CurrentFlightState> emit) {
    emit(CurrentFlightState(status: CurrentFlightStatus.loaded, flight: null, errorMessage: null));
  }

  void _onCurrentFlightLoadingError(CurrentFlightLoadingError event, Emitter<CurrentFlightState> emit) {
    emit(state.copyWith(
      status: CurrentFlightStatus.error,
      errorMessage: event.errorMessage,
    ));
  }

}
