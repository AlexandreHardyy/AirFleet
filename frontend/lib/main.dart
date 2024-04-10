import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Home(),
      theme: ThemeData(
        textTheme: TextTheme(
          displayLarge: GoogleFonts.prostoOne(
            color: const Color(0xFFDCA200),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          )
        ),
        // ALTERNATIVE
        /*textTheme: GoogleFonts.prostoOneTextTheme(),*/
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131141),
      body: Container(
          width:  MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: const Color(0xFF131141),
          child: Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 200,
            ),
        ),
      ),
    );
  }
}
