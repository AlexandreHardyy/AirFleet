part of 'logs_bloc.dart';

enum MonitoringLogStatus {
  loading,
  loaded,
  error,
}

class MonitoringLogState {
  final List<MonitoringLog>? monitoringLogs;
  final MonitoringLogStatus status;

  MonitoringLogState({required this.monitoringLogs, required this.status});

  MonitoringLogState copyWith({
    List<MonitoringLog>? monitoringLogs,
    MonitoringLogStatus? status,
  }) {
    return MonitoringLogState(
        monitoringLogs: monitoringLogs ?? this.monitoringLogs,
        status: status ?? this.status);
  }
}
