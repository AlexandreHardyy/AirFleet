import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:frontend/mobile/auth_screen/login_screen.dart';
import 'package:frontend/mobile/auth_screen/register_screen.dart';
import 'package:frontend/services/user.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:frontend/utils/file-permission.dart';
import 'package:frontend/widgets/input.dart';
import 'package:frontend/widgets/title.dart';

class RegisterPilotScreen extends StatefulWidget {
  static const routeName = '/register-pilot';

  static Future<void> navigateTo(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  const RegisterPilotScreen({super.key});
  @override
  State<RegisterPilotScreen> createState() => _RegisterPilotScreenState();
}

class _RegisterPilotScreenState extends State<RegisterPilotScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _emailFieldKey = GlobalKey<FormBuilderState>();
  var _apiMessage = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) async => requestPhotosPermission());
  }

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
              const MainTitle(content: 'Register as pilot'),
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
              const SizedBox(height: 24),
              FormBuilderFilePicker(
                name: "id_card",
                decoration: getInputDecoration(hintText: 'Card ID'),
                maxFiles: 1,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                previewImages: true,
                typeSelectors: const [
                  TypeSelector(
                    type: FileType.any,
                    selector: Row(
                      children: <Widget>[
                        Icon(Icons.add_circle),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text("Add your ID"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              FormBuilderFilePicker(
                name: "driving_licence",
                decoration: getInputDecoration(hintText: 'Pilot license'),
                maxFiles: 1,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                previewImages: true,
                typeSelectors: const [
                  TypeSelector(
                    type: FileType.any,
                    selector: Row(
                      children: <Widget>[
                        Icon(Icons.add_circle),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text("Add your licence"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                // : Theme.of(context).colorScheme.secondary,
                onPressed: () async {
                  final state = _formKey.currentState;
                  if (state == null) {
                    return;
                  }
                  setState(() {
                    _apiMessage = '';
                  });
                  state.saveAndValidate();

                  final isValid = state.validate();
                  if (!isValid) {
                    return;
                  }
                  
                  final formValues = state.instantValue;

                  final result = await UserService.registerPilot(
                    formValues['email'],
                    formValues['first_name'],
                    formValues['last_name'],
                    formValues['password'],
                    formValues['id_card'][0].path,
                    formValues['driving_licence'][0].path,
                  );

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
                    RegisterScreen.navigateTo(context);
                  },
                  child: const Text("normal register here"))
            ],
          ),
        ),
      ),
    ));
  }
}
