import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
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
  _VehiclesManagementScreenState createState() =>
      _VehiclesManagementScreenState();
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
      body: Stack(
        children: [
          FutureBuilder<List<Vehicle>>(
            future: _vehiclesFuture,
            builder: (BuildContext context, AsyncSnapshot<List<Vehicle>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/empty.svg',
                          semanticsLabel: 'Plane icon',
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'You are not part of any proposal',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: () async {
                    refreshVehicles();
                  },
                  child: ListView.builder(
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
                            await VehicleDetailsPage.navigateTo(context,
                                vehicleId: vehicle.id);
                            refreshVehicles();
                          },
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  await VehicleDetailsPage.navigateTo(context, vehicleId: null);
                  refreshVehicles();
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF131141),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Theme.of(context).textTheme.displayLarge?.color),
                    const SizedBox(width: 8),
                    Text(
                      translate("home.vehicle_management.add"),
                      style: TextStyle(color: Theme.of(context).textTheme.displayLarge?.color),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
