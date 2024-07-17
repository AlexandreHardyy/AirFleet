
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frontend/services/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/services/dio.dart';
import 'package:frontend/storage/user.dart';

class ProfileImageForm extends StatefulWidget {
  const ProfileImageForm({super.key});

  @override
  ProfileImageFormState createState() => ProfileImageFormState();
}

class ProfileImageFormState extends State<ProfileImageForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  String? _token;
  bool _isLoading = true;
  File? _newPhoto;
  DateTime _time = DateTime.now();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    _token = await UserStore.getToken();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newPhoto = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_newPhoto != null) {
      await UserService.uploadImage(_newPhoto!.path);
      setState(() {
        _time = DateTime.now();
        _newPhoto = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: ClipOval(
              child: SizedBox(
                width: 100,
                height: 100,
                child: _newPhoto != null
                ? Image.file(_newPhoto!)
                : Image.network(
                    key: ValueKey(_time),
                    '$apiUrl/users/${UserStore.user?.id}/files/profile?time=${_time}',
                    headers: {
                      'Authorization': 'Bearer $_token',
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, size: 30.0);
                    },
                  ),
            )),
          ),
          if (_newPhoto != null)
            TextButton(
              onPressed: _submit,
              child: const Text('Confirme upload'),
            ),
        ],
      ),
    );
  }
}
