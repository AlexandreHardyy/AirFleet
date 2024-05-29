import 'package:flutter/material.dart';
import 'package:frontend/web/auth_screen/login_screen.dart';
import 'package:frontend/web/home_web.dart';
import 'package:frontend/storage/user.dart';

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
    return isAuth ? const HomeWeb() : const LoginScreen();
  }
}