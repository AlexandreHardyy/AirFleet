import 'package:flutter/material.dart';
import 'package:frontend/services/vehicle.dart';
import 'package:frontend/models/vehicle.dart';

import '../routes.dart';

class VehiclesManagementScreen extends StatelessWidget {
  const VehiclesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My vehicles"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // onPressed
        },
        foregroundColor: Theme
            .of(context)
            .textTheme
            .displayLarge
            ?.color,
        backgroundColor: Theme
            .of(context)
            .primaryColor,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: VehicleService.getVehicles(),
        builder: (BuildContext context, AsyncSnapshot<List<Vehicle>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No vehicles found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Vehicle vehicle = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(vehicle.modelName),
                    subtitle: Text('Matriculation: ${vehicle.matriculation}'),
                    onTap: () {
                      Navigator.of(context).push(Routes.vehicleDetail(
                          context, vehicleId: vehicle.id));
                    },
                  ),
                );
              },
            );
          }
        },
      ),

    );
  }
}


