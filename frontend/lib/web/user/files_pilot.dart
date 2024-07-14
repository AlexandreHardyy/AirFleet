import 'package:flutter/widgets.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/storage/user.dart';
import 'package:frontend/widgets/title.dart';

class FilesPilot extends StatelessWidget {
  final User user;
  const FilesPilot({super.key, required this.user});

  @override
  Widget build(BuildContext context) {

    if (user.role != Roles.pilot) {
      return const SizedBox();
    }

    return Column(
      children: [
        const SecondaryTitle(content: "Informations about the pilot"),
        const SizedBox(
          height: 24,
        ),
        Row(
          children: [
            ...(user.files?.map((file) {
                  return Column(
                    children: [
                      Text(file.type),
                      const SizedBox(height: 16),
                      Image.network(
                          'https://airfleet-prod.s3.eu-west-3.amazonaws.com/${file.path}')
                    ],
                  );
                }) ??
                []),
          ],
        )
      ],
    );
  }
}
