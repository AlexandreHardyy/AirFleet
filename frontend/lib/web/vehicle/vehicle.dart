import 'package:flutter/material.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:frontend/services/vehicle.dart';
import 'package:frontend/web/vehicle/update_vehicle_form.dart';
import 'package:frontend/web/vehicle/create_vehicle_form.dart';

class VehicleScreen extends StatefulWidget {
  static const routeName = '/vehicle';

  static Future<void> navigateTo(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  const VehicleScreen({super.key});

  @override
  _VehicleScreenState createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    try {
      _vehicles = await VehicleService.getVehicles();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> _editVehicle(Vehicle vehicle) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateVehicleForm(vehicle: vehicle)),
    );

    if (result == true) {
      _fetchVehicles();
    }
  }

  void _deleteVehicle(int id) async {
    try {
      await VehicleService.deleteVehicle(id);
      _fetchVehicles();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateVehicleForm()),
                );
              },
              child: const Text('Create a new Vehicle'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: DataTable(
                          columnSpacing: 0,
                          columns: const [
                            DataColumn(label: Text('Model Name', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Matriculation', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Seat', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Cruise speed', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Cruise altitude', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Is verified', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Is selected', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(
                              label: Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 28.0),
                                  child: Text(
                                    'Actions',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          rows: _vehicles.map((vehicle) {
                            return DataRow(
                              cells: [
                                DataCell(Text(vehicle.modelName)),
                                DataCell(Text(vehicle.matriculation)),
                                DataCell(Text(vehicle.seat.toString())),
                                DataCell(Text(vehicle.cruiseSpeed.toString())),
                                DataCell(Text(vehicle.cruiseAltitude.toString())),
                                DataCell(Text(vehicle.type)),
                                DataCell(
                                  Checkbox(
                                    value: vehicle.isVerified,
                                    onChanged: null,
                                    tristate: true,
                                  ),
                                ),
                                DataCell(
                                  Checkbox(
                                    value: vehicle.isSelected,
                                    onChanged: null,
                                    tristate: true,
                                  ),
                                ),
                                DataCell(
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 16.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Color(0xFFDCA200)),
                                            onPressed: () => _editVehicle(vehicle),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Color(0xFFDCA200)),
                                            onPressed: () => _deleteVehicle(vehicle.id!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
