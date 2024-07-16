import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/mobile/flight_animated_paths.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/models/rating.dart';
import 'package:frontend/services/flight.dart';
import 'package:frontend/services/rating.dart';
import 'package:frontend/storage/user.dart';

class FlightDetails extends StatefulWidget {
  static const routeName = '/flight-details';

  static Future<void> navigateTo(BuildContext context,
      {required int flightId}) {
    return Navigator.of(context).pushNamed(routeName, arguments: flightId);
  }

  final int flightId;

  const FlightDetails({super.key, required this.flightId});

  @override
  State<FlightDetails> createState() => _FlightDetailsState();
}

class _FlightDetailsState extends State<FlightDetails> {
  late Future<Flight> _flight;
  late Future<List<Rating>> _ratings;

  @override
  void initState() {
    super.initState();
    _flight = FlightService.getFlight(widget.flightId);

    if (UserStore.user?.role == "ROLE_PILOT") {
      _ratings = RatingService.getAllRatings(
          {"status": "reviewed", "flight_id": widget.flightId.toString()});
    } else {
      _ratings = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate("home.flight_management.flight_details.title")),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<Flight>(
              future: _flight,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Column(
                    children: [
                      FlightInfoCard(flight: snapshot.data!),
                      // FlightAnimatedPath(flight: snapshot.data!),
                    ],
                  );
                }
              },
            ),
            // const SizedBox(height: 16),
            // const FlightAnimatedPath(flight: snapshot.data!),
            if (UserStore.user?.role == "ROLE_PILOT")
              FutureBuilder<List<Rating>>(
                future: _ratings,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text(translate(
                            "home.flight_management.flight_details.no_rating")));
                  } else {
                    return Column(
                      children: snapshot.data!.map((rating) {
                        return RatingCard(rating: rating);
                      }).toList(),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

class FlightInfoCard extends StatelessWidget {
  final Flight flight;

  const FlightInfoCard({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(flight.departure.name),
            subtitle: Text(
                translate("home.flight_management.flight_details.departure")),
          ),
          ListTile(
            title: Text(flight.arrival.name),
            subtitle: Text(
                translate("home.flight_management.flight_details.arrival")),
          ),
        ],
      ),
    );
  }
}

class RatingCard extends StatelessWidget {
  final Rating rating;

  const RatingCard({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(rating.comment ?? 'No comment'),
            subtitle: Text('Rating: ${rating.rating}'),
          ),
        ],
      ),
    );
  }
}
