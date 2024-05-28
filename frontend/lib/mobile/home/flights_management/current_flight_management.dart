import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/home/blocs/current_flight_bloc.dart';
import 'package:frontend/storage/user.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class CurrentFlightManagement extends StatefulWidget {
  const CurrentFlightManagement({super.key});

  @override
  State<CurrentFlightManagement> createState() => _CurrentFlightManagementState();
}

class _CurrentFlightManagementState extends State<CurrentFlightManagement> {
  late IO.Socket _socket;

  @override
  void initState() {
    super.initState();

    initSocket().then((socket) {
      setState(() {
        _socket = socket;
      });
    });
  }

   Future<IO.Socket> initSocket() async {
    final bearerToken = await UserStore.getToken();
    final socket = IO.io('http://localhost:3001/flights', OptionBuilder()
        .setTransports(['websocket']) // for Flutter or Dart VM
        .disableAutoConnect()
        .disableAutoConnect()// disable auto-connection
        .setExtraHeaders({'Bearer': bearerToken}) // optional
        .build()
    );
    socket.connect();
    socket.onConnect((_) {
      print('Connection established');
    });
    socket.onDisconnect((_) => print('Connection Disconnection'));
    socket.onConnectError((err) => print(err));
    socket.onError((err) => print(err));

    return socket;
  }


  @override
  Widget build(BuildContext context) {
    if (context.mounted) {
      final currentFlightState = context.read<CurrentFlightBloc>().state;
      
      _socket.emit("createSession", "${currentFlightState.flight!.id}");

      _socket.on("flightUpdated", (_) {
        context.read<CurrentFlightBloc>().add(CurrentFlightUpdated());
      });
    }
    return Center(
      child: BlocConsumer<CurrentFlightBloc, CurrentFlightState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.flight!.status == 'waiting_pilot') {
            return Column(
              children: [
                ElevatedButton(
                    onPressed: () {
                      context.read<CurrentFlightBloc>().add(CurrentFlightLoaded(flight: state.flight!));
                    },
                    child: const Text("Focus on route")
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text("Departure:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(state.flight!.departure.name)
                      ]
                    ),
                    Column(
                      children: [
                        const Text("Arrival:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(state.flight!.arrival.name)
                      ]
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text("Waiting for a pilot to accept the flight"),
                const LinearProgressIndicator(),
                ElevatedButton(
                    onPressed: () {
                      _socket.emit("cancelFlight", "${state.flight!.id}");
                    },
                    child: const Text("Cancel flight"))
              ]
            );
          }

          if (state.flight!.status == 'waiting_proposal_approval') {
            return Column(
              children: [
                const Text("Price offer received !"),
                const SizedBox(height: 10),
                Text("Price : ${state.flight!.price}"),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _socket.emit("flightProposalChoice", jsonEncode({"flightId": state.flight!.id, "choice": "accepted"}));
                      },
                      child: const Text('Accept price offer'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _socket.emit("flightProposalChoice", jsonEncode({"flightId": state.flight!.id, "choice": "rejected"}));
                      },
                      child: const Text('Reject price offer'),
                    ),
                  ],
                ),
              ],
            );
          }

          if (state.flight!.status == 'waiting_takeoff') {
            return const Text("Waiting for takeoff");
          }

          if (state.flight!.status == 'in_progress') {
            return const Text("In flight");
          }

          return const Text('No flight selected');
        }
      ),
    );
  }
}
