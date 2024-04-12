import 'package:flutter/material.dart';
import 'package:frontend/map/map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  const String MAPBOX_ACCESS_TOKEN = String.fromEnvironment("PUBLIC_ACCESS_TOKEN");
  MapboxOptions.setAccessToken(MAPBOX_ACCESS_TOKEN);

  await Future.delayed(const Duration(seconds: 3));

  FlutterNativeSplash.remove();
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
      body: Column(
        children: [
          const Expanded(
            flex: 2,
            child: AirFleetMap(),
          ),
          Expanded(
            flex: 1,
            child:
              Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.blue,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.pink,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.red,
                    ),
                  ),
                ]
              ),
          )
        ],
      )
    );
  }
}
