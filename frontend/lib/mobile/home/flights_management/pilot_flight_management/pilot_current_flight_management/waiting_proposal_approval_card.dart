import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/widgets/button.dart';
import 'package:frontend/widgets/departure_to_arrival.dart';

class WaitingProposalApprovalCard extends StatefulWidget {
  final Flight flight;

  const WaitingProposalApprovalCard({super.key, required this.flight});

  @override
  State<WaitingProposalApprovalCard> createState() =>
      _WaitingProposalApprovalCardState();
}

class _WaitingProposalApprovalCardState
    extends State<WaitingProposalApprovalCard> {
  late SocketIoBloc _socketIoBloc;

  @override
  void initState() {
    super.initState();
    _socketIoBloc = context.read<SocketIoBloc>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DepartureToArrivalWidget(flight: widget.flight),
            const SizedBox(
              height: 24,
            ),
            Text(translate(
                "home.flight_management.pilot_current_flight_management.waiting_proposal_approval.subtitle")),
            const SizedBox(
              height: 24,
            ),
            const LinearProgressIndicator(),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
              style: dangerButtonStyle,
              onPressed: () {
                _socketIoBloc.state.socket!.emit(
                  "cancelFlight",
                  '${widget.flight.id}',
                );
                context.read<CurrentFlightBloc>().add(CurrentFlightUpdated());
              },
              child: Text(translate(
                  "home.flight_management.pilot_current_flight_management.waiting_proposal_approval.cancel")),
            ),
          ],
        ));
  }
}
