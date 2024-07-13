import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/monitoring_log.dart';
import 'package:frontend/services/monitoring_log.dart';

part 'logs_event.dart';
part 'logs_state.dart';

class MonitoringLogBloc extends Bloc<MonitoringLogEvent, MonitoringLogState> {
  MonitoringLogBloc() : super(MonitoringLogState(status: MonitoringLogStatus.loading, monitoringLogs: null)) {
    on<MonitoringLogInitialized>(_onMonitoringLogInitialized);
  }

  Future<void> _onMonitoringLogInitialized(
      MonitoringLogInitialized event, Emitter<MonitoringLogState> emit) async {
    emit(state.copyWith(status: MonitoringLogStatus.loading));

    final monitoringLogs = await MonitoringLogService.fetchAll();

    emit(state.copyWith(
      monitoringLogs: monitoringLogs,
      status: MonitoringLogStatus.loaded
    ));
  }
}
