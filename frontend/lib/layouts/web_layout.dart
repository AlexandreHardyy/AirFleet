import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/blocs/auth/auth_bloc.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/web/auth_screen/login_screen.dart';
import 'package:frontend/web/flights/flight.dart';
import 'package:frontend/web/flights/flight_details.dart';
import 'package:frontend/web/home_web.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/web/module/module.dart';
import 'package:frontend/web/monitoring-logs/index.dart';
import 'package:frontend/web/user/user.dart';
import 'package:frontend/web/vehicle/vehicle.dart';

class WebLayout extends StatelessWidget {
  const WebLayout({super.key});

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: MaterialApp(
        routes: {
          '/home-web': (context) => const HomeWeb(),
          '/user': (context) => const UserScreen(),
          '/vehicle': (context) => const VehicleScreen(),
          '/flight': (context) => const FlightsWebScreen(),
          '/module': (context) => const ModuleScreen(),
          '/monitoring-logs': (context) => const MonitoringLogScreen(),
        },
        onGenerateRoute: (settings) {
          final args = settings.arguments;
          switch (settings.name) {
            case FlightDetailsScreen.routeName:
              return MaterialPageRoute(
                builder: (context) => FlightDetailsScreen(
                  flight: args as Flight,
                ),
              );
          }
          return null;
        },
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          localizationDelegate
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
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
      ),
    );
  }
}

// class WebLayout extends StatelessWidget {
//   const WebLayout({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     var localizationDelegate = LocalizedApp.of(context).delegate;
//
//     return LocalizationProvider(
//       state: LocalizationProvider.of(context).state,
//       child: MaterialApp(
//         routes: {
//           '/home-web': (context) => const HomeWeb(),
//           '/user': (context) => const UserScreen(),
//           '/vehicle': (context) => const VehicleScreen(),
//           '/flight': (context) => const FlightsWebScreen(),
//           '/module': (context) => const ModuleScreen(),
//           '/monitoring-logs': (context) => const MonitoringLogScreen(),
//         },
//         onGenerateRoute: (settings) {
//           WidgetBuilder builder;
//           switch (settings.name) {
//             case FlightDetailsScreen.routeName:
//               builder = (context) => FlightDetailsScreen(
//                 flight: settings.arguments as Flight,
//               );
//               break;
//             case '/home-web':
//               builder = (context) => const HomeWeb();
//               break;
//             case '/user':
//               builder = (context) => const UserScreen();
//               break;
//             case '/vehicle':
//               builder = (context) => const VehicleScreen();
//               break;
//             case '/flight':
//               builder = (context) => const FlightsWebScreen();
//               break;
//             case '/module':
//               builder = (context) => const ModuleScreen();
//               break;
//             case '/monitoring-logs':
//               builder = (context) => const MonitoringLogScreen();
//               break;
//             default:
//               throw Exception('Invalid route: ${settings.name}');
//           }
//           return PageRouteBuilder(
//             pageBuilder: (context, animation, secondaryAnimation) => builder(context),
//             transitionDuration: Duration.zero,
//             reverseTransitionDuration: Duration.zero,
//           );
//         },
//         localizationsDelegates: [
//           GlobalMaterialLocalizations.delegate,
//           GlobalCupertinoLocalizations.delegate,
//           GlobalWidgetsLocalizations.delegate,
//           localizationDelegate
//         ],
//         supportedLocales: localizationDelegate.supportedLocales,
//         locale: localizationDelegate.currentLocale,
//         home: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
//           return state.status == AuthStatus.connected
//               ? const HomeWeb()
//               : const LoginScreen();
//         }),
//         theme: ThemeData(
//           textTheme: const TextTheme(
//             bodyLarge: TextStyle(color: Color(0xFF131141)),
//             bodyMedium: TextStyle(color: Color(0xFF131141)),
//           ),
//           iconTheme: const IconThemeData(
//             color: Color(0xFFDCA200),
//           ),
//           appBarTheme: const AppBarTheme(
//             backgroundColor: Colors.white,
//             iconTheme: IconThemeData(color: Color(0xFFDCA200)),
//             titleTextStyle: TextStyle(color: Color(0xFF131141), fontSize: 20),
//             toolbarTextStyle: TextStyle(color: Color(0xFF131141)),
//           ),
//         ),
//       ),
//     );
//   }
// }