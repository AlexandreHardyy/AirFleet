import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/web/user/user.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeWeb extends StatefulWidget {
  const HomeWeb({super.key});

  @override
  State<HomeWeb> createState() => _HomeWebState();
}

class _HomeWebState extends State<HomeWeb> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            Container(
              width: 200,
              color: const Color(0xFF131141),
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Admin Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFFDCA200)),
                    title: const Text('User', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(FontAwesomeIcons.userTie, color: Color(0xFFDCA200)),
                    title: const Text('Pilots', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      // Handle navigation to Pilots page
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.airplanemode_active, color: Color(0xFFDCA200)),
                    title: const Text('Vols', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      // Handle navigation to Vols page
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF131141),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildChartCard('Line Chart', _buildLineChart()),
                          _buildChartCard('Bar Chart', _buildBarChart()),
                          _buildChartCard('Pie Chart', _buildPieChart()),
                          _buildChartCard('Scatter Plot', _buildScatterChart()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF131141)),
          bodyMedium: TextStyle(color: Color(0xFF131141)),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFDCA200),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Color(0xFFDCA200)),
          titleTextStyle: TextStyle(color: Color(0xFF131141), fontSize: 20),
          toolbarTextStyle: TextStyle(color: Color(0xFF131141)),
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF131141),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(1, 1),
              FlSpot(2, 4),
              FlSpot(3, 3),
              FlSpot(4, 5),
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(toY: 8, color: Colors.blue),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(toY: 10, color: Colors.blue),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(toY: 14, color: Colors.blue),
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(toY: 15, color: Colors.blue),
            ],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [
              BarChartRodData(toY: 13, color: Colors.blue),
            ],
          ),
        ],
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: 40,
            color: Colors.blue,
            title: '40%',
          ),
          PieChartSectionData(
            value: 30,
            color: Colors.red,
            title: '30%',
          ),
          PieChartSectionData(
            value: 20,
            color: Colors.green,
            title: '20%',
          ),
          PieChartSectionData(
            value: 10,
            color: Colors.yellow,
            title: '10%',
          ),
        ],
      ),
    );
  }

  Widget _buildScatterChart() {
    return ScatterChart(
      ScatterChartData(
        scatterSpots: [
          ScatterSpot(2, 3, dotPainter: FlDotCirclePainter(color: Colors.blue, radius: 6)),
          ScatterSpot(3, 4, dotPainter: FlDotCirclePainter(color: Colors.red, radius: 8)),
          ScatterSpot(4, 5, dotPainter: FlDotCirclePainter(color: Colors.green, radius: 7)),
          ScatterSpot(5, 6, dotPainter: FlDotCirclePainter(color: Colors.yellow, radius: 5)),
        ],
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
      ),
    );
  }
}
