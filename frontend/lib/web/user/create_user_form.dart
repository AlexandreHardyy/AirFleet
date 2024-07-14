import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:frontend/services/user.dart';

class CreateUserForm extends StatefulWidget {
  const CreateUserForm({super.key});

  @override
  State<CreateUserForm> createState() => _CreateUserFormState();
}

class _CreateUserFormState extends State<CreateUserForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  var _apiMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create user'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(labelText: 'Email'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email()
                ]),
              ),
              FormBuilderTextField(
                  name: 'firstName',
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: FormBuilderValidators.required()),
              FormBuilderTextField(
                  name: 'lastName',
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: FormBuilderValidators.required()),
              FormBuilderTextField(
                name: 'password',
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(8),
                ]),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final state = _formKey.currentState;
                  if (state == null) {
                    return;
                  }
                  setState(() {
                    _apiMessage = "";
                  });

                  if (state.saveAndValidate()) {
                    state.validate();
                    final formValues = state.instantValue;
                    final response = await UserService.createUser({
                      'email': formValues['email'],
                      'first_name': formValues['firstName'],
                      'last_name': formValues['lastName'],
                      'password': formValues['password'],
                    });

                    setState(() {
                      if (response.statusCode == 201) {
                        _apiMessage = 'user created successfully!';
                      } else {
                        _apiMessage = 'An error occurred';
                      }
                    });
                  }
                },
                child: const Text('Create user'),
              ),
              Text(_apiMessage)
            ],
          ),
        ),
      ),
    );
  }
}
