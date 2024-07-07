import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/mobile/home/flights_management/user_flight_management/user_current_flight_management/waiting_proposal_approval_card.dart';
import 'package:frontend/mobile/home/flights_management/user_flight_management/user_current_flight_management/waiting_takeoff.dart';
import 'package:frontend/widgets/button.dart';

import 'in_progress.dart';

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
            eventId: "flightUpdated",
            event: "flightUpdated",
            callback: (_) {
              context.read<CurrentFlightBloc>().add(CurrentFlightUpdated());
            },
          ));
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: BlocConsumer<CurrentFlightBloc, CurrentFlightState>(
          listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      }, builder: (context, state) {
        if (state.flight!.status == 'waiting_pilot') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text("Departure",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(state.flight!.departure.name)
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      context
                          .read<CurrentFlightBloc>()
                          .add(CurrentFlightLoaded(flight: state.flight!));
                    },
                    child: const Icon(Icons.arrow_circle_right),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        const Text("Arrival",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(state.flight!.arrival.name)
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
                      .emit("cancelFlight", "${state.flight!.id}");
                },
                child: const Text("Cancel flight"),
              ),
              const SizedBox(height: 30),
            ],
          );
        }

        if (state.flight!.status == 'waiting_proposal_approval') {
          return WaitingProposalApprovalCard(flight: state.flight!);
        }

        if (state.flight!.status == 'waiting_takeoff') {
          return WaitingTakeoff(flight: state.flight!);
        }

        if (state.flight!.status == 'in_progress') {
          return InProgressFlightCard(flight: state.flight!);
        }

        return const Text('No flight selected');
      }),
    );
  }
}
