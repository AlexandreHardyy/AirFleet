import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/web/user/user.dart';
import 'package:frontend/web/vehicle/vehicle.dart';
import 'package:frontend/web/flights/flight.dart';
import 'package:frontend/web/monitoring-logs/index.dart';
import 'package:frontend/web/module/module.dart';
import 'package:frontend/services/user.dart';

class NavigationWeb extends StatelessWidget {
  const NavigationWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: const Color(0xFF131141),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Admin Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(FontAwesomeIcons.chartLine, color: Color(0xFFDCA200)),
                  title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.of(context).pushNamed('/');
                  },
                ),
                ListTile(
                  leading: const Icon(FontAwesomeIcons.userTie,
                      color: Color(0xFFDCA200)),
                  title: const Text('Users',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    UserScreen.navigateTo(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.airplanemode_active,
                      color: Color(0xFFDCA200)),
                  title: const Text('Vehicles',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    VehicleScreen.navigateTo(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.airplane_ticket,
                      color: Color(0xFFDCA200)),
                  title: const Text('Flights',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    FlightsWebScreen.navigateTo(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.insert_chart_sharp,
                      color: Color(0xFFDCA200)),
                  title: const Text('Monitoring logs',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    MonitoringLogScreen.navigate(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dashboard,
                      color: Color(0xFFDCA200)),
                  title: const Text('Modules',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    ModuleScreen.navigateTo(context);
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFDCA200)),
            title: const Text('Logout', style: TextStyle(color: Colors.white)),
            onTap: () async {
              await UserService.logOut(context);
            },
          ),
        ],
      ),
    );
  }
}