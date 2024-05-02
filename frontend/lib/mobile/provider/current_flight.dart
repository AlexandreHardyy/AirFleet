import 'package:flutter/material.dart';
import 'package:frontend/models/flight.dart';

class CurrentFlight extends ChangeNotifier {
  Flight? _flight;

  Flight? get flight => _flight;

  void setFlight(Flight? flight) {
    _flight = flight;

    notifyListeners();
  }
}