import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';

class WaitingPilotAcceptJoinCard extends StatefulWidget {
  final int userId;

  const WaitingPilotAcceptJoinCard({super.key, required this.userId});

  @override
  _WaitingPilotAcceptJoinCardState createState() =>
      _WaitingPilotAcceptJoinCardState();
}

class _WaitingPilotAcceptJoinCardState
    extends State<WaitingPilotAcceptJoinCard> {
  late SocketIoBloc _socketIoBloc;
  late CurrentFlightBloc _currentFlightBloc;

  @override
  void initState() {
    super.initState();
    _socketIoBloc = context.read<SocketIoBloc>();
    _currentFlightBloc = context.read<CurrentFlightBloc>();
  }

  void onAccept() {
    // final currentFlightState = context.read<CurrentFlightBloc>().state;
    // _socketIoBloc.add(SocketIoManageUserJoiningFlight(
    //     flightId: currentFlightState.flight!.id, userId: widget.userId, choice: "accepted"));

    _socketIoBloc.state.socket!.emit("manageUserJoiningFlight", jsonEncode({
      "flightId": _currentFlightBloc.state.flight!.id,
      "userId": widget.userId,
      "choice": "accepted",
    }));

    Navigator.of(context).pop();
  }

  void onRefuse() {
    // final currentFlightState = context.read<CurrentFlightBloc>().state;
    // _socketIoBloc.add(SocketIoManageUserJoiningFlight(
    //     flightId: currentFlightState.flight!.id, userId: widget.userId, choice: "refused"));

    _socketIoBloc.state.socket!.emit("manageUserJoiningFlight", jsonEncode({
      "flightId": _currentFlightBloc.state.flight!.id,
      "userId": widget.userId,
      "choice": "refused",
    }));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Someone want to join your flight',
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: onAccept,
                child: const Text('Accept'),
              ),
              ElevatedButton(
                onPressed: onRefuse,
                child: const Text('Refuse'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
