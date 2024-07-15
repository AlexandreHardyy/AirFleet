import 'package:flutter/material.dart';
import 'package:frontend/models/module.dart';
import 'package:frontend/services/module.dart';

class ModuleScreen extends StatefulWidget {
  static const routeName = '/module';

  static Future<void> navigateTo(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  const ModuleScreen({super.key});

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  late Future<List<Module>> _modules;

  @override
  void initState() {
    super.initState();

    _modules = ModuleService.getModules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modules Management'),
      ),
      body: FutureBuilder<List<Module>>(
        future: _modules,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Module module = snapshot.data![index];
                return ListTile(
                  title: Text(module.name),
                  trailing: Switch(
                    value: module.isEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        module.isEnabled = value;
                      });

                      updateModule(module.id, value);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void fetchModules() async {
    setState(() {
      _modules = ModuleService.getModules();
    });
  }

  void updateModule(int moduleId, bool isEnabled) async {
    final UpdateModuleRequest request = UpdateModuleRequest(isEnabled: isEnabled);
    await ModuleService.updateModule(moduleId, request);
    fetchModules();
  }
}

