import 'package:flutter/material.dart';
import 'package:frontend/mobile/auth_screen/login_screen.dart';
import 'package:frontend/mobile/auth_screen/register_pilot_screen.dart';
import 'package:frontend/mobile/auth_screen/register_screen.dart';
import 'package:frontend/mobile/flight_history.dart';
import 'package:frontend/mobile/home/home.dart';
import 'package:frontend/mobile/pilot_flight_request_detail.dart';
import 'package:frontend/mobile/vehicles_management.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/web/home_web.dart';

import 'mobile/vehicle_detail.dart';

class Routes {
  static home(context) {
    return MaterialPageRoute(
      builder: (context) => const Home(),
    );
  }

  static homeWeb(context) {
    return MaterialPageRoute(
      builder: (context) => const HomeWeb(),
    );
  }

  static login(context) {
    return MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    );
  }

  static register(context) {
    return MaterialPageRoute(
      builder: (context) => const RegisterScreen(),
    );
  }

  static registerPilot(context) {
    return MaterialPageRoute(
      builder: (context) => const RegisterPilotScreen(),
    );
  }

  static flightHistory(context) {
    return MaterialPageRoute(
      builder: (context) => const FlightHistoryScreen(),
    );
  }

  static vehiclesManagement(context) {
    return MaterialPageRoute(
      builder: (context) => const VehiclesManagementScreen(),
    );
  }

  static flightRequestDetail(context, {required Flight flight}) {
    return MaterialPageRoute(
      builder: (context) => FlightRequestDetail(flight: flight),
    );
  }

  static vehicleDetail(context, {int? vehicleId}) {
    return MaterialPageRoute(
      builder: (context) => VehicleDetailsPage(vehicleId: vehicleId),
    );
  }
}
