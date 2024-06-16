import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/models/flight.dart';

class WaitingProposalApprovalCard extends StatefulWidget {
  final Flight flight;

  const WaitingProposalApprovalCard({super.key, required this.flight});

  @override
  State<WaitingProposalApprovalCard> createState() =>
      _WaitingProposalApprovalCardState();
}

class _WaitingProposalApprovalCardState
    extends State<WaitingProposalApprovalCard> {
  String? estimatedFlightTime;
  late SocketIoBloc _socketIoBloc;

  @override
  void initState() {
    super.initState();
    _socketIoBloc = context.read<SocketIoBloc>();

    //TODO: Optimization to reproduce
    _socketIoBloc.add(SocketIoListenEvent(
      event: "flightTimeUpdated",
      callback: (estimatedFlightTime) {
        if (mounted) {
          setState(() {
            this.estimatedFlightTime = _formatFlightTime(estimatedFlightTime);
          });
        }
      },
    ));
  }

  @override
  void dispose() {
    _socketIoBloc.add(SocketIoStopListeningEvent(event: 'flightTimeUpdated'));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Price offer received !"),
        const SizedBox(height: 10),
        Text("Price : ${widget.flight.price}"),
        const SizedBox(height: 10),
        Text(
            "Pilot: ${widget.flight.pilot!.firstName} ${widget.flight.pilot!.lastName}"),
        const SizedBox(height: 10),
        Text("Aircraft : ${widget.flight.vehicle!.modelName}"),
        const SizedBox(height: 10),
        estimatedFlightTime == null
            ? const CircularProgressIndicator()
            : Text("Estimated flight time : $estimatedFlightTime"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                // SocketProvider.of(context)!.socket.emit("flightProposalChoice", jsonEncode({"flightId": flight!.id, "choice": "accepted"}));
                _socketIoBloc.state.socket!.emit(
                  "flightProposalChoice",
                  jsonEncode(
                      {"flightId": widget.flight.id, "choice": "accepted"}),
                );
              },
              child: const Text('Accept price offer'),
            ),
            ElevatedButton(
              onPressed: () {
                _socketIoBloc.state.socket!.emit(
                  "flightProposalChoice",
                  jsonEncode(
                      {"flightId": widget.flight.id, "choice": "rejected"}),
                );
              },
              child: const Text('Reject price offer'),
            ),
          ],
        ),
      ],
    );
  }
}

String _formatFlightTime(String estimatedFlightTimeStr) {
  double hours = double.parse(estimatedFlightTimeStr);
  int hh = hours.floor();
  int mm = ((hours - hh) * 60).round();
  return '${hh.toString().padLeft(2, '0')}h${mm.toString().padLeft(2, '0')}min';
}