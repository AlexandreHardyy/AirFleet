import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/mobile/home/flights_management/pilot_flight_management/pilot_flights_management.dart';
import 'package:frontend/mobile/map/map.dart';
import 'package:frontend/storage/user.dart';
import 'flights_management/flights_management.dart';
import 'home_drawer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<CurrentFlightBloc>(
              create: (context) =>
                  CurrentFlightBloc()..add(CurrentFlightInitialized()),
            ),
            BlocProvider<SocketIoBloc>(
              create: (context) => SocketIoBloc()..add(SocketIoInitialized()),
            ),
          ],
          child: BlocBuilder<SocketIoBloc, SocketIoState>(
              builder: (context, state) {
            if (state.status == SocketIoStatus.error) {
              return Scaffold(
                body: Center(
                  child: Text(state.errorMessage!),
                ),
              );
            }

            if (state.status == SocketIoStatus.loading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return Scaffold(
                backgroundColor: const Color(0xFF131141),
                drawer: const HomeDrawer(),
                //ALTERNATIVE
                // floatingActionButton: Builder(
                //   builder: (context) {
                //     return FloatingActionButton(
                //       onPressed: () => Scaffold.of(context).openDrawer(),
                //       shape: const CircleBorder(),
                //       child: const Icon(FontAwesomeIcons.user),
                //     );
                //   }
                // ),
                // floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  leading: Builder(builder: (context) {
                    return IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const CircleAvatar(
                        backgroundColor: Color(0xFF131141),
                        child: Icon(
                          FontAwesomeIcons.user,
                          color: Color(0xFFDCA200),
                        ),
                      ),
                    );
                  }),
                ),
                body: Stack(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * (2 / 3),
                      child: const AirFleetMap(),
                    ),
                    UserStore.user?.role == Roles.pilot ? const PilotFlightsManagement() : const FlightsManagement()
                  ],
                ));
          }),
        ));
  }
}
