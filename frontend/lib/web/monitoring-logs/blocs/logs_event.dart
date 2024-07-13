part of 'logs_bloc.dart';

@immutable
sealed class MonitoringLogEvent {}

final class MonitoringLogInitialized extends MonitoringLogEvent {}