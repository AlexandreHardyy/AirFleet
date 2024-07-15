import 'package:flutter/material.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:intl/intl.dart';

class UserVehiclesScreen extends StatelessWidget {
  static const routeName = '/vehicles';

  static Future<void> navigateTo(BuildContext context, {required List<Vehicle> vehicles}) {
    return Navigator.of(context).pushNamed(routeName, arguments: vehicles);
  }

  final List<Vehicle> vehicles;

  const UserVehiclesScreen({super.key, required this.vehicles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Vehicles'),
      ),
      body: ListView.separated(
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          IconData iconData;
          Color iconColor;
          if (vehicle.isVerified == null) {
            iconData = Icons.help_outline;
            iconColor = Colors.grey;
          } else if (vehicle.isVerified!) {
            iconData = Icons.check_circle;
            iconColor = Colors.green;
          } else {
            iconData = Icons.cancel;
            iconColor = Colors.red;
          }
          String formattedDate = '';
          if (vehicle.updatedAt != null && vehicle.updatedAt!.isNotEmpty) {
            try {
              final DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(vehicle.updatedAt!);
              formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
            } catch (e) {
              formattedDate = 'Invalid date';
            }
          } else {
            formattedDate = 'No date provided';
          }
          return ListTile(
            leading: Icon(iconData, color: iconColor),
            title: Text(vehicle.modelName),
            subtitle: Text('${vehicle.matriculation} - ${vehicle.type} - $formattedDate'),
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}