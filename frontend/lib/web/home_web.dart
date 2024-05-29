import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/web/user/create_user_form.dart';
import 'package:frontend/web/user/user.dart';

class HomeWeb extends StatefulWidget {
  const HomeWeb({super.key});

  @override
  State<HomeWeb> createState() => _HomeWebState();
}

class _HomeWebState extends State<HomeWeb> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            Container(
              width: 200,
              color: const Color(0xFF131141),
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Admin Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFFDCA200)),
                    title: const Text('User', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(FontAwesomeIcons.userTie, color: Color(0xFFDCA200)),
                    title: const Text('Pilots', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      // Handle navigation to Pilots page
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.airplanemode_active, color: Color(0xFFDCA200)),
                    title: const Text('Vols', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      // Handle navigation to Vols page
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.person_add, color: Color(0xFFDCA200)),
                    title: const Text('User CRUD Operations'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateUserForm()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF131141)),
          bodyMedium: TextStyle(color: Color(0xFF131141)),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFDCA200),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Color(0xFFDCA200)),
          titleTextStyle: TextStyle(color: Color(0xFF131141), fontSize: 20),
          toolbarTextStyle: TextStyle(color: Color(0xFF131141)),
        ),
      ),
    );
  }
}