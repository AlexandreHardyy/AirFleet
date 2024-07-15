import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/mobile/home/flights_management/user_flight_management/create_flight.dart';
import 'package:frontend/mobile/map/mapbox_endpoint/suggest.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:frontend/services/dio.dart';
import 'package:frontend/services/vehicle.dart';
import 'package:frontend/widgets/input.dart';

class CreateProposalView extends StatefulWidget {
  const CreateProposalView({super.key});

  @override
  _CreateProposalViewState createState() => _CreateProposalViewState();
}

class _CreateProposalViewState extends State<CreateProposalView> {
  final _formKey = GlobalKey<FormState>();
  String mapboxSessionToken = uuid.v4();
  List<DropdownMenuItem<Vehicle>> _vehicleDropdownItems = [];
  int availableSeats = 0;
  String departureTime = '';
  String description = '';
  double price = 0;
  int vehicleId = 0;
  Airport? selectedDepartureAirport;
  Airport? selectedArrivalAirport;

  List<Suggestion> _suggestions = [];

  FocusNode departureTextFieldFocusNode = FocusNode();
  FocusNode arrivalTextFieldFocusNode = FocusNode();

  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() async {
    try {
      List<Vehicle> vehicles = await VehicleService.getVehiclesForMe();
      setState(() {
        _vehicleDropdownItems = vehicles
            .map((vehicle) =>
            DropdownMenuItem<Vehicle>(
              value: vehicle,
              child: Text(vehicle.modelName),
            ))
            .toList();
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<List<Suggestion>> _retrieveAirport(String searchValue) async {
    Response response;
    try {
      response = await dioMapbox.get(
        "search/searchbox/v1/suggest",
        queryParameters: {
          'q': searchValue,
          'language': 'en',
          'poi_category': 'airport',
          'types': "poi",
          'access_token': const String.fromEnvironment("PUBLIC_ACCESS_TOKEN"),
          'session_token': mapboxSessionToken,
        },
      );
      return SuggestionResponse
          .fromJson(response.data)
          .suggestions;
    } on DioException catch (e) {
      throw Exception('Something went wrong: ${e.response}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
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
                controller: _departureController,
                onChanged: (value) async {
                  final suggestions = await _retrieveAirport(value);
                  setState(() {
                    _suggestions = suggestions;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search Airport',
                  suffixIcon: _departureController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _departureController.clear();
                      setState(() {
                        _suggestions = [];
                      });
                    },
                  )
                      : null,
                ),
              ),
              if (_suggestions.isNotEmpty)
                SizedBox(
                  height: 200, // Fixed height for the suggestions list
                  child: ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (BuildContext context, int index) {
                      final airportSuggestion = _suggestions[index];
                      return GestureDetector(
                        onTap: () {
                          // Implement onTap functionality
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 1.0, color: Colors.grey),
                            ),
                          ),
                          child: ListTile(
                            title: Text(airportSuggestion.name),
                            subtitle: Text(airportSuggestion.fullAddress ?? ""),
                          ),
                        ),
                      );
                    },
                  ),
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
                      "departureTime": departureTime,
                      "description": description,
                      "price": price,
                      "vehicleId": vehicleId,
                    });
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
