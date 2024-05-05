import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:frontend/services/vehicle.dart';

import '../services/dio.dart';

class VehicleDetailsPage extends StatefulWidget {
  final int vehicleId;

  const VehicleDetailsPage({super.key, required this.vehicleId});

  @override
  _VehicleDetailsPageState createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  late Future<Vehicle> _vehicleDetails;
  final _formKey = GlobalKey<FormState>();
  late Vehicle _vehicle;

  get updateVehicle => null;
  get deleteVehicle => null;

  @override
  void initState() {
    super.initState();

    _vehicleDetails = VehicleService.getVehicle(widget.vehicleId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
      ),
      body: FutureBuilder<Vehicle>(
        future: _vehicleDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else {
            _vehicle = snapshot.data!;
            return Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _vehicle.modelName,
                      decoration: const InputDecoration(labelText: 'Model Name'),
                    ),
                    TextFormField(
                      initialValue: _vehicle.matriculation,
                      decoration: const InputDecoration(labelText: 'Matriculation'),
                    ),
                    TextFormField(
                      initialValue: _vehicle.seat.toString(),
                      decoration: const InputDecoration(labelText: 'Seat'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a number';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    ElevatedButton(
                      onPressed: updateVehicle,
                      child: const Text('Update Vehicle'),
                    ),
                    ElevatedButton(
                      onPressed: deleteVehicle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red
                      ),
                      child: const Text('Delete Vehicle'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
