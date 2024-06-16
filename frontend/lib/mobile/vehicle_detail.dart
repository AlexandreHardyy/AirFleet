import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:frontend/services/vehicle.dart';


class VehicleDetailsPage extends StatefulWidget {
  final int? vehicleId;

  const VehicleDetailsPage({super.key, this.vehicleId});

  @override
  _VehicleDetailsPageState createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  late Future<Vehicle> _vehicleDetails;
  final _formKey = GlobalKey<FormState>();
  late Vehicle _vehicle;
  bool isPlaneSelected = true;

  @override
  void initState() {
    super.initState();
    if (widget.vehicleId == null) {
      _vehicle = Vehicle(
        modelName: '',
        matriculation: '',
        seat: 0,
        type: 'PLANE',
      );
      _vehicleDetails = Future.value(_vehicle);
    } else {
      _vehicleDetails = VehicleService.getVehicle(widget.vehicleId!);
      _vehicleDetails.then((vehicle) {
        setState(() {
          isPlaneSelected = vehicle.type == 'PLANE';
        });
      });
    }
  }

  void toggleSelection(bool isPlane) {
    setState(() {
      isPlaneSelected = isPlane;
      _vehicle.type = isPlane ? 'PLANE' : 'HELICOPTER';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.vehicleId == null ? const Text('Create a new Vehicle'): const Text('Edit Vehicle'),
      ),
      body: FutureBuilder<Vehicle>(
        future: _vehicleDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a model name';
                        }
                        return null;
                      },
                      onSaved: (value) => _vehicle.modelName = value!,
                    ),
                    TextFormField(
                      initialValue: _vehicle.matriculation,
                      decoration: const InputDecoration(labelText: 'Matriculation'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a matriculation';
                        }
                        return null;
                      },
                      onSaved: (value) => _vehicle.matriculation = value!,
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
                      onSaved: (value) => _vehicle.seat = int.parse(value!),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Select Vehicle Type:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => toggleSelection(true),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: isPlaneSelected ? Colors.blue : Colors.grey,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'Plane',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => toggleSelection(false),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: !isPlaneSelected ? Colors.blue : Colors.grey,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'Helicopter',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ...widget.vehicleId == null
                        ? [
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            try {
                              await VehicleService.createVehicle(_vehicle);
                              Navigator.of(context).pop();
                            } on DioException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.response?.data['message']}'),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Save Vehicle'),
                      ),
                    ] : [
                      ElevatedButton(
                        onPressed: () => {
                          if (_formKey.currentState!.validate())
                            {
                              _formKey.currentState!.save(),
                              VehicleService.updateVehicle(_vehicle),
                              Navigator.of(context).pop(),
                            }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Update Vehicle'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm'),
                                content: const Text('Are you sure you want to delete this vehicle?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Yes'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('No'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            try {
                              await VehicleService.deleteVehicle(widget.vehicleId!);
                              Navigator.of(context).pop();
                            } on DioException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.response?.data['message']}'),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Delete Vehicle'),
                      ),
                    ],
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
