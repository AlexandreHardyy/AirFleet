import 'package:flutter/material.dart';
import 'package:frontend/models/flight.dart';

class FlightDetailsScreen extends StatelessWidget {
  static const routeName = '/flight-details';

  static Future<void> navigateTo(BuildContext context, {required Flight flight}) {
    return Navigator.of(context).pushNamed(routeName, arguments: flight);
  }

  final Flight flight;

  const FlightDetailsScreen({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Details'),
        backgroundColor: const Color(0xFF131141),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Flight Information',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Departure: ${flight.departure.name}', style: const TextStyle(fontSize: 18)),
                      Text('Arrival: ${flight.arrival.name}', style: const TextStyle(fontSize: 18)),
                      Text('Price: ${flight.price.toString()} €', style: const TextStyle(fontSize: 18)),
                      Text('Status: ${flight.status}', style: const TextStyle(fontSize: 18)),
                      Text('Pilot: ${flight.pilot?.firstName} ${flight.pilot?.lastName}', style: const TextStyle(fontSize: 18)),
                      Text('Vehicle: ${flight.vehicle?.modelName ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}