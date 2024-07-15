import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:frontend/mobile/auth_screen/login_screen.dart';
import 'package:frontend/mobile/auth_screen/register_pilot_screen.dart';
import 'package:frontend/services/user.dart';
import 'package:frontend/widgets/input.dart';
import 'package:frontend/widgets/title.dart';

class RegisterScreen extends StatefulWidget {
  static String routeName = '/register';

  static Future<void> navigateTo(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

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
        body: SingleChildScrollView(
            child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 54),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MainTitle(content: 'Register'),
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
            const SizedBox(height: 24),
            FormBuilderTextField(
              name: 'first_name',
              decoration: getInputDecoration(hintText: 'First Name'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            const SizedBox(height: 24),
            FormBuilderTextField(
              name: 'last_name',
              decoration: getInputDecoration(hintText: 'Last Name'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            const SizedBox(height: 24),
            FormBuilderTextField(
              name: 'password',
              decoration: getInputDecoration(hintText: 'Password'),
              obscureText: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            const SizedBox(height: 24),
            FormBuilderTextField(
              name: 'confirm_password',
              decoration: getInputDecoration(hintText: 'Confirm password'),
              obscureText: true,
              validator: (val) {
                if (val != _formKey.currentState?.fields['password']?.value) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              // : Theme.of(context).colorScheme.secondary,
              onPressed: () async {
                final state = _formKey.currentState;
                if (state == null) {
                  return;
                }
                state.saveAndValidate();

                final isValid = state.validate();
                if (!isValid) {
                  return;
                }
                final formValues = state.instantValue;
                final result = await UserService.register(
                    formValues['email'],
                    formValues['first_name'],
                    formValues['last_name'],
                    formValues['password']);

                setState(() {
                  if (result['message'] == null) {
                    _apiMessage = 'Register success !';
                    LoginScreen.navigateTo(context);
                  } else if (result['message'] != null) {
                    _apiMessage = result['message'];
                  } else {
                    _apiMessage = 'An error occurred';
                  }
                });
              },
              child: const Text('Register'),
            ),
            Text(_apiMessage),
            MaterialButton(
                onPressed: () {
                  LoginScreen.navigateTo(context);
                },
                child: const Text("already registered ? login here")),
            MaterialButton(
                onPressed: () {
                  RegisterPilotScreen.navigateTo(context);
                },
                child: const Text("register as a pilot here"))
          ],
        ),
      ),
    )));
  }
}
