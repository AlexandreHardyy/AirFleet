import 'package:flutter/material.dart';
import 'package:frontend/mobile/auth_screen/login_screen.dart';
import 'package:frontend/mobile/auth_screen/register_pilot_screen.dart';
import 'package:frontend/mobile/auth_screen/register_screen.dart';
import 'package:frontend/mobile/flight_history.dart';
import 'package:frontend/mobile/home/home.dart';

class Routes {
  static home(context) {
    return MaterialPageRoute(
      builder: (context) => const Home(),
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
}