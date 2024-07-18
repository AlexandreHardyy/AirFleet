import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/models/rating.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:frontend/services/rating.dart';
import 'package:frontend/services/flight.dart';
import 'package:frontend/services/user.dart';
import 'package:frontend/services/vehicle.dart';
import 'package:frontend/web/charts/bar_chart_users.dart';
import 'package:frontend/web/charts/pie_chart_vehicles.dart';
import 'package:frontend/web/charts/pie_chart_ratings.dart';
import 'package:frontend/web/charts/bar_chart_payments.dart';
import 'package:frontend/web/flights/flight.dart';
import 'package:frontend/web/monitoring-logs/index.dart';
import 'package:frontend/web/user/user.dart';
import 'package:frontend/web/vehicle/vehicle.dart';
import 'package:frontend/widgets/navigation_web.dart';
import 'package:intl/intl.dart';

class HomeWeb extends StatefulWidget {
  const HomeWeb({super.key});

  @override
  State<HomeWeb> createState() => _HomeWebState();
}

class _HomeWebState extends State<HomeWeb> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<User> _users = [];
  List<Vehicle> _vehicles = [];
  List<Vehicle> _unverifiedVehicles = [];
  List<Rating> _ratings = [];
  List<Flight> _flights = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchVehicles();
    _fetchRatings();
    _fetchFlights();
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
      _filterUnverifiedVehicles();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void _filterUnverifiedVehicles() {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    _unverifiedVehicles = _vehicles.where((vehicle) {
      if (vehicle.isVerified == null || vehicle.createdAt == null) {
        return false;
      } else {
        DateTime vehicleDate;
        try {
          vehicleDate = DateTime.parse(vehicle.createdAt!);
        } catch (e) {
          return false;
        }
        return !vehicle.isVerified! && vehicleDate.isAfter(oneWeekAgo);
      }
    }).toList();
  }

  Future<void> _fetchRatings() async {
    try {
      _ratings = await RatingService.getAllRatings({"status": "reviewed"});
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> _verifyVehicle(Vehicle vehicle) async {
    try {
      vehicle.isVerified = true;
      await VehicleService.updateVehicle(vehicle);
      _fetchVehicles();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchFlights() async {
    try {
      _flights = await FlightService.getAllFlights();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Row(
            children: [
              const NavigationWeb(),
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
                            _buildChart(BarChartUsers(users: _users)),
                            _buildChart(PieChartVehicles(vehicles: _vehicles)),
                            _buildChart(PieChartRatings(ratings: _ratings)),
                            _buildChart(BarChartPayments(flights: _flights)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: Stack(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                  backgroundColor: const Color(0xFF131141),
                  child: const Icon(Icons.notifications, color: Color(0xFFDCA200)),
                ),
                if (_unverifiedVehicles.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      child: Text(
                        '${_unverifiedVehicles.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      endDrawer: _buildUnverifiedVehiclesDrawer(),
    );
  }

  Widget _buildUnverifiedVehiclesDrawer() {
    return Drawer(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _unverifiedVehicles.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF131141),
              ),
              child: Text(
                'Unverified Vehicles',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            );
          }
          final vehicle = _unverifiedVehicles[index - 1];
          return Column(
            children: [
              ListTile(
                title: Text(vehicle.modelName),
                subtitle: Text(DateFormat('yyyy-MM-dd')
                    .format(DateTime.parse(vehicle.createdAt!))),
                trailing: IconButton(
                  icon: const Icon(Icons.check_circle, color: Color(0xFFDCA200)),
                  tooltip: 'Verify this vehicle',
                  onPressed: () => _verifyVehicle(vehicle),
                ),
              ),
              if (index - 1 < _unverifiedVehicles.length - 1) const Divider(),
            ],
          );
        },
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
            aspectRatio: 2.5,
            child: chart,
          ),
        ),
      ],
    );
  }
}
