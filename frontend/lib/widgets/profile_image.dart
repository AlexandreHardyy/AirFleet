import 'package:flutter/material.dart';
import 'package:frontend/services/dio.dart';
import 'package:frontend/storage/user.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({super.key});

  @override
  ProfileImageState createState() => ProfileImageState();
}

class ProfileImageState extends State<ProfileImage> {
  String? _token;
  bool _isLoading = true;
  DateTime _time = DateTime.now();

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Image.network(
      fit: BoxFit.fitHeight,
      key: ValueKey(_time),
      '$apiUrl/users/${UserStore.user?.id}/files/profile?time=${_time}',
      headers: {
        'Authorization': 'Bearer $_token',
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.person, size: 30.0);
      },
    );
  }
}