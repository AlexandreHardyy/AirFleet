import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        _showConfirmationDialog();
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

  Future<void> _showConfirmationDialog() async {
    final confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate("common.confirm")),
          content: Text(translate("home.profile.updateProfilePicture.submit")),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(translate("common.yes")),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(translate("common.no")),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _submit();
    } else {
      setState(() {
        _newPhoto = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        FormBuilder(
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
                          '$apiUrl/users/${UserStore.user?.id}/files/profile?time=$_time',
                          headers: {
                            'Authorization': 'Bearer $_token',
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              UserStore.user?.role == Roles.pilot
                                  ? FontAwesomeIcons.userTie
                                  : FontAwesomeIcons.userLarge,
                              color: const Color(0xFFDCA200),
                              size: 50,
                            );
                          },
                        ),
                )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
