import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:frontend/services/user.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';

class RegisterPilotScreen extends StatefulWidget {
  const RegisterPilotScreen({super.key});
  @override
  _RegisterPilotScreenState createState() => _RegisterPilotScreenState();
}

class _RegisterPilotScreenState extends State<RegisterPilotScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _emailFieldKey = GlobalKey<FormBuilderState>();
  var _apiMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Register Pilot'),
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
                  FormBuilderFilePicker(
                      name: "id_card",
                      decoration: InputDecoration(labelText: "card ID"),
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
                      ]),
                  FormBuilderFilePicker(
                      name: "driving_licence",
                      decoration: InputDecoration(labelText: "driving licence"),
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
                      ]),
                  MaterialButton(
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

                      state.validate();
                      final formValues = state.instantValue;

                      final result = await UserService().registerPilot(
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
                        } else if (result['message'] != null) {
                          _apiMessage = result['message'];
                        } else {
                          _apiMessage = 'An error occured';
                        }
                      });
                    },
                    child: const Text('Register'),
                  ),
                  Text(_apiMessage)
                ],
              ),
            ),
          ),
        ));
  }
}
