import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/services/flight.dart';

class SearchFlightWaitingTakeOff extends StatefulWidget {
  const SearchFlightWaitingTakeOff({super.key});

  @override
  _SearchFlightWaitingTakeOffState createState() =>
      _SearchFlightWaitingTakeOffState();
}

class _SearchFlightWaitingTakeOffState
    extends State<SearchFlightWaitingTakeOff> {
  late Future<List<Flight>?> _flightsFuture;

  @override
  void initState() {
    super.initState();
    _flightsFuture =
        FlightService.getFlights(FlightFilters(status: "waiting_takeoff"));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Flight>?>(
      future: _flightsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Flight flight = snapshot.data![index];
              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: flight.departure.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const TextSpan(text: ' → '),
                            TextSpan(
                                text: flight.arrival.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Text("Price: ${flight.price}"),
                onTap: () async {
                  await _showJoinFlightDialog(context, flight);
                },
              );
            },
          );
        } else {
          return const Text("No recent flights found");
        }
      },
    );
  }
}

Future<void> _showJoinFlightDialog(BuildContext context, Flight flight) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Join Flight'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                  'Do you want to ask for joining the flight from ${flight.departure.name} to ${flight.arrival.name}?'),
              const SizedBox(height: 10),
              Text('Price: ${flight.price} euros', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              if (context.mounted) {
                context
                    .read<CurrentFlightBloc>()
                    .add(CurrentFlightLoaded(flight: flight));
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
