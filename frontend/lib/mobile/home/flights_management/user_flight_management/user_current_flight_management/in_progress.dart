import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/utils/utils.dart';

class InProgressFlightCard extends StatefulWidget {
  final Flight flight;

  const InProgressFlightCard({super.key, required this.flight});

  @override
  State<InProgressFlightCard> createState() => _InProgressFlightCardState();
}

class _InProgressFlightCardState extends State<InProgressFlightCard> {
  late SocketIoBloc _socketIoBloc;

  String? remainingTime;
  num? remainingDistance;

  @override
  void initState() {
    super.initState();
    _socketIoBloc = context.read<SocketIoBloc>();

    _socketIoBloc.add(SocketIoListenEvent(
      eventId: "pilotPositionUpdated2",
      event: "pilotPositionUpdated",
      callback: (data) {
        Map<String, dynamic> jsonData = jsonDecode(data);
        if (mounted) {
          setState(() {
            remainingTime = formatFlightTime(jsonData['estimated_flight_time'].toString());
            remainingDistance = jsonData['remaining_distance'];
          });
        }
      },
    ));
  }

  @override
  void dispose() {
    _socketIoBloc.add(SocketIoStopListeningEvent(eventId: 'pilotPositionUpdated2'));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                context
                    .read<CurrentFlightBloc>()
                    .add(CurrentFlightLoaded(flight: widget.flight));
              },
              child: const Text("Focus on route"),
            ),
            const SizedBox(width: 10),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: Text(widget.flight.departure.name)),
            const Icon(Icons.arrow_forward),
            Expanded(child: Text(widget.flight.arrival.name)),
          ]
        ),
        const SizedBox(height: 10),
        Text("Remaining time: $remainingTime"),
        const SizedBox(height: 10),
        Text("Remaining distance: $remainingDistance nm"),
      ],
    );
  }
}
