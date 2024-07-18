import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/mobile/flight_chat.dart';
import 'package:frontend/widgets/departure_to_arrival.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/title.dart';

class WaitingTakeoff extends StatefulWidget {
  final Flight flight;

  const WaitingTakeoff({super.key, required this.flight});

  @override
  State<WaitingTakeoff> createState() => _WaitingTakeoffState();
}

class _WaitingTakeoffState extends State<WaitingTakeoff> {
  String? estimatedFlightTime;
  late SocketIoBloc _socketIoBloc;

  @override
  void initState() {
    super.initState();
    _socketIoBloc = context.read<SocketIoBloc>();

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SecondaryTitle(
            content: translate(
                'home.flight_management.user_current_flight_management.waiting_takeoff.title')),
        const SizedBox(height: 10),
        DepartureToArrivalWidget(flight: widget.flight),
        const SizedBox(height: 24),
        Text(translate(
            'home.flight_management.user_current_flight_management.waiting_takeoff.subtitle')),
        const SizedBox(height: 8),
        const LinearProgressIndicator(
          color: Color(0xFF131141),
        ),
        const SizedBox(
          height: 24,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                style: dangerButtonStyle,
                onPressed: () {
                  _socketIoBloc.state.socket!.emit(
                    "cancelFlight",
                    '${widget.flight.id}',
                  );
                  context.read<CurrentFlightBloc>().add(CurrentFlightUpdated());
                },
                child: Text(translate('common.input.cancel_flight')),
              ),
            ),
            const SizedBox(width: 10),
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

String _formatFlightTime(String estimatedFlightTimeStr) {
  double hours = double.parse(estimatedFlightTimeStr);
  int hh = hours.floor();
  int mm = ((hours - hh) * 60).round();
  return '${hh.toString().padLeft(2, '0')}h${mm.toString().padLeft(2, '0')}min';
}
