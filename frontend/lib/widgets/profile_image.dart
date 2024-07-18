import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/services/dio.dart';
import 'package:frontend/storage/user.dart';

class ProfileImage extends StatefulWidget {
  final String? profileID;

  const ProfileImage({super.key, this.profileID});

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

    String? userId = widget.profileID ?? UserStore.user?.id.toString();

    return CircleAvatar(
      radius: 50,
      backgroundColor: const Color(0xFF131141),
      child: Image.network(
        '$apiUrl/users/$userId/files/profile?time=$_time',
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
    );
  }
}
