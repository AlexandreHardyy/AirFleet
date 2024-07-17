import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/mobile/profile/user_flights_list.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/models/rating.dart';
import 'package:frontend/services/flight.dart';
import 'package:frontend/services/rating.dart';
import 'package:frontend/storage/user.dart';
import 'package:intl/intl.dart';

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
      _ratings = RatingService.getRatingsByPilotID(UserStore.user!.id,
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
                  return SingleFlightList(
                      flight: snapshot.data!,
                      backgroundColor: Colors.grey[200]);
                }
              },
            ),
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
                      child: Text(
                        translate(
                            "home.flight_management.flight_details.no_rating"),
                      ),
                    );
                  } else {
                    final rating = snapshot.data!.first;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.black12,
                                    child: Text(
                                      rating.user.firstName[0].toUpperCase(),
                                      style: const TextStyle(
                                          color: Color(0xFF131141),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${rating.user.firstName} ${rating.user.lastName}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd MMM yyyy').format(
                                          DateTime.parse(rating.createdAt),
                                        ),
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    Icons.star,
                                    color: starIndex < rating.rating!
                                        ? Colors.amber
                                        : Colors.grey,
                                  );
                                }),
                              ),
                              const SizedBox(height: 10),
                              Text(rating.comment!),
                            ],
                          ),
                        ),
                      ),
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
              translate("home.flight_management.flight_details.departure"),
            ),
          ),
          ListTile(
            title: Text(flight.arrival.name),
            subtitle: Text(
              translate("home.flight_management.flight_details.arrival"),
            ),
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

class SingleFlightList extends StatelessWidget {
  final Flight flight;
  final Color? backgroundColor;

  const SingleFlightList(
      {super.key, required this.flight, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return ExpandableFlightList(
        flights: [flight], backgroundColor: backgroundColor);
  }
}
