import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../services/dio.dart';
import '../../../models/flight.dart';
import '../../map/mapbox_endpoint/retrieve.dart';
import '../../map/mapbox_endpoint/suggest.dart';

const uuid = Uuid();

class CreateFlightWidget extends StatefulWidget {
  final FocusNode departureTextFieldFocusNode;
  final FocusNode arrivalTextFieldFocusNode;

  const CreateFlightWidget({super.key, required this.departureTextFieldFocusNode, required this.arrivalTextFieldFocusNode});

  @override
  State<CreateFlightWidget> createState() => _CreateFlightWidgetState();
}

class _CreateFlightWidgetState extends State<CreateFlightWidget> {
  late Position userLocation;
  String mapboxSessionToken = uuid.v4();

  List<Suggestion>? searchResults;
  Airport? departure;
  Airport? arrival;

  @override
  void initState() {
    super.initState();

    _determinePosition().then((value) => setState(() {
      userLocation = value;
    }));
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
          'session_token': mapboxSessionToken
        }
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
          'session_token': mapboxSessionToken
        }
      );

      return RetrieveResponse.fromJson(response.data).features[0];
    } on DioException catch (e) {
      throw Exception('Something went wrong: ${e.response}');
    }
  }
  
  Future<void> _createFlight(Flight flight) async {
    try {
      await dioApi.post("flights", data: flight.toJson());
    } on DioException catch (e) {
      throw Exception('Something went wrong during flight creation: ${e.response}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          focusNode: widget.departureTextFieldFocusNode,
          onChanged: (value) async {
            final suggestions = await _retrieveNearbyAirport(value);
            setState(() {
              searchResults = suggestions;
            });
          },
        ),
        TextField(
          focusNode: widget.arrivalTextFieldFocusNode,
          onChanged: (value) async {
            final suggestions = await _retrieveNearbyAirport(value);
            setState(() {
              searchResults = suggestions;
            });
          },
        ),
        Expanded(
          child: searchResults != null ? ListView.builder(
            itemCount: searchResults?.length,
            itemBuilder: (BuildContext context, int index) {
              final airportSuggestion = searchResults![index];

              return GestureDetector(
                onTap: () async {
                  final feature = await _retrieveAirportData(airportSuggestion.mapboxId);
                  final airport = Airport(
                      name: feature.properties.name,
                      address: feature.properties.fullAddress ?? "",
                      latitude: feature.geometry.coordinates[0],
                      longitude: feature.geometry.coordinates[1]
                  );

                  setState(() {
                    if (widget.departureTextFieldFocusNode.hasFocus) {
                      departure = airport;
                    } else if (widget.arrivalTextFieldFocusNode.hasFocus) {
                      arrival = airport;
                    }
                  });
                },
                child: Card(
                  child: ListTile(
                    title: Text(airportSuggestion.name),
                    subtitle: Text(airportSuggestion.fullAddress ?? ""),
                  ),
                ),
              );
            },
          ) : const Text("Type something"),
        ),
        if (departure != null && arrival != null)
          Center(
          child: ElevatedButton(
            onPressed: () {
              final Flight flight = Flight(departure: departure!, arrival: arrival!);
              _createFlight(flight);
            },
            child: const Text("Create Flight"),
          ),
        )
      ],
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}

class Flight {
  Airport departure;
  Airport arrival;

  Flight({
    required this.departure,
    required this.arrival,
  });

  Map<String, dynamic> toJson() {
    return {
      'departure': departure.toJson(),
      'arrival': arrival.toJson(),
    };
  }
}


