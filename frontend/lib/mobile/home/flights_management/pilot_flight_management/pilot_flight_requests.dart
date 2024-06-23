import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/pilot_status/pilot_status_bloc.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/routes.dart';

class PilotFlightRequests extends StatelessWidget {
  const PilotFlightRequests({super.key});

  @override
  Widget build(BuildContext context) {
    final statePilot = context.read<PilotStatusBloc>().state;

    final flights = statePilot.flights;
    if (flights?.isNotEmpty == true) {
      return ListView.builder(
        itemCount: flights!.length,
        itemBuilder: (context, index) {
          Flight flight = flights[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
                title:
                    Text("${flight.departure.name} -> ${flight.arrival.name}"),
                leading: const Icon(Icons.flight, color: Color(0xFFDCA200)),
                onTap: () {
                  Navigator.of(context).push(
                      Routes.flightRequestDetail(context, flight: flight));
                }),
          );
        },
      );
    }

    if (statePilot.status == CurrentPilotStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return const Center(child: Text('no flight requested yet'));
  }
}
