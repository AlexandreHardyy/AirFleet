import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/blocs/auth/auth_bloc.dart';
import 'package:frontend/global_key.dart';
import 'package:frontend/mobile/auth_screen/login_screen.dart';
import 'package:frontend/mobile/auth_screen/register_screen.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/message/message_bloc.dart';
import 'package:frontend/mobile/blocs/pilot_status/pilot_status_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/mobile/flight_chat.dart';
import 'package:frontend/mobile/flight_details.dart';
import 'package:frontend/mobile/home/home.dart';
import 'package:frontend/mobile/pilot_flight_request_detail.dart';
import 'package:frontend/mobile/profile/user_profile.dart';
import 'package:frontend/mobile/profile/user_vehicles.dart';
import 'package:frontend/mobile/proposal/proposal_detail.dart';
import 'package:frontend/mobile/proposal/proposals_management.dart';
import 'package:frontend/mobile/vehicle_detail.dart';
import 'package:frontend/mobile/vehicles_management.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;

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
        child: LocalizationProvider(
          state: LocalizationProvider.of(context).state,
          child: MaterialApp(
            routes: {
              '/home': (context) => const Home(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/register-pilot': (context) => const RegisterScreen(),
              '/profile': (context) => const UserProfileScreen(),
              '/vehicles-management': (context) => const VehiclesManagementScreen(),
              '/proposals-management': (context) => const ProposalsManagementScreen(),
            },
            onGenerateRoute: (settings) {
              final args = settings.arguments;
              switch (settings.name) {
                case UserVehiclesScreen.routeName:
                  return MaterialPageRoute(
                    builder: (context) {
                      return UserVehiclesScreen(vehicles: args as List<Vehicle>);
                    },
                  );
                case FlightRequestDetail.routeName:
                  return MaterialPageRoute(
                    builder: (context) {
                      return FlightRequestDetail(flight: args as Flight);
                    },
                  );
                case VehicleDetailsPage.routeName:
                  return MaterialPageRoute(
                    builder: (context) {
                      return VehicleDetailsPage(vehicleId: args as int);
                    },
                  );
                case FlightChat.routeName:
                  return MaterialPageRoute(
                    builder: (context) {
                      return FlightChat(flightId: args as int);
                    },
                  );
                case FlightDetails.routeName:
                  return MaterialPageRoute(
                    builder: (context) {
                      return FlightDetails(flightId: args as int);
                    },
                  );
                case ProposalDetail.routeName:
                  return MaterialPageRoute(
                    builder: (context) {
                      return ProposalDetail(proposalId: args as int);
                    },
                  );
              }
            },
            navigatorKey: navigatorKey,
            supportedLocales: localizationDelegate.supportedLocales,
            locale: localizationDelegate.currentLocale,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              localizationDelegate
            ],
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
          ),
        ));
  }
}
