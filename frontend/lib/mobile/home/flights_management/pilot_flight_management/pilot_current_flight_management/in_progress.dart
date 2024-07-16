import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/widgets/departure_to_arrival.dart';

class FlightInProgress extends StatelessWidget {
  final Flight flight;
  const FlightInProgress({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DepartureToArrivalWidget(flight: flight),
            const SizedBox(
              height: 24,
            ),
            const Text('Flight in progress'),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
              onPressed: () {
                context.read<SocketIoBloc>().tickerSubscription?.cancel();
                context
                    .read<SocketIoBloc>()
                    .state
                    .socket!
                    .emit("flightLanding", "${flight.id}");
                context.read<CurrentFlightBloc>().add(CurrentFlightUpdated());
              },
              child: Text(translate(
                  "home.flight_management.pilot_current_flight_management.in_progress.button")),
            ),
          ],
        ));
  }
}
