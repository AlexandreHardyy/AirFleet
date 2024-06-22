import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/models/flight.dart';

class FlightRequestDetail extends StatelessWidget {
  final Flight flight;
  final _formKey = GlobalKey<FormBuilderState>();

  FlightRequestDetail({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flight Details'),
        ),
        body:
            BlocBuilder<SocketIoBloc, SocketIoState>(builder: (context, state) {
          return BlocBuilder<CurrentFlightBloc, CurrentFlightState>(
              builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${flight.departure.name} -> ${flight.arrival.name}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Departure:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    flight.departure.address,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Arrival:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    flight.arrival.address,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  FormBuilder(
                    key: _formKey,
                    child: Column(
                      children: [
                        FormBuilderTextField(
                          name: 'price',
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Your price for the flight request',
                            border: OutlineInputBorder(),
                          ),
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
                              context.read<SocketIoBloc>().add(
                                  SocketIoMakePriceProposal(
                                      flightId: flight.id,
                                      price:
                                          double.parse(formValues['price'])));

                              context
                                  .read<SocketIoBloc>()
                                  .add(SocketIoListenEvent(
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
