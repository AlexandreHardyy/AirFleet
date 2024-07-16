import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/mobile/flight_chat.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/departure_to_arrival.dart';

class WaitingForTakeoff extends StatelessWidget {
  final Flight flight;
  const WaitingForTakeoff({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DepartureToArrivalWidget(flight: flight),
            const SizedBox(
              height: 24,
            ),
            Text(translate(
                "home.flight_management.pilot_current_flight_management.waiting_for_takeoff.subtitle")),
            const SizedBox(
              height: 12,
            ),
            SizedBox(
              height: 50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () {
                      context
                          .read<SocketIoBloc>()
                          .startFlightTakeoff(flight.id);
                    },
                    child: const Text('Start'),
                  )),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        FlightChat.navigateTo(context, flightId: flight.id);
                      },
                      child: const Icon(Icons.chat),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
              style: dangerButtonStyle,
              onPressed: () {
                final socketBloc = context.read<SocketIoBloc>();
                socketBloc.tickerSubscription?.cancel();
                socketBloc.state.socket!.emit("cancelFlight", "${flight.id}");
              },
              child: Text(translate(
                  "home.flight_management.pilot_current_flight_management.waiting_for_takeoff.cancel")),
            ),
          ],
        ));
  }
}
