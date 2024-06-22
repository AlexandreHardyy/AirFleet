import 'package:flutter/material.dart';
import 'package:frontend/web/auth_screen/login_screen.dart';
import 'package:frontend/web/home_web.dart';
import 'package:frontend/storage/user.dart';
import 'package:google_fonts/google_fonts.dart';

class WebLayout extends StatefulWidget {
  const WebLayout({super.key});

  @override
  WebLayoutState createState() => WebLayoutState();
}

class WebLayoutState extends State<WebLayout> {
  WebLayoutState() {
    checkAuth();
  }
  var isAuth = false;

  checkAuth() async {
    final user = await UserStore.getUser();
    setState(() {
      isAuth = user == null ? false : true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          home: isAuth ? const HomeWeb() : const LoginScreen(),
          theme: ThemeData(
            textTheme: TextTheme(
                displayLarge: GoogleFonts.prostoOne(
                  color: const Color(0xFFDCA200),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                )
            ),
          )
      );
  }
}