import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/mobile/widget/departure_to_arrival.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/routes.dart';
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

    // TODO: I think this is not used
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
        const SecondaryTitle(content: 'Waiting for takeoff'),
        const SizedBox(height: 10),
        DepartureToArrivalWidget(flight: widget.flight),
        const SizedBox(height: 24),
        const Text('Please join aircraft the plane before takeoff'),
        const SizedBox(height: 8),
        const LinearProgressIndicator(color: Color(0xFF131141),),
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
                child: const Text('Cancel flight'),
              ),
            ),
            const SizedBox(width: 10),
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

String _formatFlightTime(String estimatedFlightTimeStr) {
  double hours = double.parse(estimatedFlightTimeStr);
  int hh = hours.floor();
  int mm = ((hours - hh) * 60).round();
  return '${hh.toString().padLeft(2, '0')}h${mm.toString().padLeft(2, '0')}min';
}
