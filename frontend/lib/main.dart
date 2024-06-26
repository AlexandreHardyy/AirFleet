import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/blocs/auth/auth_bloc.dart';
import 'package:frontend/layouts/mobile_layout.dart';
import 'package:frontend/layouts/web_layout.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'local_notification_setup.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: ".env");

  final String mapboxAccessToken =
      const String.fromEnvironment("PUBLIC_ACCESS_TOKEN") != ""
          ? const String.fromEnvironment("PUBLIC_ACCESS_TOKEN")
          : dotenv.get("PUBLIC_ACCESS_TOKEN_MAPBOX");

  MapboxOptions.setAccessToken(mapboxAccessToken);

  await Future.delayed(const Duration(seconds: 3));

  FlutterNativeSplash.remove();

  await LocalNotificationService().init();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => AuthBloc()..add(AuthInitialized()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.status == AuthStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return kIsWeb ? const WebLayout() : const MobileLayout();
        },
      ),
    );
  }
}
