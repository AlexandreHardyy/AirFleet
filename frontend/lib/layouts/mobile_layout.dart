import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/auth_screen/login_screen.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/pilot_status/pilot_status_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/mobile/home/home.dart';
import 'package:frontend/storage/user.dart';
import 'package:google_fonts/google_fonts.dart';

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
            create: (context) =>  CurrentFlightBloc()..add(CurrentFlightInitialized()),
          ),
        ],
        child: MaterialApp(
          home: isAuth ? const Home() : const LoginScreen(),
          theme: ThemeData(
            textTheme: TextTheme(
                displayLarge: GoogleFonts.prostoOne(
              color: const Color(0xFFDCA200),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            )),
            // ALTERNATIVE
            /*textTheme: GoogleFonts.prostoOneTextTheme(),*/
          ),
        ));
  }
}
