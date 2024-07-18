import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/mobile/home/flights_management/user_flight_management/create_flight.dart';
import 'package:frontend/mobile/map/mapbox_endpoint/retrieve.dart';
import 'package:frontend/mobile/map/mapbox_endpoint/suggest.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/services/dio.dart';

class FilterView extends StatefulWidget {
  final Function(double?) onMaxPriceChanged;
  final Function(int?) onMinSeatsChanged;
  final Function(Airport?) onDepartureLocationChanged;
  final Function(Airport?) onArrivalLocationChanged;
  final Function refreshProposals;
  final double? maxPrice;
  final int? minSeatsAvailable;
  final Airport? departureLocation;
  final Airport? arrivalLocation;
  final Function resetFilters;

  const FilterView({
    super.key,
    required this.onMaxPriceChanged,
    required this.onMinSeatsChanged,
    required this.onDepartureLocationChanged,
    required this.onArrivalLocationChanged,
    required this.refreshProposals,
    required this.resetFilters,
    this.maxPrice,
    this.minSeatsAvailable,
    this.departureLocation,
    this.arrivalLocation,
  });

  @override
  _FilterViewState createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  late TextEditingController maxPriceController;
  late TextEditingController minSeatsAvailableController;

  String mapboxSessionToken = uuid.v4();
  List<Suggestion> _suggestions = [];

  FocusNode departureTextFieldFocusNode = FocusNode();
  FocusNode arrivalTextFieldFocusNode = FocusNode();

  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    maxPriceController = TextEditingController(text: widget.maxPrice.toString());
    minSeatsAvailableController = TextEditingController(text: widget.minSeatsAvailable.toString());
    print(widget.departureLocation);
    _departureController.text = widget.departureLocation?.name ?? "";
  }

  @override
  void dispose() {
    maxPriceController.dispose();
    minSeatsAvailableController.dispose();
    super.dispose();
  }

  final String mapboxAccessToken =
  const String.fromEnvironment("PUBLIC_ACCESS_TOKEN") != ""
      ? const String.fromEnvironment("PUBLIC_ACCESS_TOKEN")
      : dotenv.get("PUBLIC_ACCESS_TOKEN_MAPBOX");

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
          'access_token': mapboxAccessToken,
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
          'access_token': mapboxAccessToken,
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
      _suggestions = [];
      if (departureTextFieldFocusNode.hasFocus) {
        widget.onDepartureLocationChanged(airport);
      } else if (arrivalTextFieldFocusNode.hasFocus) {
        widget.onArrivalLocationChanged(airport);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Options'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                      _suggestions = [];
                    });
                  },
                )
                    : null,),
            ),
            if (_suggestions.isNotEmpty &&
                departureTextFieldFocusNode.hasFocus)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (BuildContext context, int index) {
                    final airportSuggestion = _suggestions[index];
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
                      _suggestions = [];
                    });
                  },
                )
                    : null,),
            ),
            if (_suggestions.isNotEmpty && arrivalTextFieldFocusNode.hasFocus)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (BuildContext context, int index) {
                    final airportSuggestion = _suggestions[index];
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
            TextField(
              controller: maxPriceController,
              decoration: InputDecoration(
                labelText: 'Maximum Price',
                hintText: 'Enter maximum price',
                prefixIcon: const Icon(Icons.monetization_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => widget.onMaxPriceChanged(double.tryParse(value)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: minSeatsAvailableController,
              decoration: InputDecoration(
                labelText: 'Minimum Seats Available',
                hintText: 'Enter minimum seats available',
                prefixIcon: const Icon(Icons.event_seat),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => widget.onMinSeatsChanged(int.tryParse(value)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.refreshProposals();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(translate('proposal.filter.apply')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.resetFilters();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(translate('proposal.filter.reset')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}