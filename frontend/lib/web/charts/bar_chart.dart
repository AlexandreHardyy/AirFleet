import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:intl/intl.dart';

class CustomBarChart extends StatefulWidget {
  final Color barColor = const Color(0xFF131141);
  final List<User> users;

  const CustomBarChart({super.key, required this.users});

  @override
  State<StatefulWidget> createState() => CustomBarChartState();
}

class CustomBarChartState extends State<CustomBarChart> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    const Icon(Icons.person),
                    const SizedBox(
                      width: 32,
                    ),
                    Text(
                      'Sales forecasting chart',
                      style: TextStyle(
                        color: widget.barColor,
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
                    userData(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y, String label) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: x >= 6 ? Colors.transparent : widget.barColor,
          borderRadius: BorderRadius.zero,
          borderDashArray: x >= 6 ? [4, 4] : null,
          width: 22,
          borderSide: BorderSide(color: widget.barColor, width: 2.0),
          rodStackItems: [
            BarChartRodStackItem(
              0,
              y,
              widget.barColor,
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

    List<String> months = getLastSixMonths();

    Widget text = Text(
      months[value.toInt()],
      style: style,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  List<String> getLastSixMonths() {
    DateTime now = DateTime.now();
    List<String> months = [];
    for (int i = 5; i >= 0; i--) {
      DateTime date = DateTime(now.year, now.month - i, 1);
      String month = DateFormat.MMM().format(date);
      months.add(month);
    }
    return months;
  }

  BarChartData userData() {
    List<int> userCounts = List.generate(6, (index) => 0);

    DateTime now = DateTime.now();
    for (var user in widget.users) {
      DateTime userCreatedAt = DateFormat('yyyy-MM-dd').parse(user.createdAt);
      for (int i = 0; i < 6; i++) {
        DateTime start = DateTime(now.year, now.month - i, 1);
        DateTime end = DateTime(now.year, now.month - i + 1, 1);
        if (userCreatedAt.isAfter(start) && userCreatedAt.isBefore(end)) {
          userCounts[5 - i]++;
          break;
        }
      }
    }

    return BarChartData(
      maxY: (userCounts.reduce(max) + userCounts.reduce(max) / 10).ceil().toDouble(),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipRoundedRadius: 30,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${userCounts[group.x]}',
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
        6,
            (i) => makeGroupData(i, userCounts[i].toDouble(), '${userCounts[i]}'),
      ),
      gridData: const FlGridData(show: false),
    );
  }
}
