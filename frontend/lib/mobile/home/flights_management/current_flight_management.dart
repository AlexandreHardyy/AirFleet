import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/home/blocs/current_flight_bloc.dart';
import 'package:frontend/services/socketio.dart';


class CurrentFlightManagement extends StatefulWidget {
  const CurrentFlightManagement({super.key});

  @override
  State<CurrentFlightManagement> createState() => _CurrentFlightManagementState();
}

class _CurrentFlightManagementState extends State<CurrentFlightManagement> {


  @override
  Widget build(BuildContext context) {
    if (context.mounted) {
      SocketProvider.of(context)!.socket.connect();

      final currentFlightState = context.read<CurrentFlightBloc>().state;

      SocketProvider.of(context)!.socket.emit("createSession", "${currentFlightState.flight!.id}");

      SocketProvider.of(context)!.socket.on("flightUpdated", (_) {
        context.read<CurrentFlightBloc>().add(CurrentFlightUpdated());
      });
    }
    return Center(
      child: BlocConsumer<CurrentFlightBloc, CurrentFlightState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.flight!.status == 'waiting_pilot') {
            return Column(
              children: [
                ElevatedButton(
                    onPressed: () {
                      context.read<CurrentFlightBloc>().add(CurrentFlightLoaded(flight: state.flight!));
                    },
                    child: const Text("Focus on route")
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text("Departure:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(state.flight!.departure.name)
                      ]
                    ),
                    Column(
                      children: [
                        const Text("Arrival:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(state.flight!.arrival.name)
                      ]
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text("Waiting for a pilot to accept the flight"),
                const LinearProgressIndicator(),
                ElevatedButton(
                    onPressed: () {
                      SocketProvider.of(context)!.socket.emit("cancelFlight", "${state.flight!.id}");
                    },
                    child: const Text("Cancel flight"))
              ]
            );
          }

          if (state.flight!.status == 'waiting_proposal_approval') {
            return Column(
              children: [
                const Text("Price offer received !"),
                const SizedBox(height: 10),
                Text("Price : ${state.flight!.price}"),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        SocketProvider.of(context)!.socket.emit("flightProposalChoice", jsonEncode({"flightId": state.flight!.id, "choice": "accepted"}));
                      },
                      child: const Text('Accept price offer'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        SocketProvider.of(context)!.socket.emit("flightProposalChoice", jsonEncode({"flightId": state.flight!.id, "choice": "rejected"}));
                      },
                      child: const Text('Reject price offer'),
                    ),
                  ],
                ),
              ],
            );
          }

          if (state.flight!.status == 'waiting_takeoff') {
            return const Text("Waiting for takeoff");
          }

          if (state.flight!.status == 'in_progress') {
            return const Text("In flight");
          }

          return const Text('No flight selected');
        }
      ),
    );
  }
}
