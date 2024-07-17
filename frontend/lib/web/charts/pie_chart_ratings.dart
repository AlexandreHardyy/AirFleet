import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/rating.dart';

class PieChartRatings extends StatefulWidget {
  final List<Rating> ratings;

  const PieChartRatings({super.key, required this.ratings});

  @override
  State<StatefulWidget> createState() => PieChartRatingsState();
}

class PieChartRatingsState extends State<PieChartRatings> {
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
                    Icon(Icons.stars),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      'Pilot ratings chart',
                      style: TextStyle(
                        color: Color(0xFF131141),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 100,
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
                      '1 - Very poor',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '2 - Poor',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '3 - Average',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '4 - Good',
                      style: TextStyle(
                        color: Colors.lightGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '5 - Very good',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
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
    num rating1 = 0;
    num rating2 = 0;
    num rating3 = 0;
    num rating4 = 0;
    num rating5 = 0;

    for (var rating in widget.ratings) {
      if (rating.rating! <= 1) {
        rating1++;
      } else if (rating.rating! > 1 && rating.rating! <= 2) {
        rating1++;
      } else if (rating.rating! > 2 && rating.rating! <= 3) {
        rating2++;
      } else if (rating.rating! > 3 && rating.rating! <= 4) {
        rating3++;
      } else if (rating.rating! > 4 && rating.rating! < 5) {
        rating4++;
      } else if (rating.rating! == 5) {
        rating5++;
      }
    }

    return [
      PieChartSectionData(
        color: Colors.red,
        value: rating1.toDouble(),
        title: rating1.toString(),
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: rating2.toDouble(),
        title: rating2.toString(),
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.yellow,
        value: rating3.toDouble(),
        title: rating3.toString(),
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.lightGreen,
        value: rating4.toDouble(),
        title: rating4.toString(),
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.green,
        value: rating5.toDouble(),
        title: rating5.toString(),
        radius: 50,
      ),
    ];
  }
}
