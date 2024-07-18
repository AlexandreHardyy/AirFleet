import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/web/user/user.dart';
import 'package:frontend/web/vehicle/vehicle.dart';
import 'package:frontend/web/flights/flight.dart';
import 'package:frontend/web/monitoring-logs/index.dart';
import 'package:frontend/services/user.dart';
import 'package:frontend/services/module.dart';
import 'package:frontend/models/module.dart';

class NavigationWeb extends StatefulWidget {
  const NavigationWeb({super.key});

  @override
  _NavigationWebState createState() => _NavigationWebState();
}

class _NavigationWebState extends State<NavigationWeb> {
  Future<List<Module>>? _modules;

  @override
  void initState() {
    super.initState();
    _fetchModules();
  }

  Future<void> _fetchModules() async {
    _modules = ModuleService.getModules();
  }

  Future<void> _showModulesDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<Module>>(
          future: _modules,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(translate("web.modules.title")),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      snapshot.data!.sort((a, b) => a.id.compareTo(b.id));
                      Module module = snapshot.data![index];
                      return ListTile(
                        title: Text(module.name),
                        trailing: Switch(
                          value: module.isEnabled,
                          onChanged: (bool value) {
                            setState(() {
                              module.isEnabled = value;
                            });
                            _updateModule(module.id, value);
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  void _updateModule(int moduleId, bool isEnabled) async {
    final UpdateModuleRequest request = UpdateModuleRequest(isEnabled: isEnabled);
    await ModuleService.updateModule(moduleId, request);
    _fetchModules();
    Navigator.of(context).pop();
    _showModulesDialog();
  }

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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    translate("web.navigation.title"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.chartLine,
                    color: Color(
                      0xFFDCA200,
                    ),
                  ),
                  title: Text(
                    translate("web.navigation.dashboard"),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/');
                  },
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.userTie,
                    color: Color(0xFFDCA200),
                  ),
                  title: Text(
                    translate("web.navigation.users"),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    UserScreen.navigateTo(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.airplanemode_active,
                    color: Color(0xFFDCA200),
                  ),
                  title: Text(
                    translate("web.navigation.vehicles"),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    VehicleScreen.navigateTo(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.airplane_ticket,
                    color: Color(0xFFDCA200),
                  ),
                  title: Text(
                    translate("web.navigation.flights"),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    FlightsWebScreen.navigateTo(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.insert_chart_sharp,
                    color: Color(0xFFDCA200),
                  ),
                  title: Text(
                    translate("web.navigation.monitoringLogs"),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    MonitoringLogScreen.navigate(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.dashboard,
                    color: Color(0xFFDCA200),
                  ),
                  title: Text(
                    translate("web.navigation.modules"),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    _showModulesDialog();
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Color(0xFFDCA200),
            ),
            title: Text(
              translate("web.navigation.logout"),
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () async {
              await UserService.logOut(context);
            },
          ),
        ],
      ),
    );
  }
}
