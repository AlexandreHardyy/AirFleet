import 'package:flutter/material.dart';
import 'package:frontend/mobile/auth_screen/login_screen.dart';
import 'package:frontend/mobile/auth_screen/register_pilot_screen.dart';
import 'package:frontend/mobile/auth_screen/register_screen.dart';
import 'package:frontend/mobile/flight_chat.dart';
import 'package:frontend/mobile/flight_history.dart';
import 'package:frontend/mobile/home/home.dart';
import 'package:frontend/mobile/pilot_flight_request_detail.dart';
import 'package:frontend/mobile/profile/user_profile.dart';
import 'package:frontend/mobile/profile/user_vehicles.dart';
import 'package:frontend/mobile/proposal/proposal_detail.dart';
import 'package:frontend/mobile/vehicles_management.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:frontend/web/home_web.dart';
import 'package:frontend/mobile/vehicle_detail.dart';
import 'package:frontend/web/module/module.dart';
import 'package:frontend/web/user/user.dart';
import 'package:frontend/web/vehicle/vehicle.dart';
import 'mobile/flight_details.dart';
import 'mobile/proposal/proposals_management.dart';

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

  static userProfile(context) {
    return MaterialPageRoute(
      builder: (context) => const UserProfileScreen(),
    );
  }

  static userVehicles(context, {required List<Vehicle> vehicles}) {
    return MaterialPageRoute(
      builder: (context) => UserVehiclesScreen(vehicles: vehicles),
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

  static flightChat(context, {required int flightId}) {
    return MaterialPageRoute(
      builder: (context) => FlightChat(flightId: flightId),
    );
  }

  static flightDetails(context, {required int flightId}) {
    return MaterialPageRoute(
      builder: (context) => FlightDetails(flightId: flightId),
    );
  }

  static proposalsManagement(context) {
    return MaterialPageRoute(
      builder: (context) => const ProposalsManagementScreen(),
    );
  }

  static proposalDetail(context, {required int proposalId}) {
    return MaterialPageRoute(
      builder: (context) => ProposalDetail(proposalId: proposalId),
    );
  }

  //WEB

  static userScreen(context) {
    return MaterialPageRoute(
      builder: (context) => const UserScreen(),
    );
  }

  static vehicleScreen(context) {
    return MaterialPageRoute(
      builder: (context) => const VehicleScreen(),
    );
  }

  static moduleScreen(context) {
    return MaterialPageRoute(
      builder: (context) => const ModuleScreen(),
    );
  }
}
