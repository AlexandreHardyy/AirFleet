import 'package:flutter/material.dart';
import 'package:frontend/mobile/auth_screen/login_screen.dart';
import 'package:frontend/mobile/home/home.dart';
import 'package:frontend/storage/user.dart';

class MobileLayout extends StatefulWidget {
  const MobileLayout({super.key});

  @override
  MobileLayoutState createState() => MobileLayoutState();
}

class MobileLayoutState extends State<MobileLayout> {
  MobileLayoutState() {
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
    return isAuth ? const Home() : const LoginScreen();
  }
}
