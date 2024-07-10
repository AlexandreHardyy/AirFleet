import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:frontend/routes.dart';
import 'package:frontend/services/flight.dart';
import 'package:frontend/services/vehicle.dart';
import 'package:frontend/services/user.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<User?> _currentUser;
  late Future<List<Vehicle>> _userVehicles;
  Future<List<Flight>>? _recentFlights;

  @override
  void initState() {
    super.initState();
    _currentUser = UserService.getCurrentUser();
    _userVehicles = VehicleService.getVehiclesForMe();
    _recentFlights = FlightService.getFlightsHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<User?>(
                    future: _currentUser,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return UserInfoCard(user: snapshot.data!);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Vehicle>>(
                    future: _userVehicles,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.data != null) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(Routes.userVehicles(context, vehicles: snapshot.data!));
                          },
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.directions_car, color: Color(0xFFDCA200),),
                              title: const Text('Vehicles'),
                              subtitle: Text('Total: ${snapshot.data!.length}'),
                            ),
                          ),
                        );
                      } else {
                        return const Text('No vehicles found.');
                      }
                    },
                  ),
                ),
              ],
            ),
            if (_recentFlights != null)
              FutureBuilder<List<Flight>>(
                future: _recentFlights,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.data != null) {
                    return ExpandableFlightList(flights: snapshot.data!);
                  } else {
                    return const Text('No recent flights found.');
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

class UserInfoCard extends StatelessWidget {
  final User user;

  const UserInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person, color : Color(0xFFDCA200)),
        title: Text('${user.firstName} ${user.lastName}'),
        subtitle: _displayRole(user.role),
      ),
    );
  }
}

Widget _displayRole(String role) {
  switch (role) {
    case 'ROLE_ADMIN':
      return const Text('Admin');
    case 'ROLE_USER':
      return const Text('User');
    case 'ROLE_PILOT':
      return const Text('Pilot');
    default:
      return const Text('Unknown Role');
  }
}

class ExpandableFlightList extends StatefulWidget {
  final List<Flight> flights;

  const ExpandableFlightList({super.key, required this.flights});

  @override
  _ExpandableFlightListState createState() => _ExpandableFlightListState();
}

class _ExpandableFlightListState extends State<ExpandableFlightList> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final flightsToShow = _isExpanded ? widget.flights : widget.flights.take(3).toList();

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: flightsToShow.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('${flightsToShow[index].departure.name} - ${flightsToShow[index].arrival.name}'),
              subtitle: Text(flightsToShow[index].status),
            );
          },
        ),
        if (widget.flights.length > 3)
          TextButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF131141)),
              ),
              foregroundColor: const Color(0xFF131141),
            ),
            child: Text(_isExpanded ? 'Show Less' : 'Show More'),
          )
      ],
    );
  }
}
