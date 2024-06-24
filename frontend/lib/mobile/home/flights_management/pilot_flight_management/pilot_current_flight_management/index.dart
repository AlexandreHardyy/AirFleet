import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/mobile/home/flights_management/pilot_flight_management/pilot_current_flight_management/waiting_proposal_approval_card.dart';

class CurrentPilotFlightManagement extends StatefulWidget {
  const CurrentPilotFlightManagement({super.key});

  @override
  State<CurrentPilotFlightManagement> createState() =>
      _CurrentPilotFlightManagementState();
}

class _CurrentPilotFlightManagementState extends State<CurrentPilotFlightManagement> {
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
    return Center(
      child: BlocConsumer<CurrentFlightBloc, CurrentFlightState>(
          listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      }, builder: (context, state) {
        if (state.flight!.status == 'waiting_proposal_approval') {
          return WaitingProposalApprovalCard(flight: state.flight!);
        }

        if (state.flight!.status == 'waiting_takeoff') {
          return const Text("Waiting for takeoff");
        }

        if (state.flight!.status == 'in_progress') {
          return const Text("flight in progress");
        }

        return const Text('No flight selected');
      }),
    );
  }
}
