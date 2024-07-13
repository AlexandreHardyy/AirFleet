import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/auth/auth_bloc.dart';
import 'package:frontend/web/auth_screen/login_screen.dart';
import 'package:frontend/web/home_web.dart';
import 'package:google_fonts/google_fonts.dart';

class WebLayout extends StatelessWidget {
  const WebLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
        return state.status == AuthStatus.connected
            ? const HomeWeb()
            : const LoginScreen();
      }),
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
