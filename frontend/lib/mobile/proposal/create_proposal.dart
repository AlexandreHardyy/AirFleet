import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/mobile/home/flights_management/user_flight_management/create_flight.dart';
import 'package:frontend/mobile/map/mapbox_endpoint/retrieve.dart';
import 'package:frontend/mobile/map/mapbox_endpoint/suggest.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:frontend/services/dio.dart';
import 'package:frontend/services/proposal.dart';
import 'package:frontend/services/vehicle.dart';
import 'package:frontend/widgets/input.dart';
import 'package:intl/intl.dart';

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
  DateTime departureTime = DateTime.now();
  String description = '';
  double price = 0;
  int vehicleId = 0;
  Airport? selectedDepartureAirport;
  Airport? selectedArrivalAirport;

  List<Suggestion>? _suggestions = [];

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
            .map((vehicle) => DropdownMenuItem<Vehicle>(
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
      return SuggestionResponse.fromJson(response.data).suggestions;
    } on DioException catch (e) {
      throw Exception('Something went wrong: ${e.response}');
    }
  }

  Future<Feature> _retrieveAirportData(String mapboxId) async {
    Response response;

    try {
      response = await dioMapbox.get(
        "search/searchbox/v1/retrieve/$mapboxId",
        queryParameters: {
          'access_token': const String.fromEnvironment("PUBLIC_ACCESS_TOKEN"),
          'session_token': mapboxSessionToken,
        },
      );

      return RetrieveResponse.fromJson(response.data).features[0];
    } on DioException catch (e) {
      throw Exception('Something went wrong: ${e.response}');
    }
  }

  Future<void> _onSelectAirport(
    Suggestion suggestion,
  ) async {
    final feature = await _retrieveAirportData(suggestion.mapboxId);
    final airport = Airport(
      name: feature.properties.name,
      address: feature.properties.fullAddress ?? "",
      longitude: feature.geometry.coordinates[0],
      latitude: feature.geometry.coordinates[1],
    );

    setState(() {
      _suggestions = null;
      if (departureTextFieldFocusNode.hasFocus) {
        selectedDepartureAirport = airport;
        _departureController.text = selectedDepartureAirport!.name;
      } else if (arrivalTextFieldFocusNode.hasFocus) {
        selectedArrivalAirport = airport;
        _arrivalController.text = selectedArrivalAirport!.name;
      }
    });
  }

  InputDecoration _buildInputDecoration({required String labelText, IconData? prefixIcon, String? suffixText, IconButton? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixText: suffixText,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
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
              const SizedBox(height: 10),
              TextFormField(
                decoration: _buildInputDecoration(labelText: translate('proposal.seats_available')),
                onSaved: (value) => availableSeats = int.parse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter available seats';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _departureController,
                focusNode: departureTextFieldFocusNode,
                onChanged: (value) async {
                  final suggestions = await _retrieveAirport(value);
                  setState(() {
                    _suggestions = suggestions;
                  });
                },
                decoration: _buildInputDecoration(labelText: translate('proposal.form.departure'),
                  suffixIcon: _departureController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _departureController.clear();
                    setState(() {
                      _suggestions = null;
                    });
                  },
                )
                    : null,),
              ),
              if (_suggestions != null && departureTextFieldFocusNode.hasFocus)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: _suggestions?.length,
                    itemBuilder: (BuildContext context, int index) {
                      final airportSuggestion = _suggestions![index];
                      return GestureDetector(
                        onTap: () => _onSelectAirport(airportSuggestion),
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
              const SizedBox(height: 18),
              TextFormField(
                controller: _arrivalController,
                focusNode: arrivalTextFieldFocusNode,
                onChanged: (value) async {
                  final suggestions = await _retrieveAirport(value);
                  setState(() {
                    _suggestions = suggestions;
                  });
                },
                decoration: _buildInputDecoration(labelText: translate('proposal.form.arrival'),
                  suffixIcon: _arrivalController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _arrivalController.clear();
                      setState(() {
                        _suggestions = null;
                      });
                    },
                  )
                      : null,),
              ),
              if (_suggestions != null && arrivalTextFieldFocusNode.hasFocus)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: _suggestions?.length,
                    itemBuilder: (BuildContext context, int index) {
                      final airportSuggestion = _suggestions![index];
                      return GestureDetector(
                        onTap: () => _onSelectAirport(airportSuggestion),
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
              const SizedBox(height: 18),
              FormBuilderDateTimePicker(
                name: 'departureTime',
                decoration: _buildInputDecoration(labelText: translate('proposal.form.departure_time')),
                inputType: InputType.both,
                onSaved: (value) => departureTime = value!,
                validator: (value) {
                  if (value == null) {
                    return 'Please enter departure time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                decoration: _buildInputDecoration(labelText: translate('proposal.form.description')),
                onSaved: (value) => description = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                decoration: _buildInputDecoration(labelText: translate('proposal.form.price')),
                keyboardType: TextInputType.number,
                onSaved: (value) => price = double.parse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              FormBuilderDropdown(
                name: "vehicleId",
                decoration: getInputDecoration(hintText: translate('proposal.form.select_vehicle')),
                items: _vehicleDropdownItems,
                onChanged: (dynamic value) {
                  setState(() {
                    vehicleId = (value as Vehicle).id!;
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          try {
                            await ProposalService.createProposal({
                              "availableSeats": availableSeats,
                              "departureTime": DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(departureTime.toUtc()),
                              "description": description,
                              "price": price,
                              "vehicleId": vehicleId,
                              "createFlight": {
                                "departure": {
                                  "name": selectedDepartureAirport!.name,
                                  "address": selectedDepartureAirport!.address,
                                  "longitude": selectedDepartureAirport!.longitude,
                                  "latitude": selectedDepartureAirport!.latitude,
                                },
                                "arrival": {
                                  "name": selectedArrivalAirport!.name,
                                  "address": selectedArrivalAirport!.address,
                                  "longitude": selectedArrivalAirport!.longitude,
                                  "latitude": selectedArrivalAirport!.latitude,
                                },
                              },
                            });
                            Navigator.pop(context, true);
                          } on DioException catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.response?.data['message']}'),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(translate('common.input.submit')),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
