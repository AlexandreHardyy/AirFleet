import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/mobile/profile/user_flights_list.dart';
import 'package:frontend/mobile/profile/user_ratings.dart';
import 'package:frontend/models/rating.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:frontend/services/flight.dart';
import 'package:frontend/services/rating.dart';
import 'package:frontend/services/vehicle.dart';
import 'package:frontend/services/user.dart';
import 'package:frontend/storage/user.dart';
import 'package:frontend/widgets/profile_image_form.dart';

import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class UserProfileScreen extends StatefulWidget {
  static const route = '/profile';

  static Future<void> navigateTo(BuildContext context) {
    return Navigator.of(context).pushNamed(route);
  }

  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<User?> _currentUser;
  late Future<List<Vehicle>> _userVehicles;
  Future<List<Flight>>? _recentFlights;
  late Future<List<Rating>> _ratings;

  @override
  void initState() {
    super.initState();
    _currentUser = UserService.getCurrentUser();
    _userVehicles = VehicleService.getVehiclesForMe();
    _recentFlights = FlightService.getFlightsHistory();
    _ratings = RatingService.getRatingsByPilotID(
        UserStore.user!.id, {"status": "reviewed"});
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
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  'assets/images/flight_banner.jpg',
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: -50,
                  child: Container(
                    width: 102,
                    height: 102,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF131141),
                        width: .5,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: ProfileImageForm(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 64),
            FutureBuilder<User?>(
              future: _currentUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final user = snapshot.data!;
                  return Column(
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _displayRole(user.role),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  );
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (UserStore.user!.role == 'ROLE_PILOT')
                    FutureBuilder<List<Vehicle>>(
                      future: _userVehicles,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Icon(Icons.error, color: Colors.red);
                        } else {
                          return TotalVehicleInfo(vehicles: snapshot.data!);
                        }
                      },
                    ),
                  if (UserStore.user!.role == 'ROLE_PILOT')
                    const SizedBox(
                      height: 30,
                      child: VerticalDivider(
                        width: 20,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                  FutureBuilder<List<Flight>>(
                    future: _recentFlights,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Icon(Icons.error, color: Colors.red);
                      } else {
                        return TotalRevenueInfo(flights: snapshot.data!);
                      }
                    },
                  ),
                  if (UserStore.user!.role == 'ROLE_PILOT')
                    const SizedBox(
                      height: 30,
                      child: VerticalDivider(
                        width: 20,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                  if (UserStore.user!.role == 'ROLE_PILOT')
                    FutureBuilder<List<Rating>>(
                      future: _ratings,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Icon(Icons.error, color: Colors.red);
                        } else {
                          return TotalRatingInfo(ratings: snapshot.data!);
                        }
                      },
                    ),
                ],
              ),
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
                    return Container(
                      color: Colors.grey[300],
                      child: ExpandableFlightList(flights: snapshot.data!),
                    );
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

String _displayRole(String role) {
  switch (role) {
    case 'ROLE_ADMIN':
      return translate('common.role.admin');
    case 'ROLE_USER':
      return translate('common.role.user');
    case 'ROLE_PILOT':
      return translate('common.role.pilot');
    default:
      return translate('common.role.unknown');
  }
}

class TotalVehicleInfo extends StatelessWidget {
  final List<Vehicle> vehicles;

  const TotalVehicleInfo({super.key, required this.vehicles});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.directions_car, color: Color(0xFFDCA200), size: 40),
        Text(
          '${vehicles.length}',
          style: const TextStyle(
            color: Color(0xFF131141),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class TotalRevenueInfo extends StatelessWidget {
  final List<Flight> flights;

  const TotalRevenueInfo({super.key, required this.flights});

  double get totalRevenue => flights.fold(
      0,
      (previousValue, flight) => flight.status == "finished" || flight.status == "in_progress" || flight.status == "waiting_takeoff"
          ? previousValue + flight.price!
          : previousValue);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.euro, color: Color(0xFFDCA200), size: 40),
        Text(
          '$totalRevenue',
          style: const TextStyle(
            color: Color(0xFF131141),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class TotalRatingInfo extends StatelessWidget {
  final List<Rating> ratings;

  const TotalRatingInfo({super.key, required this.ratings});

  double get sumRate => ratings.fold(
      0, (previousValue, rating) => previousValue + rating.rating!);

  double get globalRate =>
      double.parse((sumRate / ratings.length).toStringAsFixed(2));

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        UserRatingsScreen.navigateTo(context, ratings: ratings);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.star, color: Color(0xFFDCA200), size: 40),
            Text(
              '$globalRate',
              style: const TextStyle(
                color: Color(0xFF131141),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
