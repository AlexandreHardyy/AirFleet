import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/mobile/blocs/pilot_status/pilot_status_bloc.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:frontend/services/vehicle.dart';

class VehicleDetailsPage extends StatefulWidget {
  static const routeName = '/vehicle-detail';

  static Future<void> navigateTo(BuildContext context, {int? vehicleId}) {
    return Navigator.of(context).pushNamed(routeName, arguments: vehicleId);
  }

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
  var _isLoading = false;

  InputDecoration _buildInputDecoration(
      {required String labelText, IconData? prefixIcon, String? suffixText}) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixText: suffixText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.vehicleId == null) {
      _vehicle = Vehicle(
        modelName: '',
        matriculation: '',
        seat: 0,
        type: 'PLANE',
        cruiseSpeed: 0,
        cruiseAltitude: 0,
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
        title: widget.vehicleId == null
            ? Text(translate('vehicle.create_vehicle'))
            : Text(translate('vehicle.edit_vehicle')),
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
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _vehicle.modelName,
                        decoration:
                            _buildInputDecoration(labelText: 'Model Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a model name';
                          }
                          return null;
                        },
                        onSaved: (value) => _vehicle.modelName = value!,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        initialValue: _vehicle.matriculation,
                        decoration:
                            _buildInputDecoration(labelText: 'Matriculation'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a matriculation';
                          }
                          return null;
                        },
                        onSaved: (value) => _vehicle.matriculation = value!,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        initialValue: _vehicle.seat.toString(),
                        decoration: _buildInputDecoration(labelText: 'Seat'),
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
                      const SizedBox(height: 18),
                      const Text(
                        'Select Vehicle Type:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        initialValue: _vehicle.cruiseSpeed.toString(),
                        decoration: _buildInputDecoration(
                            labelText: 'Cruise Speed', suffixText: 'kts'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a number';
                          }
                          if (num.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) =>
                            _vehicle.cruiseSpeed = num.parse(value!),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        initialValue: _vehicle.cruiseAltitude.toString(),
                        decoration: _buildInputDecoration(
                            labelText: 'Cruise Altitude', suffixText: 'ft'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a number';
                          }
                          if (num.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) =>
                            _vehicle.cruiseAltitude = num.parse(value!),
                      ),
                      const SizedBox(height: 20),
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
                                    color: isPlaneSelected
                                        ? const Color(0xFFDCA200)
                                        : Colors.grey,
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
                                    color: !isPlaneSelected
                                        ? const Color(0xFFDCA200)
                                        : Colors.grey,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Helicopter',
                                    style: TextStyle(
                                      color: Color(0xFF131141),
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                      ...widget.vehicleId == null
                          ? [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      try {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        await VehicleService.createVehicle(
                                            _vehicle);
                                        Navigator.of(context).pop();
                                      } on DioException catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Error: ${e.response?.data['message']}'),
                                          ),
                                        );
                                      }
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  },
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 15.0,
                                          width: 15.0,
                                          child: Center(
                                              child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          )),
                                        )
                                      : const Text('Save Vehicle'),
                                ),
                              ),
                            ]
                          : [
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          _formKey.currentState!.save();
                                          VehicleService.updateVehicle(
                                              _vehicle);
                                          Navigator.of(context).pop();
                                          context
                                              .read<PilotStatusBloc>()
                                              .add(PilotStatusNotReady());
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor:
                                            const Color(0xFF131141),
                                        backgroundColor:
                                            const Color(0xFFDCA200),
                                      ),
                                      child: Text(
                                          translate('vehicle.update_vehicle')),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final confirm = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Confirm'),
                                              content: const Text(
                                                  'Are you sure you want to delete this vehicle?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  child: const Text('Yes'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                  child: const Text('No'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirm == true) {
                                          try {
                                            await VehicleService.deleteVehicle(
                                                widget.vehicleId!);
                                            Navigator.of(context).pop();
                                          } on DioException catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Error: ${e.response?.data['message']}'),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade100,
                                        foregroundColor: Colors.red,
                                      ),
                                      child: Text(
                                          translate('vehicle.delete_vehicle')),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
