import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:frontend/routes.dart';
import 'package:frontend/services/user.dart';
import 'package:frontend/storage/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _emailFieldKey = GlobalKey<FormBuilderState>();
  var _apiMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
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
                name: 'password',
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              ElevatedButton(
                onPressed: () async {
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
                  final result = await UserService.login(
                      formValues['email'], formValues['password']);

                  if (result['token'] != null) {
                    await UserStore.setToken(result['token']);
                  }

                  setState(() {
                    if (result['token'] != null) {
                      _apiMessage = 'Login success !';
                      Navigator.of(context).popUntil((route) => false);
                      Navigator.of(context).push(Routes.home(context));
                    } else if (result['message'] != null) {
                      _apiMessage = result['message'];
                    } else {
                      _apiMessage = 'An error occurred';
                    }
                  });
                },
                child: const Text('Login'),
              ),
              Text(_apiMessage),
              MaterialButton(
                  onPressed: () {
                    Navigator.of(context).push(Routes.register(context));
                  },
                  child: const Text("no account yet ? register"))
            ],
          ),
        ),
      ),
    );
  }
}
