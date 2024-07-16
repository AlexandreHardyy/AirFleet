import 'package:flutter/material.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/services/flight.dart';
import 'package:frontend/web/flights/flight_details.dart';

class FlightsWebScreen extends StatefulWidget {
  static const routeName = '/flight';

  static Future<void> navigateTo(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  const FlightsWebScreen({super.key});

  @override
  _FlightsWebScreenState createState() => _FlightsWebScreenState();
}

class _FlightsWebScreenState extends State<FlightsWebScreen> {
  List<Flight> _flights = [];

  @override
  void initState() {
    super.initState();
    _fetchFlights();
  }

  Future<void> _fetchFlights() async {
    try {
      _flights = await FlightService.getAllFlights();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flights'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minWidth: constraints.maxWidth),
                        child: DataTable(
                          columnSpacing: 0,
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Departure airport',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Arrival airport',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Price',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Pilot',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Vehicle',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          rows: _flights.map((flight) {
                            return DataRow(
                              cells: [
                                DataCell(Text(flight.departure.name)),
                                DataCell(Text(flight.arrival.name)),
                                DataCell(Text('${flight.price.toString()} €')),
                                DataCell(Text(flight.status)),
                                DataCell(Text('${flight.pilot?.firstName} ${flight.pilot?.lastName}')),
                                DataCell(Text(flight.vehicle?.modelName ?? '')),
                              ],
                              onSelectChanged : (isSelected) {
                                if (isSelected!) {
                                  FlightDetailsScreen.navigateTo(context, flight: flight);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
