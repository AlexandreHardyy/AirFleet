import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/routes.dart';
import 'package:frontend/utils/utils.dart';
import 'package:frontend/widgets/title.dart';

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
            remainingTime =
                formatFlightTime(jsonData['estimated_flight_time'].toString());
            remainingDistance = jsonData['remaining_distance'];
          });
        }
      },
    ));
  }

  @override
  void dispose() {
    _socketIoBloc
        .add(SocketIoStopListeningEvent(eventId: 'pilotPositionUpdated2'));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SecondaryTitle(content: 'Flight in progress'),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text(
                    "Departure",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.flight.departure.name,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                context
                    .read<CurrentFlightBloc>()
                    .add(CurrentFlightLoaded(flight: widget.flight));
              },
              child: const Icon(Icons.arrow_circle_right),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    "Arrival",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.flight.arrival.name,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text("Remaining time: $remainingTime"),
        const SizedBox(height: 10),
        Text("Remaining distance: $remainingDistance nm"),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(Routes.flightChat(context, flightId: widget.flight.id));
                },
                child: const Icon(Icons.chat),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
