import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/models/flight.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class SimulationScreen extends StatefulWidget {
  static const routeName = '/simulation';

  static Future<void> navigateTo(BuildContext context, {required Flight flight}) {
    return Navigator.of(context).pushNamed(routeName, arguments: flight);
  }

  final Flight flight;

  const SimulationScreen({super.key, required this.flight});

  @override
  _SimulationScreenState createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SocketIoBloc>(
      create: (context) => SocketIoBloc()..add(SocketIoInitialized()),
      child: BlocBuilder<SocketIoBloc, SocketIoState>(
        builder: (context, state) {

          if (state.status == SocketIoStatus.error) {
            return Scaffold(
              body: Center(
                child: Text(state.errorMessage!),
              ),
            );
          }

          if (state.status == SocketIoStatus.loading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Temporary(flight: widget.flight);
        }
      ),
    );
  }
}

class Temporary extends StatefulWidget {
  final Flight flight;
  const Temporary({super.key, required this.flight});

  @override
  State<Temporary> createState() => _TemporaryState();
}

class _TemporaryState extends State<Temporary> {
  String? flightState;
  Position? flightPosition;
  late SocketIoBloc _socketIoBloc;

  @override
  void initState() {
    super.initState();
    _socketIoBloc = context.read<SocketIoBloc>();

    print("bonosir");

    print(_socketIoBloc.state.status);

    if (_socketIoBloc.state.status == SocketIoStatus.disconnected) {
      _socketIoBloc.state.socket!.connect();
      _socketIoBloc.add(SocketIoCreateSession(flightId: widget.flight.id));
      print("bonosir2222");
    }

    _socketIoBloc.add(SocketIoListenEvent(
      eventId: "flightUpdated",
      event: "flightUpdated",
      callback: (flightState) {
        if (mounted) {
          setState(() {
            this.flightState = flightState;
          });
        }
      },
    ));

    _socketIoBloc.add(SocketIoListenEvent(
      eventId: "pilotPositionUpdated",
      event: "pilotPositionUpdated",
      callback: (data) {
        Map<String, dynamic> jsonData = jsonDecode(data);
        flightPosition = Position(jsonData['longitude'], jsonData['latitude']);
      },
    ));
  }

  @override
  void dispose() {
    _socketIoBloc.add(SocketIoStopListeningEvent(eventId: 'flightUpdated'));
    _socketIoBloc
        .add(SocketIoStopListeningEvent(eventId: 'pilotPositionUpdated'));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              // Add a Card widget to display flight details
              child: ListTile(
                title: const Text('Flight Simulation Details'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Departure: ${widget.flight.departure.name}'),
                    Text('Arrival: ${widget.flight.arrival.name}'),
                    Text('Status: ${widget.flight.status}'),
                    if (flightState != null)
                      Text('Live information: $flightState'),
                    if (flightPosition != null)
                      Text(
                          'Pilot position: ${flightPosition!.lat}, ${flightPosition!.lng}'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 1),
                        const FlSpot(1, 3),
                        const FlSpot(2, 10),
                        // Add more points here
                      ],
                      isCurved: true,
                      barWidth: 5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              print("test");
              _socketIoBloc.state.socket!.emit(
                "flightSimulation",
                jsonEncode({
                  "flightId": widget.flight.id,
                  "pilotId": widget.flight.pilot!.id
                }),
              );
              print("test2");
            },
            child: const Icon(Icons.play_arrow),
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            onPressed: () {
              _socketIoBloc.state.socket!.emit(
                "flightSimulationStop",
                jsonEncode({
                  "flightId": widget.flight.id,
                  "pilotId": widget.flight.pilot!.id
                }),
              );
            },
            child: const Icon(Icons.stop),
          ),
        ],
      ),
    );
  }
}
