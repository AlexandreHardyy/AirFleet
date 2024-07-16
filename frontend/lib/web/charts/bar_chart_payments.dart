import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/flight.dart';
import 'package:intl/intl.dart';

class BarChartPayments extends StatefulWidget {
  final Color barColor = const Color(0xFF131141);
  final List<Flight> flights;

  const BarChartPayments({super.key, required this.flights});

  @override
  State<StatefulWidget> createState() => BarChartPaymentsState();
}

class BarChartPaymentsState extends State<BarChartPayments> {
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
                    const Icon(Icons.euro),
                    const SizedBox(
                      width: 16,
                    ),
                    Text(
                      'Monthly Payments Chart',
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
                    flightData(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: widget.barColor,
          width: 22,
          borderRadius: BorderRadius.zero,
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

  BarChartData flightData() {
    List<double> flightSums = List.generate(6, (index) => 0.0);

    DateTime now = DateTime.now();
    for (var flight in widget.flights) {
      if (flight.status != "finished") {
        continue;
      }
      DateTime flightCreatedAt = DateFormat('yyyy-MM-dd').parse(flight.createdAt!);
      for (int i = 0; i < 6; i++) {
        DateTime start = DateTime(now.year, now.month - i, 1);
        DateTime end = DateTime(now.year, now.month - i + 1, 1);
        if (flightCreatedAt.isAfter(start) && flightCreatedAt.isBefore(end)) {
          flightSums[5 - i] += flight.price!;
          break;
        }
      }
    }

    return BarChartData(
      maxY: (flightSums.reduce(max) + flightSums.reduce(max) / 10).ceil().toDouble(),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipRoundedRadius: 30,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${flightSums[group.x].toStringAsFixed(2)} €',
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
            (i) => makeGroupData(i, flightSums[i]),
      ),
      gridData: const FlGridData(show: false),
    );
  }
}
