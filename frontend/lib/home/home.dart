import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/home/flights_management/flights_management.dart';

import '../map/map.dart';
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
                      child: Icon(FontAwesomeIcons.user),
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
    );
  }
}