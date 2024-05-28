import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/layouts/mobile_layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: ".env");

  final String MAPBOX_ACCESS_TOKEN =
      const String.fromEnvironment("PUBLIC_ACCESS_TOKEN") != ""
          ? const String.fromEnvironment("PUBLIC_ACCESS_TOKEN")
          : dotenv.get("PUBLIC_ACCESS_TOKEN_MAPBOX");

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
      home: const MobileLayout(),
      theme: ThemeData(
        primaryColor: const Color(0xFF131141),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.prostoOne(
            color: const Color(0xFFDCA200),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        // ALTERNATIVE
        /*textTheme: GoogleFonts.prostoOneTextTheme(),*/
      ),
    );
  }
}
