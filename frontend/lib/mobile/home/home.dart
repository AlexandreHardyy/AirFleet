import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
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
      child:
          BlocBuilder<SocketIoBloc, SocketIoState>(builder: (context, state) {
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
            drawer: const HomeDrawer(),
            floatingActionButton: Builder(builder: (context) {
              return FloatingActionButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                shape: const CircleBorder(),
                backgroundColor: const Color(0xFF131141),
                child: Icon(
                  UserStore.user?.role == Roles.pilot
                      ? FontAwesomeIcons.userTie
                      : Icons.person,
                  color: const Color(0xFFDCA200),
                ),
              );
            }),
            floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * (2 / 3),
                  child: const AirFleetMap(),
                ),
                const FlightsManagement()
              ],
            ));
      }),
    );
  }
}
