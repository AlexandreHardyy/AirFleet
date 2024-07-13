import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/web/monitoring-logs/bar_chart.dart';
import 'package:frontend/web/monitoring-logs/blocs/logs_bloc.dart';
import 'package:frontend/web/monitoring-logs/list_logs.dart';
import 'package:frontend/widgets/title.dart';

class MonitoringLogScreen extends StatelessWidget {
  const MonitoringLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: BlocProvider(
          create: (context) =>
              MonitoringLogBloc()..add(MonitoringLogInitialized()),
          child: BlocBuilder<MonitoringLogBloc, MonitoringLogState>(
            builder: (context, state) {
              if (state.status == MonitoringLogStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final logs = state.monitoringLogs;

              if (logs == null || logs.isEmpty) {
                return const Text("there no logs yet.");
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const MainTitle(content: "Monitoring logs"),
                      const SizedBox(
                        height: 34,
                      ),
                      const SizedBox(width: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: MonitoringLogChart(logs: logs)),
                          const SizedBox(width: 56),
                          Expanded(child: ListLogs(logs: logs))
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}
