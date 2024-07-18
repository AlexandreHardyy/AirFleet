import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/user.dart';
import 'package:frontend/storage/user.dart';
import 'package:frontend/web/user/files_pilot.dart';
import 'package:frontend/widgets/navigation_web.dart';
import 'package:frontend/widgets/title.dart';

class UpdateUserForm extends StatefulWidget {
  final User user;

  const UpdateUserForm({super.key, required this.user});

  @override
  _UpdateUserFormState createState() => _UpdateUserFormState();
}

class _UpdateUserFormState extends State<UpdateUserForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  var _apiMessage = "";

  @override
  void initState() {
    super.initState();
  }

  Future<void> _updateUser() async {
    final state = _formKey.currentState;
    if (state == null) {
      return;
    }
    setState(() {
      _apiMessage = "";
    });

    state.saveAndValidate();

    state.validate();
    final formValues = state.instantValue;

    final result = await UserService.update(widget.user.id, formValues);

    setState(() {
      if (result['message'] != null) {
        _apiMessage = result['message'];
      } else {
        _apiMessage = 'An error occurred';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const NavigationWeb(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const MainTitle(content: 'Update user'),
                  FormBuilder(
                    key: _formKey,
                    child: Column(
                      children: [
                        FormBuilderTextField(
                          name: 'email',
                          initialValue: widget.user.email,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.email(),
                          ]),
                        ),
                        const SizedBox(height: 10),
                        FormBuilderTextField(
                          name: 'first_name',
                          initialValue: widget.user.firstName,
                          decoration:
                          const InputDecoration(labelText: 'First Name'),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        const SizedBox(height: 10),
                        FormBuilderTextField(
                          name: 'last_name',
                          initialValue: widget.user.lastName,
                          decoration: const InputDecoration(labelText: 'Last Name'),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        FormBuilderDropdown(
                          name: "role",
                          initialValue: widget.user.role,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                          items: [Roles.pilot, Roles.user]
                              .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ))
                              .toList(),
                        ),
                        FormBuilderCheckbox(
                          title: const Text("is verified"),
                          name: "is_verified",
                          initialValue: widget.user.isVerified,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        widget.user.role == Roles.pilot
                            ? FormBuilderCheckbox(
                          title: const Text("is pilot verified"),
                          name: "is_pilot_verified",
                          initialValue: widget.user.isPilotVerified,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        )
                            : const Text(''),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _updateUser,
                          child: const Text('Update user'),
                        ),
                        const SizedBox(height: 10),
                        Text(_apiMessage)
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  FilesPilot(user: widget.user)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}