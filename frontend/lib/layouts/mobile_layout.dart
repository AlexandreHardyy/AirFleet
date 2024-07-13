import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/auth/auth_bloc.dart';
import 'package:frontend/mobile/auth_screen/login_screen.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/message/message_bloc.dart';
import 'package:frontend/mobile/blocs/pilot_status/pilot_status_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/mobile/home/home.dart';
import 'package:google_fonts/google_fonts.dart';

class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<PilotStatusBloc>(
            create: (context) =>
                PilotStatusBloc()..add(PilotStatusInitialized()),
          ),
          BlocProvider<SocketIoBloc>(
            create: (context) => SocketIoBloc()..add(SocketIoInitialized()),
          ),
          BlocProvider<CurrentFlightBloc>(
            create: (context) =>
                CurrentFlightBloc()..add(CurrentFlightInitialized()),
          ),
          BlocProvider<MessageBloc>(
            create: (context) =>
                MessageBloc()..add(MessageLoaded(messages: const [])),
          ),
        ],
        child: MaterialApp(
          home: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
            return state.status == AuthStatus.connected ? const Home() : const LoginScreen();
          }),
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF0D003B),
            textTheme: TextTheme(
                displayLarge: GoogleFonts.prostoOne(
              color: const Color(0xFFDCA200),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            )),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDCA200),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 16),
                  // Couleur du texte blanc
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Coins arrondis de 4px
                  ),
                  padding: const EdgeInsets.all(14)),
            ),
            // ALTERNATIVE
            /*textTheme: GoogleFonts.prostoOneTextTheme(),*/
          ),
        ));
  }
}
