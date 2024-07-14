import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/widgets/departure_to_arrival.dart';
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
        DepartureToArrivalWidget(flight: widget.flight),
        const SizedBox(height: 24),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Waiting for a pilot to accept the flight"),
                SizedBox(height: 10),
                LinearProgressIndicator(color: Color(0xFF131141),),
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
