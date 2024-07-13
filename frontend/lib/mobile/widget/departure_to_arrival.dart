import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/models/flight.dart';

class DepartureToArrivalWidget extends StatelessWidget {
  final Flight flight;
  const DepartureToArrivalWidget({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              const Text(
                "Departure",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                flight.departure.name,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () {
            context
                .read<CurrentFlightBloc>()
                .add(CurrentFlightLoaded(flight: flight));
          },
          child: const Icon(Icons.arrow_circle_right, color: Color(0xFF131141),),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              const Text(
                "Arrival",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                flight.arrival.name,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ],
    );
  }
}
