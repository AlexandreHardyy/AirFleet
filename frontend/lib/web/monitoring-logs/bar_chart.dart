import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/monitoring_log.dart';
import 'package:intl/intl.dart';

class MonitoringLogChart extends StatefulWidget {
  final Color infoBarColor = const Color.fromARGB(255, 41, 218, 135);
  final Color errorBarColor = const Color.fromARGB(255, 202, 42, 77);
  final List<MonitoringLog> logs;

  const MonitoringLogChart({super.key, required this.logs});

  @override
  State<StatefulWidget> createState() => MonitoringLogChartState();
}

class MonitoringLogChartState extends State<MonitoringLogChart> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.insert_chart_sharp),
                  const SizedBox(
                    width: 32,
                  ),
                  Text(
                    'Logs Chart',
                    style: TextStyle(
                      color: widget.infoBarColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 32,
              ),
              Expanded(
                child: BarChart(
                  monitoringLogsData(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(
      int x, double yInfo, double yError, String label1, String label2) {
    return BarChartGroupData(
      barsSpace: 8,
      x: x,
      barRods: [
        BarChartRodData(
          toY: yInfo,
          color: widget.infoBarColor,
          borderRadius: BorderRadius.zero,
          width: 18,
          borderSide: BorderSide(color: widget.infoBarColor, width: 2.0),
          rodStackItems: [
            BarChartRodStackItem(
              0,
              yInfo,
              widget.infoBarColor,
            ),
          ],
        ),
        BarChartRodData(
          toY: yError,
          color: widget.errorBarColor,
          borderRadius: BorderRadius.zero,
          width: 18,
          borderSide: BorderSide(color: widget.errorBarColor, width: 2.0),
          rodStackItems: [
            BarChartRodStackItem(
              0,
              yError,
              widget.errorBarColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    List<String> days = getLastSevenDays();

    Widget text = Text(
      days[value.toInt()],
      style: style,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  List<String> getLastSevenDays() {
    DateTime now = DateTime.now();
    List<String> days = [];
    for (int i = 6; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      String day = DateFormat.E().format(date); // Short name of the day
      days.add(day);
    }
    return days;
  }

  BarChartData monitoringLogsData() {
    List<int> logInfoCounts = List.generate(7, (index) => 0);
    List<int> logErrorCounts = List.generate(7, (index) => 0);

    DateTime now = DateTime.now();
    for (var log in widget.logs) {
      DateTime logCreatedAt = DateTime.parse(log.createdAt);
      for (int i = 0; i < 7; i++) {
        DateTime start = now.subtract(Duration(days: i)).subtract(Duration(
            hours: now.hour,
            minutes: now.minute,
            seconds: now.second,
            milliseconds: now.millisecond,
            microseconds: now.microsecond));
        DateTime end = start.add(Duration(days: 1));

        if (logCreatedAt.isAfter(start) && logCreatedAt.isBefore(end)) {
          if (log.type == "error") {
            logErrorCounts[6 - i]++;
          } else {
            logInfoCounts[6 - i]++;
          }
          break;
        }
      }
    }

    return BarChartData(
      maxY: (logInfoCounts.reduce(max) + logInfoCounts.reduce(max) / 10)
          .ceil()
          .toDouble(),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipRoundedRadius: 10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              rodIndex == 0
                  ? "${logInfoCounts[group.x]} info logs"
                  : "${logErrorCounts[group.x]} error logs",
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            reservedSize: 40,
            showTitles: true,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: List.generate(
        7,
        (i) => makeGroupData(
            i,
            logInfoCounts[i].toDouble(),
            logErrorCounts[i].toDouble(),
            "${logInfoCounts[i]}",
            "${logErrorCounts[i]}"),
      ),
      gridData: const FlGridData(show: false),
    );
  }
}
