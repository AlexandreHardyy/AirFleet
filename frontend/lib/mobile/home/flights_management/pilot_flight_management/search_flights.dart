import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:frontend/mobile/blocs/pilot_status/pilot_status_bloc.dart';
import 'package:frontend/mobile/home/flights_management/pilot_flight_management/pilot_flight_requests.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:frontend/routes.dart';
import 'package:frontend/widgets/input.dart';

class SearchFlights extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  SearchFlights({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PilotStatusBloc, PilotStatusState>(
        builder: (context, state) {
      if (state.status == CurrentPilotStatus.loading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (state.status == CurrentPilotStatus.loaded &&
          (state.vehicles == null || state.vehicles!.isEmpty)) {
        return Column(
          children: [
            const Text('no vehicles availables'),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(Routes.vehiclesManagement(context));
                },
                child: const Text('Add new vehicle'))
          ],
        );
      }

      if (state.status == CurrentPilotStatus.loaded &&
          (state.selectedVehicle != null &&
              state.selectedVehicle!.isSelected == true)) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<PilotStatusBloc>()
                          .add(PilotStatusNotReady());
                    },
                    child: const Text('Cancel search'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Expanded(child: PilotFlightRequests())
                ]));
      }

      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 24),
          child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormBuilderDropdown(
                    name: "vehicle_selected",
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    decoration: getInputDecoration(hintText: 'Select vehicle'),
                    items: state.vehicles!
                        .map((vehicle) => DropdownMenuItem(
                              value: vehicle,
                              child: Text(vehicle.modelName),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final state = _formKey.currentState;
                      if (state == null) {
                        return;
                      }
                      state.saveAndValidate();

                      final vehicle =
                          state.instantValue['vehicle_selected'] as Vehicle;
                      vehicle.isSelected = true;

                      context
                          .read<PilotStatusBloc>()
                          .add(PilotStatusReady(vehicle: vehicle));
                    },
                    child: const Text('I am ready'),
                  ),
                ],
              )));
    });
  }
}
