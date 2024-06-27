import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/widgets/title.dart';

class WaitingForTakeoff extends StatelessWidget {
  final Flight flight;
const WaitingForTakeoff({ super.key, required this.flight });

  @override
  Widget build(BuildContext context){
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MainTitle(
                content:
                    '${flight.departure.name} -> ${flight.arrival.name}'),
            const SizedBox(
              height: 24,
            ),
            const Text('Press start when the flight is ready for takeoff'),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
              onPressed: () {
                context.read<SocketIoBloc>().add(SocketIoFlightTakeoff(flightId: flight.id));
              },
              child: const Text('Start takeoff'),
            ),
          ],
        ));
  }
}