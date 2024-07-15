import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/widgets/input.dart';

class FlightRequestDetail extends StatelessWidget {
  static const routeName = '/flight-request-detail';

  static Future<void> navigateTo(BuildContext context, {required Flight flight}) async {
    await Navigator.of(context).pushNamed(routeName, arguments: flight);
  }

  final Flight flight;
  final _formKey = GlobalKey<FormBuilderState>();

  FlightRequestDetail({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flight details'),
        ),
        body:
            BlocBuilder<SocketIoBloc, SocketIoState>(builder: (context, state) {
          return BlocBuilder<CurrentFlightBloc, CurrentFlightState>(
              builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        flight.departure.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.arrow_forward, // Icône de flèche
                        size: 24,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        flight.arrival.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Departure:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    flight.departure.address,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Arrival:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    flight.arrival.address,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  FormBuilder(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FormBuilderTextField(
                          name: 'price',
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: getInputDecoration(
                              hintText: 'Your price for the flight request'),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                          ]),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            final state = _formKey.currentState;
                            if (state == null) {
                              return;
                            }

                            if (state.saveAndValidate()) {
                              final formValues = state.value;
                              context.read<SocketIoBloc>().state.socket!.emit(
                                  "makeFlightProposal",
                                  const JsonEncoder().convert({
                                    'flightId': flight.id,
                                    'price': formValues['price']
                                  }));

                              context
                                  .read<SocketIoBloc>()
                                  .add(SocketIoListenEvent(
                                    eventId: "flightProposalChoice",
                                    event: "flightProposalChoice",
                                    callback: (_) {
                                      context
                                          .read<CurrentFlightBloc>()
                                          .add(CurrentFlightUpdated());
                                    },
                                  ));
                              context
                                  .read<CurrentFlightBloc>()
                                  .add(CurrentFlightUpdated());
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Send your proposal'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        }));
  }
}
