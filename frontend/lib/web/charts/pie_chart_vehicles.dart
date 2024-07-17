import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/vehicle.dart';

class PieChartVehicles extends StatefulWidget {
  final List<Vehicle> vehicles;

  const PieChartVehicles({super.key, required this.vehicles});

  @override
  State<StatefulWidget> createState() => PieChartVehiclesState();
}

class PieChartVehiclesState extends State<PieChartVehicles> {
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.airplanemode_active),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      'Verified vehicles chart',
                      style: TextStyle(
                        color: Color(0xFF131141),
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
                  child: PieChart(
                    PieChartData(
                      sections: getSections(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 0,
                    ),
                  ),
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Verified vehicles',
                      style: TextStyle(
                        color: Color(0xFF131141),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Unverified vehicles',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  List<PieChartSectionData> getSections() {
    int verified = 0;
    int unverified = 0;

    for (var vehicle in widget.vehicles) {
      if (vehicle.isVerified != false) {
        verified++;
      } else {
        unverified++;
      }
    }

    return [
      PieChartSectionData(
        color: const Color(0xFF131141),
        value: verified.toDouble(),
        title: '$verified',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.grey,
        value: unverified.toDouble(),
        title: '$unverified',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }
}