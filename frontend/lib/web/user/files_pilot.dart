import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/dio.dart';
import 'package:frontend/storage/user.dart';
import 'package:frontend/widgets/title.dart';

class FilesPilot extends StatefulWidget {
  final User user;

  const FilesPilot({super.key, required this.user});

  @override
  _FilesPilotState createState() => _FilesPilotState();
}

class _FilesPilotState extends State<FilesPilot> {
  String? _token;
  bool _isLoading = true;

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
    if (widget.user.role != Roles.pilot) {
      return const SizedBox();
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        const SecondaryTitle(content: "Informations about the pilot"),
        const SizedBox(height: 24),
        Row(
          children: [
            ...(widget.user.files?.map((file) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(file.type),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 250,
                        child: Image(
                          image: NetworkImage(
                              '$apiUrl/users/${widget.user.id}/files/${file.type}',
                              headers: {
                                'Authorization': 'Bearer $_token',
                              }),
                        ),
                      )
                    ],
                  );
                }) ??
                []),
          ],
        ),
      ],
    );
  }
}
