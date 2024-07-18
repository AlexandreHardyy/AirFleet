import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/mobile/flight_details.dart';
import 'package:frontend/models/flight.dart';
import 'package:intl/intl.dart';

class ExpandableFlightList extends StatefulWidget {
  final List<Flight> flights;
  final Color? backgroundColor;

  const ExpandableFlightList({
    super.key,
    required this.flights,
    this.backgroundColor,
  });

  @override
  _ExpandableFlightListState createState() => _ExpandableFlightListState();
}

class _ExpandableFlightListState extends State<ExpandableFlightList> {
  bool _isExpanded = false;

  double calculateDistance(num lat1, num lon1, num lat2, num lon2) {
    const R = 6371; // Radius of the earth in km

    final lat1Rad = lat1 * (pi / 180);
    final lon1Rad = lon1 * (pi / 180);
    final lat2Rad = lat2 * (pi / 180);
    final lon2Rad = lon2 * (pi / 180);

    final dLat = lat2Rad - lat1Rad;
    final dLon = lon2Rad - lon1Rad;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distance = R * c;

    return distance;
  }

  @override
  Widget build(BuildContext context) {
    final flightsToShow =
        _isExpanded ? widget.flights : widget.flights.take(3).toList();
    final backgroundColor = widget.backgroundColor ?? Colors.white;

    return Container(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: flightsToShow.length,
            itemBuilder: (context, index) {
              final flight = flightsToShow[index];

              final totalDistance = calculateDistance(
                  flight.departure.latitude,
                  flight.departure.longitude,
                  flight.arrival.latitude,
                  flight.arrival.longitude);
              final cruiseSpeedKmH =
                  flight.vehicle!.cruiseSpeed * 1.852;
              final estimatedTime = totalDistance / cruiseSpeedKmH;
              final estimatedTimeInHours = estimatedTime.floor();
              final estimatedTimeInMinutes =
                  ((estimatedTime - estimatedTimeInHours) * 60).floor();

              return GestureDetector(
                onTap: () {
                  FlightDetails.navigateTo(context, flightId: flight.id);
                },
                child: Container(
                  margin: const EdgeInsets.all(2.0),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                            bottomLeft: Radius.circular(4.0),
                            bottomRight: Radius.circular(4.0),
                          ),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        constraints: const BoxConstraints(
                          minHeight: 50,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                flight.departure.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF131141),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Transform.rotate(
                                  angle: 90 * 3.1415926535897932 / 180,
                                  child: const Icon(
                                    Icons.airplanemode_active,
                                    color: Color(0xFFDCA200),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Text(
                                flight.arrival.name,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF131141),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        constraints: const BoxConstraints(
                          minHeight: 50,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Flight Time: ${estimatedTimeInHours}h ${estimatedTimeInMinutes}m',
                                style:
                                    const TextStyle(color: Color(0xFF131141)),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${flight.price?.toStringAsFixed(2)} €',
                                textAlign: TextAlign.right,
                                style:
                                    const TextStyle(color: Color(0xFF131141)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4.0),
                            topRight: Radius.circular(4.0),
                            bottomLeft: Radius.circular(16.0),
                            bottomRight: Radius.circular(16.0),
                          ),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        constraints: const BoxConstraints(
                          minHeight: 50,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: FlightStatusText(status: flight.status),
                            ),
                            Expanded(
                              child: Text(
                                DateFormat('dd MMM yyyy').format(
                                  DateTime.parse(flight.updatedAt!),
                                ),
                                textAlign: TextAlign.right,
                                style:
                                    const TextStyle(color: Color(0xFF131141)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (widget.flights.length > 3)
            TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFDCA200)),
                ),
                foregroundColor: const Color(0xFFDCA200),
              ),
              child: Text(_isExpanded
                  ? translate('home.profile.show.less')
                  : translate('home.profile.show.more')),
            ),
        ],
      ),
    );
  }
}

class FlightStatusText extends StatelessWidget {
  final String status;

  const FlightStatusText({super.key, required this.status});

  String get _statusText {
    switch (status) {
      case 'finished':
        return translate('home.profile.flightList.status.finished');
      case 'cancelled':
        return translate('home.profile.flightList.status.cancelled');
      case 'waiting_takeoff':
        return translate('home.profile.flightList.status.waitingTakeoff');
      case 'in_progress':
        return translate('home.profile.flightList.status.inProgress');
      default:
        return '';
    }
  }

  Object get _statusColor {
    switch (status) {
      case 'finished':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'waiting_takeoff':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _statusText,
      style: TextStyle(
        color: _statusColor as Color,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
