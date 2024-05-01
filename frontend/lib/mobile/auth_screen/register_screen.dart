import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:frontend/routes.dart';
import 'package:frontend/services/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _emailFieldKey = GlobalKey<FormBuilderState>();
  var _apiMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                FormBuilderTextField(
                  key: _emailFieldKey,
                  name: 'email',
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'first_name',
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'last_name',
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'password',
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                ElevatedButton(
                  // : Theme.of(context).colorScheme.secondary,
                  onPressed: () async {
                    final state = _formKey.currentState;
                    if (state == null) {
                      return;
                    }
                    state.saveAndValidate();

                    state.validate();
                    final formValues = state.instantValue;
                    final result = await UserService.register(
                        formValues['email'],
                        formValues['first_name'],
                        formValues['last_name'],
                        formValues['password']);

                    setState(() {
                      if (result['message'] == null) {
                        _apiMessage = 'Register success !';
                        Navigator.of(context).push(Routes.login(context));
                      } else if (result['message'] != null) {
                        _apiMessage = result['message'];
                      } else {
                        _apiMessage = 'An error occured';
                      }
                    });
                  },
                  child: const Text('Register'),
                ),
                Text(_apiMessage),
                MaterialButton(
                    onPressed: () {
                      Navigator.of(context).push(Routes.login(context));
                    },
                    child: const Text("already registered ? login here")),
                MaterialButton(
                    onPressed: () {
                      Navigator.of(context).push(Routes.registerPilot(context));
                    },
                    child: const Text("register as a pilot here"))
              ],
            ),
          ),
        )));
  }
}
