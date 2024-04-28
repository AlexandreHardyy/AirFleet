import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/routes.dart';
import 'package:frontend/services/user.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.clockRotateLeft),
            title: const Text('Flight history'),
            onTap: () {
              Navigator.of(context).push(Routes.flightHistory(context));
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.rightFromBracket),
            title: const Text("Log out"),
            onTap: () async {
              Navigator.of(context).popUntil((route) => false);
              Navigator.of(context).push(Routes.login(context));
              UserService.logOut();
            },
          )
        ],
      ),
    );
  }
}
