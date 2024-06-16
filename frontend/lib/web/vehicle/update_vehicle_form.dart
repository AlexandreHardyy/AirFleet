import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:frontend/services/vehicle.dart';

class UpdateVehicleForm extends StatefulWidget {
  final Vehicle vehicle;

  const UpdateVehicleForm({super.key, required this.vehicle});

  @override
  _UpdateVehicleFormState createState() => _UpdateVehicleFormState();
}

class _UpdateVehicleFormState extends State<UpdateVehicleForm> {
  final _formKey = GlobalKey<FormState>();
  late Vehicle _vehicle;
  bool isPlaneSelected = true;

  @override
  void initState() {
    super.initState();
    _vehicle = Vehicle(
      id: widget.vehicle.id,
      modelName: widget.vehicle.modelName,
      matriculation: widget.vehicle.matriculation,
      seat: widget.vehicle.seat,
      type: widget.vehicle.type,
      isVerified: widget.vehicle.isVerified,
    );
    isPlaneSelected = _vehicle.type == 'PLANE';
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
        title: const Text('Update Vehicle'),
      ),
      body: Form(
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
                            color: isPlaneSelected ? const Color(0xFFDCA200) : Colors.grey,
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
                            color: !isPlaneSelected ? const Color(0xFFDCA200) : Colors.grey,
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
              Row(
                children: [
                  const Text('Is Verified'),
                  const SizedBox(width: 10),
                  Checkbox(
                    value: _vehicle.isVerified,
                    onChanged: (value) {
                      setState(() {
                        _vehicle.isVerified = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    try {
                      await VehicleService.updateVehicle(_vehicle);
                      Navigator.pop(context, true);
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
                child: const Text('Update Vehicle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}