import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/title.dart';

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
      eventId: "flightTimeUpdated",
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
    _socketIoBloc.add(SocketIoStopListeningEvent(eventId: 'flightTimeUpdated'));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SecondaryTitle(content: "Price offer received"),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text(
              "Pilot : ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
                "${widget.flight.pilot!.firstName} ${widget.flight.pilot!.lastName}")
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              "Price : ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("${widget.flight.price} USD")
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              "Aircraft : ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.flight.vehicle!.modelName)
          ],
        ),
        const SizedBox(height: 8),
        estimatedFlightTime == null
            ? const CircularProgressIndicator()
            : Row(
                children: [
                  const Text(
                    "Estimated flight time : ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("$estimatedFlightTime")
                ],
              ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // SocketProvider.of(context)!.socket.emit("flightProposalChoice", jsonEncode({"flightId": flight!.id, "choice": "accepted"}));
                  _socketIoBloc.state.socket!.emit(
                    "flightProposalChoice",
                    jsonEncode(
                        {"flightId": widget.flight.id, "choice": "accepted"}),
                  );
                },
                child: const Text('Accept offer'),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                style: dangerButtonStyle,
                onPressed: () {
                  _socketIoBloc.state.socket!.emit(
                    "flightProposalChoice",
                    jsonEncode(
                        {"flightId": widget.flight.id, "choice": "rejected"}),
                  );
                },
                child: const Text('Reject offer'),
              ),
            )
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
