import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:frontend/routes.dart';
import 'package:frontend/services/user.dart';
import 'package:frontend/widgets/input.dart';
import 'package:frontend/widgets/title.dart';

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
            const SizedBox(height: 32),
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
                    _apiMessage = 'An error occurred';
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
