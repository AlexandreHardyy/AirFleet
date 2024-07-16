import 'package:flutter/material.dart';
import 'package:frontend/mobile/vehicle_detail.dart';
import 'package:frontend/services/vehicle.dart';
import 'package:frontend/models/vehicle.dart';

class VehiclesManagementScreen extends StatefulWidget {
  static const routeName = '/vehicles-management';

  static Future<void> navigateTo(BuildContext context) async {
    await Navigator.of(context).pushNamed(routeName);
  }

  const VehiclesManagementScreen({super.key});

  @override
  _VehiclesManagementScreenState createState() => _VehiclesManagementScreenState();
}

class _VehiclesManagementScreenState extends State<VehiclesManagementScreen> {
  late Future<List<Vehicle>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = VehicleService.getVehiclesForMe();
  }

  void refreshVehicles() {
    setState(() {
      _vehiclesFuture = VehicleService.getVehiclesForMe();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My vehicles"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          VehicleDetailsPage.navigateTo(context, vehicleId: null);
          refreshVehicles();
        },
        foregroundColor: Theme.of(context).textTheme.displayLarge?.color,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: _vehiclesFuture,
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
                    leading: vehicle.isVerified!
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.cancel, color: Colors.red),
                    onTap: () async {
                      VehicleDetailsPage.navigateTo(context, vehicleId: vehicle.id);
                      refreshVehicles();
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


