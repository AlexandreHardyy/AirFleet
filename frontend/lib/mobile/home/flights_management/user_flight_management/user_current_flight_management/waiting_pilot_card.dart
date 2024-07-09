import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/widgets/button.dart';

class WaitingPilotCard extends StatefulWidget {
  final Flight flight;

  const WaitingPilotCard({super.key, required this.flight});

  @override
  State<WaitingPilotCard> createState() => _WaitingPilotCardState();
}

class _WaitingPilotCardState extends State<WaitingPilotCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text(
                    "Departure",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.flight.departure.name,
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
                    .add(CurrentFlightLoaded(flight: widget.flight));
              },
              child: const Icon(Icons.arrow_circle_right),
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
                    widget.flight.arrival.name,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Waiting for a pilot to accept the flight"),
                SizedBox(height: 10),
                LinearProgressIndicator(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: dangerButtonStyle,
          onPressed: () {
            // SocketProvider.of(context)!.socket.emit("cancelFlight", "${state.flight!.id}");
            context
                .read<SocketIoBloc>()
                .state
                .socket!
                .emit("cancelFlight", "${widget.flight.id}");
          },
          child: const Text("Cancel flight"),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
