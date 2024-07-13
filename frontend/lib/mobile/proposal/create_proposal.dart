import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:frontend/services/vehicle.dart';
import 'package:frontend/widgets/input.dart';

class CreateProposalView extends StatefulWidget {
  const CreateProposalView({super.key});

  @override
  _CreateProposalViewState createState() => _CreateProposalViewState();
}

class _CreateProposalViewState extends State<CreateProposalView> {
  final _formKey = GlobalKey<FormState>();
  List<DropdownMenuItem<Vehicle>> _vehicleDropdownItems = [];

  int availableSeats = 0;
  String arrivalAddress = '';
  double arrivalLatitude = 0;
  double arrivalLongitude = 0;
  String arrivalName = '';
  String departureAddress = '';
  double departureLatitude = 0;
  double departureLongitude = 0;
  String departureName = '';
  String departureTime = '';
  String description = '';
  double price = 0;
  int vehicleId = 0;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() async {
    try {
      List<Vehicle> vehicles = await VehicleService.getVehiclesForMe();
      setState(() {
        _vehicleDropdownItems = vehicles.map((vehicle) => DropdownMenuItem<Vehicle>(
          value: vehicle,
          child: Text(vehicle.modelName),
        )).toList();
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Available Seats'),
                keyboardType: TextInputType.number,
                onSaved: (value) => availableSeats = int.parse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter available seats';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Arrival Address'),
                onSaved: (value) => arrivalAddress = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter arrival address';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Arrival Latitude'),
                keyboardType: TextInputType.number,
                onSaved: (value) => arrivalLatitude = double.parse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter arrival latitude';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Arrival Longitude'),
                keyboardType: TextInputType.number,
                onSaved: (value) => arrivalLongitude = double.parse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter arrival longitude';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Arrival Name'),
                onSaved: (value) => arrivalName = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter arrival name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Departure Address'),
                onSaved: (value) => departureAddress = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter departure address';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Departure Latitude'),
                keyboardType: TextInputType.number,
                onSaved: (value) => departureLatitude = double.parse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter departure latitude';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Departure Longitude'),
                keyboardType: TextInputType.number,
                onSaved: (value) => departureLongitude = double.parse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter departure longitude';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Departure Name'),
                onSaved: (value) => departureName = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter departure name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Departure Time'),
                onSaved: (value) => departureTime = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter departure time';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => description = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => price = double.parse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  return null;
                },
              ),
              FormBuilderDropdown(
                name: "vehicleId",
                decoration: getInputDecoration(hintText: 'Select vehicle'),
                items: _vehicleDropdownItems,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Envoyer les données à l'API via le service Dart
                    print({
                      "availableSeats": availableSeats,
                      "createFlight": {
                        "arrival": {
                          "address": arrivalAddress,
                          "latitude": arrivalLatitude,
                          "longitude": arrivalLongitude,
                          "name": arrivalName,
                        },
                        "departure": {
                          "address": departureAddress,
                          "latitude": departureLatitude,
                          "longitude": departureLongitude,
                          "name": departureName,
                        }
                      },
                      "departureTime": departureTime,
                      "description": description,
                      "price": price,
                      "vehicleId": vehicleId,
                    });
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      );
  }
}