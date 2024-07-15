import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/mobile/flight_chat.dart';
import 'package:frontend/widgets/departure_to_arrival.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/utils/utils.dart';
import 'package:frontend/widgets/title.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
  double? progress;

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

            final totalDistance = jsonData['total_distance'];

            if (totalDistance != 0) {
              progress = (totalDistance - remainingDistance!) / totalDistance;
            }
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
        SecondaryTitle(content: translate('home.flight_management.user_current_flight_management.in_progress.title')),
        const SizedBox(height: 24),
        DepartureToArrivalWidget(flight: widget.flight),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFF131141)),
                const SizedBox(width: 5),
                Skeletonizer(
                  enabled: remainingTime == null,
                  child: Text(remainingTime == null ? "Loading" : remainingTime!),
                )
              ],
            ),
            Row(
              children: [
                const Icon(Icons.map, color: Color(0xFF131141)),
                const SizedBox(width: 5),
                Skeletonizer(
                  enabled: remainingDistance == null,
                  child: Text(remainingDistance == null ? "Loading" : "$remainingDistance km"),
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: progress,
          color: const Color(0xFF131141),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  FlightChat.navigateTo(context, flightId: widget.flight.id);
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
