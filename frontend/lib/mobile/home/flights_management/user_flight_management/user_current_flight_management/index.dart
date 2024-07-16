import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/message/message_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/mobile/home/flights_management/user_flight_management/user_current_flight_management/waiting_pilot_card.dart';
import 'package:frontend/mobile/home/flights_management/user_flight_management/user_current_flight_management/waiting_proposal_approval_card.dart';
import 'package:frontend/mobile/home/flights_management/user_flight_management/user_current_flight_management/waiting_takeoff.dart';
import 'package:frontend/models/message.dart';

import 'in_progress.dart';

class CurrentFlightManagement extends StatefulWidget {
  const CurrentFlightManagement({super.key});

  @override
  State<CurrentFlightManagement> createState() =>
      _CurrentFlightManagementState();
}

class _CurrentFlightManagementState extends State<CurrentFlightManagement> {
  late SocketIoBloc _socketIoBloc;

  @override
  void initState() {
    super.initState();

    _socketIoBloc = context.read<SocketIoBloc>();

    if (_socketIoBloc.state.status == SocketIoStatus.disconnected) {
      final currentFlightState = context.read<CurrentFlightBloc>().state;

      _socketIoBloc.state.socket!.connect();
      _socketIoBloc
          .add(SocketIoCreateSession(flightId: currentFlightState.flight!.id));
      _socketIoBloc.state.socket!.onReconnect((data) => {
            print("Reconnected to socket.io server"),
            _socketIoBloc.add(
                SocketIoCreateSession(flightId: currentFlightState.flight!.id))
          });

      _socketIoBloc.add(SocketIoListenEvent(
        eventId: "flightUpdated",
        event: "flightUpdated",
        callback: (_) {
          context.read<CurrentFlightBloc>().add(CurrentFlightUpdated());
        },
      ));

      _socketIoBloc.add(SocketIoListenEvent(
        eventId: "newMessageFront",
        event: "newMessageFront",
        callback: (message) {
          Map<String, dynamic> messageMap = jsonDecode(message);
          Message convertedMessage = Message.fromJson(messageMap);

          context
              .read<MessageBloc>()
              .add(NewMessage(message: convertedMessage));
        },
      ));
    }
  }

  @override
  void dispose() {
    _socketIoBloc.add(SocketIoStopListeningEvent(eventId: 'flightUpdated'));
    _socketIoBloc.add(SocketIoStopListeningEvent(eventId: 'newMessageFront'));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          return WaitingPilotCard(flight: state.flight!);
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
