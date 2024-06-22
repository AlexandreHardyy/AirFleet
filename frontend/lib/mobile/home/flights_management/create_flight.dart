import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/map/mapbox_endpoint/retrieve.dart';
import 'package:frontend/mobile/map/mapbox_endpoint/suggest.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/services/dio.dart';
import 'package:frontend/services/flight.dart';
import 'package:frontend/services/position.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class CreateFlightWidget extends StatefulWidget {
  final FocusNode departureTextFieldFocusNode;
  final FocusNode arrivalTextFieldFocusNode;

  const CreateFlightWidget({
    super.key,
    required this.departureTextFieldFocusNode,
    required this.arrivalTextFieldFocusNode,
  });

  @override
  State<CreateFlightWidget> createState() => _CreateFlightWidgetState();
}

class _CreateFlightWidgetState extends State<CreateFlightWidget> {
  late Position userLocation;

  String mapboxSessionToken = uuid.v4();
  final TextEditingController departureController = TextEditingController();
  final TextEditingController arrivalController = TextEditingController();

  List<Suggestion>? searchResults;
  Airport? departure;
  Airport? arrival;

  @override
  void initState() {
    super.initState();

    determinePosition().then((value) => setState(() {
          userLocation = value;
        }));
  }

  void _checkFlightValidity() {
    if (departure != null && arrival != null) {
      widget.departureTextFieldFocusNode.unfocus();
      widget.arrivalTextFieldFocusNode.unfocus();

      context.read<CurrentFlightBloc>().add(
            CurrentFlightSelected(
              flightRequest: CreateFlightRequest(
                departure: departure!,
                arrival: arrival!,
              ),
            ),
          );
    }
  }

  Future<List<Suggestion>> _retrieveNearbyAirport(String searchValue) async {
    Response response;

    try {
      response = await dioMapbox.get(
        "search/searchbox/v1/suggest",
        queryParameters: {
          'q': searchValue,
          'language': 'en',
          'poi_category': 'airport',
          'proximity': "${userLocation.longitude},${userLocation.latitude}",
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

  Future<void> _onSelectAirport(Suggestion suggestion) async {
    final feature = await _retrieveAirportData(suggestion.mapboxId);
    final airport = Airport(
      name: feature.properties.name,
      address: feature.properties.fullAddress ?? "",
      longitude: feature.geometry.coordinates[0],
      latitude: feature.geometry.coordinates[1],
    );

    setState(() {
      searchResults = null;
      if (widget.departureTextFieldFocusNode.hasFocus) {
        departure = airport;
        departureController.text = departure!.name;
      } else if (widget.arrivalTextFieldFocusNode.hasFocus) {
        arrival = airport;
        arrivalController.text = arrival!.name;
      }
    });

    _checkFlightValidity();
  }

  @override
  Widget build(BuildContext context) {
    return departure == null || arrival == null
        ? Column(
            children: [
              TextField(
                focusNode: widget.departureTextFieldFocusNode,
                controller: departureController,
                onChanged: (value) async {
                  final suggestions = await _retrieveNearbyAirport(value);
                  setState(() {
                    searchResults = suggestions;
                  });
                },
              ),
              TextField(
                focusNode: widget.arrivalTextFieldFocusNode,
                controller: arrivalController,
                onChanged: (value) async {
                  final suggestions = await _retrieveNearbyAirport(value);
                  setState(() {
                    searchResults = suggestions;
                  });
                },
              ),
              Expanded(
                child: searchResults != null
                    ? ListView.builder(
                        itemCount: searchResults?.length,
                        itemBuilder: (BuildContext context, int index) {
                          final airportSuggestion = searchResults![index];

                          return GestureDetector(
                            onTap: () => _onSelectAirport(airportSuggestion),
                            child: Card(
                              child: ListTile(
                                title: Text(airportSuggestion.name),
                                subtitle:
                                    Text(airportSuggestion.fullAddress ?? ""),
                              ),
                            ),
                          );
                        },
                      )
                    : const Text("Type something"),
              ),
            ],
          )
        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: () async {
                final CreateFlightRequest flightRequest = CreateFlightRequest(
                  departure: departure!,
                  arrival: arrival!,
                );
                final flight = await FlightService.createFlight(flightRequest);

                if (context.mounted) {
                  context
                      .read<CurrentFlightBloc>()
                      .add(CurrentFlightLoaded(flight: flight));
                }
              },
              child: const Text("Create Flight"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  departure = null;
                  arrival = null;
                });

                context.read<CurrentFlightBloc>().add(CurrentFlightCleared());
                departureController.clear();
                arrivalController.clear();
              },
              child: const Text("Cancel Selection"),
            ),
          ]);
  }
}
