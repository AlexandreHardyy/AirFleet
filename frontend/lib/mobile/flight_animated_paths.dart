// // // import 'package:animated_flight_paths/animated_flight_paths.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:frontend/models/flight.dart' as flight_local_model;
// // //
// // // class FlightAnimatedPath extends StatefulWidget {
// // //   final flight_local_model.Flight flight;
// // //
// // //   const FlightAnimatedPath({super.key, required this.flight});
// // //
// // //   @override
// // //   State<FlightAnimatedPath> createState() => FlightAnimatedPathState();
// // // }
// // //
// // // class FlightAnimatedPathState extends State<FlightAnimatedPath>
// // //     with SingleTickerProviderStateMixin {
// // //   late AnimationController controller;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     controller = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(seconds: 10),
// // //     )..repeat();
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return AnimatedFlightPaths(
// // //       controller: controller,
// // //       flightSchedule: FlightSchedule(
// // //         // All flights must depart on or after [start] of schedule.
// // //         start: DateTime.parse('2023-01-01 00:00:00'),
// // //         // All flights must arrive on or before [end] of schedule.
// // //         end: DateTime.parse('2023-01-02 23:59:00'),
// // //         flights: flights,
// // //       ),
// // //       child: const MapSvg(
// // //         map: FlightMap.worldMercatorProjection,
// // //         outlineColor: Color(0xFFDCA200),
// // //         fillColor: Color(0xFF131141),
// // //       ),
// // //     );
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     controller.dispose();
// // //     super.dispose();
// // //   }
// // // }
// // //
// // // final flights = <Flight>[
// // //   Flight(
// // //     from: FlightEndpoint(
// // //       offset: const Offset(28, 51),
// // //       label: const Label(text: 'New York'),
// // //     ),
// // //     to: FlightEndpoint(
// // //       offset: const Offset(75, 65),
// // //       label: const Label(text: 'Bangkok'),
// // //     ),
// // //     departureTime: DateTime.parse('2023-01-01 00:00:00'),
// // //     arrivalTime: DateTime.parse('2023-01-01 19:30:00'),
// // //   ),
// // // ];
// // //
// // // class Label extends StatelessWidget {
// // //   const Label({super.key, required this.text});
// // //
// // //   final String text;
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// // //       decoration: BoxDecoration(
// // //         color: const Color(0xFF131141),
// // //         border: Border.all(color: const Color(0xFFDCA200), width: 2),
// // //         borderRadius: BorderRadius.circular(32),
// // //       ),
// // //       child: Text(
// // //         text,
// // //         style:
// // //             GoogleFonts.righteous(color: const Color(0xFFDCA200), fontSize: 14),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// // import 'package:animated_flight_paths/animated_flight_paths.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:frontend/models/flight.dart' as flight_local_model;
// //
// // class FlightAnimatedPath extends StatefulWidget {
// //   final flight_local_model.Flight flight;
// //
// //   const FlightAnimatedPath({super.key, required this.flight});
// //
// //   @override
// //   State<FlightAnimatedPath> createState() => FlightAnimatedPathState();
// // }
// //
// // class FlightAnimatedPathState extends State<FlightAnimatedPath>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController controller;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     controller = AnimationController(
// //       vsync: this,
// //       duration: const Duration(seconds: 10),
// //     )..repeat();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return AnimatedFlightPaths(
// //       controller: controller,
// //       flightSchedule: FlightSchedule(
// //         // All flights must depart on or after [start] of schedule.
// //         start: DateTime.parse('2023-01-01 00:00:00'),
// //         // All flights must arrive on or before [end] of schedule.
// //         end: DateTime.parse('2023-01-02 23:59:00'),
// //         flights: [
// //           Flight(
// //             from: FlightEndpoint(
// //               offset: Offset(widget.flight.departure.longitude, widget.flight.departure.latitude),
// //               label: Label(text: widget.flight.departure.name),
// //             ),
// //             to: FlightEndpoint(
// //               offset: Offset(widget.flight.arrival.longitude, widget.flight.arrival.latitude),
// //               label: Label(text: widget.flight.arrival.name),
// //             ),
// //             departureTime: DateTime.parse('2023-01-01 00:00:00'),
// //             arrivalTime: DateTime.parse('2023-01-01 19:30:00'),
// //           ),
// //         ],
// //       ),
// //       child: const MapSvg(
// //         map: FlightMap.worldMercatorProjection,
// //         outlineColor: Color(0xFFDCA200),
// //         fillColor: Color(0xFF131141),
// //       ),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     controller.dispose();
// //     super.dispose();
// //   }
// // }
// //
// // class Label extends StatelessWidget {
// //   const Label({super.key, required this.text});
// //
// //   final String text;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //       decoration: BoxDecoration(
// //         color: const Color(0xFF131141),
// //         border: Border.all(color: const Color(0xFFDCA200), width: 2),
// //         borderRadius: BorderRadius.circular(32),
// //       ),
// //       child: Text(
// //         text,
// //         style:
// //         GoogleFonts.righteous(color: const Color(0xFFDCA200), fontSize: 14),
// //       ),
// //     );
// //   }
// // }
// //
// //
// // // import 'package:animated_flight_paths/animated_flight_paths.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:frontend/models/flight.dart' as flight_local_model;
// // //
// // // class FlightAnimatedPath extends StatefulWidget {
// // //   final flight_local_model.Flight flight;
// // //
// // //   const FlightAnimatedPath({super.key, required this.flight});
// // //
// // //   @override
// // //   State<FlightAnimatedPath> createState() => FlightAnimatedPathState();
// // // }
// // //
// // // class FlightAnimatedPathState extends State<FlightAnimatedPath>
// // //     with SingleTickerProviderStateMixin {
// // //   late AnimationController controller;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     controller = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(seconds: 10),
// // //     )..repeat();
// // //   }
// // //
// // //   double _roundToThreeDecimals(double value) {
// // //     return double.parse(value.toStringAsFixed(3));
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return AnimatedFlightPaths(
// // //       controller: controller,
// // //       flightSchedule: FlightSchedule(
// // //         // All flights must depart on or after [start] of schedule.
// // //         start: DateTime.parse('2023-01-01 00:00:00'),
// // //         // All flights must arrive on or before [end] of schedule.
// // //         end: DateTime.parse('2023-01-02 23:59:00'),
// // //         flights: [
// // //           Flight(
// // //             from: FlightEndpoint(
// // //               offset: Offset(
// // //                   _roundToThreeDecimals(widget.flight.departure.longitude),
// // //                   _roundToThreeDecimals(widget.flight.departure.latitude)
// // //               ),
// // //               label: Label(text: widget.flight.departure.name),
// // //             ),
// // //             to: FlightEndpoint(
// // //               offset: Offset(
// // //                   _roundToThreeDecimals(widget.flight.arrival.longitude),
// // //                   _roundToThreeDecimals(widget.flight.arrival.latitude)
// // //               ),
// // //               label: Label(text: widget.flight.arrival.name),
// // //             ),
// // //             departureTime: DateTime.parse('2023-01-01 00:00:00'),
// // //             arrivalTime: DateTime.parse('2023-01-01 19:30:00'),
// // //           ),
// // //         ],
// // //       ),
// // //       child: const MapSvg(
// // //         map: FlightMap.worldMercatorProjection,
// // //         outlineColor: Color(0xFFDCA200),
// // //         fillColor: Color(0xFF131141),
// // //       ),
// // //     );
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     controller.dispose();
// // //     super.dispose();
// // //   }
// // // }
// // //
// // // class Label extends StatelessWidget {
// // //   const Label({super.key, required this.text});
// // //
// // //   final String text;
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// // //       decoration: BoxDecoration(
// // //         color: const Color(0xFF131141),
// // //         border: Border.all(color: const Color(0xFFDCA200), width: 2),
// // //         borderRadius: BorderRadius.circular(32),
// // //       ),
// // //       child: Text(
// // //         text,
// // //         style: GoogleFonts.righteous(color: const Color(0xFFDCA200), fontSize: 14),
// // //       ),
// // //     );
// // //   }
// // // }
//
//
// import 'dart:math' as math;
// import 'package:animated_flight_paths/animated_flight_paths.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:frontend/models/flight.dart' as flight_local_model;
//
// class FlightAnimatedPath extends StatefulWidget {
//   final flight_local_model.Flight flight;
//
//   const FlightAnimatedPath({super.key, required this.flight});
//
//   @override
//   State<FlightAnimatedPath> createState() => FlightAnimatedPathState();
// }
//
// class FlightAnimatedPathState extends State<FlightAnimatedPath>
//     with SingleTickerProviderStateMixin {
//   late AnimationController controller;
//
//   @override
//   void initState() {
//     super.initState();
//     controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 10),
//     )..repeat();
//   }
//
//   // Convert longitude to X
//   double longitudeToX(double longitude, double mapWidth) {
//     return ((longitude + 180) / 360) * mapWidth;
//   }
//
//   // Convert latitude to Y using Mercator projection
//   double latitudeToY(double latitude, double mapHeight) {
//     double latRad = latitude * math.pi / 180;
//     double mercN = math.log(math.tan((math.pi / 4) + (latRad / 2)));
//     return (mapHeight / 2) - (mapHeight * mercN / (2 * math.pi));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Define map dimensions (example values, adjust as necessary)
//     const double mapWidth = 1000;
//     const double mapHeight = 500;
//
//     // Calculate offsets for departure and arrival
//     final departureOffset = Offset(
//       longitudeToX(widget.flight.departure.longitude, mapWidth),
//       latitudeToY(widget.flight.departure.latitude, mapHeight),
//     );
//
//     final arrivalOffset = Offset(
//       longitudeToX(widget.flight.arrival.longitude, mapWidth),
//       latitudeToY(widget.flight.arrival.latitude, mapHeight),
//     );
//
//     return AnimatedFlightPaths(
//       controller: controller,
//       flightSchedule: FlightSchedule(
//         start: DateTime.parse('2023-01-01 00:00:00'),
//         end: DateTime.parse('2023-01-02 23:59:00'),
//         flights: [
//           Flight(
//             from: FlightEndpoint(
//               offset: departureOffset,
//               label: Label(text: widget.flight.departure.name),
//             ),
//             to: FlightEndpoint(
//               offset: arrivalOffset,
//               label: Label(text: widget.flight.arrival.name),
//             ),
//             departureTime: DateTime.parse('2023-01-01 00:00:00'),
//             arrivalTime: DateTime.parse('2023-01-01 19:30:00'),
//           ),
//         ],
//       ),
//       child: const MapSvg(
//         map: FlightMap.worldMercatorProjection,
//         outlineColor: Color(0xFFDCA200),
//         fillColor: Color(0xFF131141),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
// }
//
// class Label extends StatelessWidget {
//   const Label({super.key, required this.text});
//
//   final String text;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: const Color(0xFF131141),
//         border: Border.all(color: const Color(0xFFDCA200), width: 2),
//         borderRadius: BorderRadius.circular(32),
//       ),
//       child: Text(
//         text,
//         style: GoogleFonts.righteous(color: const Color(0xFFDCA200), fontSize: 14),
//       ),
//     );
//   }
// }

import 'package:animated_flight_paths/animated_flight_paths.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/models/flight.dart' as flight_local_model;

class FlightAnimatedPath extends StatefulWidget {
  final flight_local_model.Flight flight;

  const FlightAnimatedPath({super.key, required this.flight});

  @override
  State<FlightAnimatedPath> createState() => FlightAnimatedPathState();
}

class FlightAnimatedPathState extends State<FlightAnimatedPath>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  double convertLongitudeToX(double longitude) {
    return ((longitude + 180) / 360) * 100;
  }

  double convertLatitudeToY(double latitude) {
    return ((90 - latitude) / 180) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedFlightPaths(
      controller: controller,
      flightSchedule: FlightSchedule(
        start: DateTime.parse('2023-01-01 00:00:00'),
        end: DateTime.parse('2023-01-02 23:59:00'),
        flights: [
          Flight(
            from: FlightEndpoint(
              offset: Offset(
                convertLongitudeToX(widget.flight.departure.longitude),
                convertLatitudeToY(widget.flight.departure.latitude),
              ),
              label: Label(text: widget.flight.departure.name),
            ),
            to: FlightEndpoint(
              offset: Offset(
                convertLongitudeToX(widget.flight.arrival.longitude),
                convertLatitudeToY(widget.flight.arrival.latitude),
              ),
              label: Label(text: widget.flight.arrival.name),
            ),
            departureTime: DateTime.parse('2023-01-01 00:00:00'),
            arrivalTime: DateTime.parse('2023-01-01 19:30:00'),
          ),
        ],
      ),
      child: const MapSvg(
        map: FlightMap.worldMercatorProjection,
        outlineColor: Color(0xFFDCA200),
        fillColor: Color(0xFF131141),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class Label extends StatelessWidget {
  const Label({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF131141),
        border: Border.all(color: const Color(0xFFDCA200), width: 2),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Text(
        text,
        style:
        GoogleFonts.righteous(color: const Color(0xFFDCA200), fontSize: 14),
      ),
    );
  }
}
