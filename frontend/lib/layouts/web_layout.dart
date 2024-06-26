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
          home: context.read<AuthBloc>().state.status == AuthStatus.connected ? const HomeWeb() : const LoginScreen(),
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