import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:frontend/services/dio.dart';

class FlightHistoryScreen extends StatefulWidget {
  const FlightHistoryScreen({super.key});

  @override
  State<FlightHistoryScreen> createState() => _FlightHistoryScreenState();
}

class _FlightHistoryScreenState extends State<FlightHistoryScreen> {
  late Future<String> message;

  @override
  void initState() {
    super.initState();

    message = fetchFlights();
  }

  Future<String> fetchFlights() async {
    Response response;
    try {
      response = await dioApi.get("flights");

      FlightResponse flightResponse = FlightResponse.fromJson(response.data);

      return flightResponse.message;
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 404) {
          throw Exception('No flights found.');
        }
      }

      throw Exception('Something went wrong: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flight History"),
      ),
      body: FutureBuilder<String>(
          future: message,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            return Center(
              child:
              (snapshot.connectionState == ConnectionState.waiting)
                  ? const CircularProgressIndicator()
                  : (snapshot.hasError)
                  ? Text('Error: ${snapshot.error}')
                  : Text('Fetched data: ${snapshot.data}'),
            );
          }),
    );
  }
}

class FlightResponse {
  final String message;

  FlightResponse({required this.message});

  factory FlightResponse.fromJson(Map<String, dynamic> json) {
    return FlightResponse(
      message: json['message'],
    );
  }
}

