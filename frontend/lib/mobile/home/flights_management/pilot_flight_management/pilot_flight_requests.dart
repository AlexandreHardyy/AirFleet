import 'package:flutter/material.dart';
import 'package:frontend/mobile/blocs/pilot_status/pilot_status_bloc.dart';
import 'package:frontend/mobile/pilot_flight_request_detail.dart';
import 'package:frontend/models/flight.dart';

class PilotFlightRequests extends StatelessWidget {
  final CurrentPilotStatus status;
  final List<Flight>? flights;

  const PilotFlightRequests(
      {super.key, required this.status, required this.flights});

  @override
  Widget build(BuildContext context) {
    if (flights?.isNotEmpty == true) {
      return ListView.builder(
        itemCount: flights!.length,
        itemBuilder: (context, index) {
          Flight flight = flights![index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
                title:
                    Text("${flight.departure.name} -> ${flight.arrival.name}"),
                leading: const Icon(Icons.flight, color: Color(0xFFDCA200)),
                onTap: () {
                  FlightRequestDetail.navigateTo(context, flight: flight);
                }),
          );
        },
      );
    }

    if (status == CurrentPilotStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return const Center(child: Text('no flight requested yet'));
  }
}
