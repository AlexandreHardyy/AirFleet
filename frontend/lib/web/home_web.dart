import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:frontend/services/user.dart';
import 'package:frontend/services/vehicle.dart';
import 'package:frontend/web/charts/bar_chart.dart';
import 'package:frontend/web/charts/pie_chart.dart';
import 'package:frontend/web/user/user.dart';
import 'package:frontend/web/vehicle/vehicle.dart';

class HomeWeb extends StatefulWidget {
  const HomeWeb({super.key});

  @override
  State<HomeWeb> createState() => _HomeWebState();
}

class _HomeWebState extends State<HomeWeb> {
  List<User> _users = [];
  List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchVehicles();
  }

  Future<void> _fetchUsers() async {
    try {
      _users = await UserService.getUsers();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchVehicles() async {
    try {
      _vehicles = await VehicleService.getVehicles();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

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
                    leading: const Icon(FontAwesomeIcons.userTie, color: Color(0xFFDCA200)),
                    title: const Text('Users',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.airplanemode_active,
                        color: Color(0xFFDCA200)),
                    title: const Text('Vols',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const VehicleScreen()),
                      );
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
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.8,
                        children: [
                          _buildChart(CustomBarChart(users: _users)),
                          _buildChart(CustomPieChart(vehicles: _vehicles)),
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

  Widget _buildChart(Widget chart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Expanded(
          child: AspectRatio(
            aspectRatio: 2.5, // Adjust the aspect ratio to fit more charts
            child: chart,
          ),
        ),
      ],
    );
  }
}
