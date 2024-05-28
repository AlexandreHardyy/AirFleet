import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/mobile/map/map.dart';
import 'package:frontend/services/socketio.dart';
import 'package:frontend/storage/user.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'blocs/current_flight_bloc.dart';
import 'flights_management/flights_management.dart';
import 'home_drawer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late IO.Socket _socket;

  @override
  void initState() {
    super.initState();

    initSocket().then((socket) {
      setState(() {
        _socket = socket;
      });
    });
  }

  Future<IO.Socket> initSocket() async {
    final bearerToken = await UserStore.getToken();
    final socket = IO.io('http://localhost:3001/flights', IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .disableAutoConnect()
        .setExtraHeaders({'Bearer': bearerToken})
        .build()
    );
    socket.onConnect((_) {
      print('Connection established');
    });
    socket.onDisconnect((_) => print('Connection Disconnection'));
    socket.onConnectError((err) => print(err));
    socket.onError((err) => print(err));

    return socket;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SocketProvider(socket: _socket, child: BlocProvider(
        create: (context) => CurrentFlightBloc()..add(CurrentFlightInitialized()),
        child: Scaffold(
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
              leading: Builder(
                  builder: (context) {
                    return IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const CircleAvatar(
                        backgroundColor: Color(0xFF131141),
                        child: Icon(
                            FontAwesomeIcons.user,
                            color: Color(0xFFDCA200)
                        ),
                      ),
                    );
                  }
              ),
            ),
            body: Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * (2/3),
                  child: const AirFleetMap(),
                ),
                const FlightsManagement()
              ],
            )
        ),
      ))
    );
  }
}