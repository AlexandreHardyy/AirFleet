import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/user.dart';
import 'package:frontend/web/user/create_user_form.dart';
import 'package:frontend/web/user/update_user_form.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      _users = await UserService.getUsers();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> _editUser(User user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateUserForm(user: user)),
    );

    if (result == true) {
      _fetchUsers();
    }
  }

  void _deleteUser(int id) async {
    try {
      await UserService.delete(id);
      _fetchUsers();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateUserForm()),
                );
              },
              child: const Text('Create a new User'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: DataTable(
                          columnSpacing: 0,
                          columns: const [
                            DataColumn(label: Text('First Name', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Last Name', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: _users.map((user) {
                            return DataRow(
                              cells: [
                                DataCell(Text(user.firstName)),
                                DataCell(Text(user.lastName)),
                                DataCell(Text(user.email)),
                                DataCell(Text(user.role)),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Color(0xFFDCA200)),
                                        onPressed: () => _editUser(user),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Color(0xFFDCA200)),
                                        onPressed: () => _deleteUser(user.id),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
