import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/mobile/widget/departure_to_arrival.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/widgets/button.dart';

class WaitingPilotToJoin extends StatefulWidget {
  final Flight flight;

  const WaitingPilotToJoin({super.key, required this.flight});

  @override
  State<WaitingPilotToJoin> createState() => _WaitingPilotToJoin();
}

class _WaitingPilotToJoin extends State<WaitingPilotToJoin> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DepartureToArrivalWidget(flight: widget.flight),
        const SizedBox(height: 24),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Waiting for the pilot to accept"),
                SizedBox(height: 10),
                LinearProgressIndicator(color: Color(0xFF131141),),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
