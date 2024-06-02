import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';

class CurrentFlightManagement extends StatefulWidget {
  const CurrentFlightManagement({super.key});

  @override
  State<CurrentFlightManagement> createState() =>
      _CurrentFlightManagementState();
}

class _CurrentFlightManagementState extends State<CurrentFlightManagement> {
  @override
  Widget build(BuildContext context) {
    if (context.read<SocketIoBloc>().state.status ==
        SocketIoStatus.disconnected) {
      final currentFlightState = context.read<CurrentFlightBloc>().state;

      context
          .read<SocketIoBloc>()
          .add(SocketIoCreateSession(flightId: currentFlightState.flight!.id));

      context.read<SocketIoBloc>().add(SocketIoListenEvent(
            event: "flightUpdated",
            callback: (_) {
              context.read<CurrentFlightBloc>().add(CurrentFlightUpdated());
            },
          ));
    }
    return Center(
      child: BlocConsumer<CurrentFlightBloc, CurrentFlightState>(
          listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      }, builder: (context, state) {
        if (state.flight!.status == 'waiting_pilot') {
          return Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: () {
                      context
                          .read<CurrentFlightBloc>()
                          .add(CurrentFlightLoaded(flight: state.flight!));
                    },
                    child: const Text("Focus on route")),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(children: [
                    const Text("Departure",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(state.flight!.departure.name)
                  ]),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(children: [
                    const Text("Arrival",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(state.flight!.arrival.name)
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 30),
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
            ElevatedButton(
              onPressed: () {
                // SocketProvider.of(context)!.socket.emit("cancelFlight", "${state.flight!.id}");
                context
                    .read<SocketIoBloc>()
                    .state
                    .socket!
                    .emit("cancelFlight", "${state.flight!.id}");
              },
              child: const Text("Cancel flight"),
            ),
            const SizedBox(height: 30),
          ]);
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
                      // SocketProvider.of(context)!.socket.emit("flightProposalChoice", jsonEncode({"flightId": state.flight!.id, "choice": "accepted"}));
                      context.read<SocketIoBloc>().state.socket!.emit(
                            "flightProposalChoice",
                            jsonEncode({
                              "flightId": state.flight!.id,
                              "choice": "accepted"
                            }),
                          );
                    },
                    child: const Text('Accept price offer'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SocketIoBloc>().state.socket!.emit(
                            "flightProposalChoice",
                            jsonEncode({
                              "flightId": state.flight!.id,
                              "choice": "rejected"
                            }),
                          );
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
      }),
    );
  }
}
