import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:frontend/routes.dart';
import 'package:frontend/services/user.dart';
import 'package:frontend/storage/user.dart';
import 'package:frontend/widgets/input.dart';
import 'package:frontend/widgets/title.dart';

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 54),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MainTitle(content: 'Login'),
              const SizedBox(height: 32),
              FormBuilderTextField(
                key: _emailFieldKey,
                name: 'email',
                decoration: getInputDecoration(hintText: 'Email'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
              ),
              const SizedBox(height: 32),
              FormBuilderTextField(
                name: 'password',
                decoration: getInputDecoration(hintText: 'Password'),
                obscureText: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              const SizedBox(height: 32),
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
