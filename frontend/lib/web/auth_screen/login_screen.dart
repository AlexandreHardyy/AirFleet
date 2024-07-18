// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:flutter_translate/flutter_translate.dart';
// import 'package:form_builder_validators/form_builder_validators.dart';
// import 'package:frontend/blocs/auth/auth_bloc.dart';
// import 'package:frontend/mobile/auth_screen/register_screen.dart';
// import 'package:frontend/services/user.dart';
// import 'package:frontend/storage/user.dart';
// import 'package:frontend/widgets/title.dart';
//
// class LoginScreen extends StatefulWidget {
//   static const routeName = '/login-web';
//
//   static Future<void> navigateTo(BuildContext context) {
//     return Navigator.of(context).pushNamed(routeName);
//   }
//
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormBuilderState>();
//   final _emailFieldKey = GlobalKey<FormBuilderState>();
//   var _apiMessage = "";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FormBuilder(
//         key: _formKey,
//         child: Column(
//           children: [
//             FormBuilderTextField(
//               key: _emailFieldKey,
//               name: "email",
//               decoration:
//                   InputDecoration(labelText: translate("web.login.email")),
//               validator: FormBuilderValidators.compose([
//                 FormBuilderValidators.required(),
//                 FormBuilderValidators.email(),
//               ]),
//             ),
//             const SizedBox(height: 10),
//             FormBuilderTextField(
//               name: "password",
//               decoration:
//                   InputDecoration(labelText: translate("web.login.password")),
//               obscureText: true,
//               validator: FormBuilderValidators.compose([
//                 FormBuilderValidators.required(),
//               ]),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 final state = _formKey.currentState;
//                 if (state == null) {
//                   return;
//                 }
//                 setState(() {
//                   _apiMessage = "";
//                 });
//
//                 state.saveAndValidate();
//
//                 state.validate();
//                 final formValues = state.instantValue;
//                 final result = await UserService.login(
//                     formValues['email'], formValues['password']);
//
//                 if (result['token'] != null) {
//                   await UserStore.setToken(result['token']);
//                 }
//
//                 setState(() {
//                   if (result['role'] != 'ROLE_ADMIN') {
//                     _apiMessage = translate("web.login.error.not_admin");
//                     return;
//                   }
//                   if (result['token'] != null) {
//                     _apiMessage = translate("web.login.success");
//                     Navigator.of(context).popUntil((route) => route.isFirst);
//                     context.read<AuthBloc>().add(AuthLogIn());
//                   } else if (result['message'] != null) {
//                     _apiMessage = result['message'];
//                   } else {
//                     _apiMessage = translate("web.login.error.unknown");
//                   }
//                 });
//               },
//               child: Text(translate("web.login.login")),
//             ),
//             Text(_apiMessage),
//             MaterialButton(
//               onPressed: () {
//                 RegisterScreen.navigateTo(context);
//               },
//               child: Text(translate("web.login.register")),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:frontend/blocs/auth/auth_bloc.dart';
import 'package:frontend/mobile/auth_screen/register_screen.dart';
import 'package:frontend/services/user.dart';
import 'package:frontend/storage/user.dart';
import 'package:frontend/widgets/title.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login-web';

  static Future<void> navigateTo(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Image.asset(
                    'assets/images/flight_path.png',
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0xFF131141),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo_without_bg.png',
                          width: screenWidth * 0.2,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          translate("web.login.title"),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          translate("web.login.subtitle"),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 32),
                        FormBuilder(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  key: _emailFieldKey,
                                  name: "email",
                                  decoration: InputDecoration(
                                    labelText: translate("web.login.email"),
                                    labelStyle:  const TextStyle(color: Color(0xFFDCA200)),
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0x00eeeeee)),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0x00eeeeee)),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFDCA200)),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                  ),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.email(),
                                  ]),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  name: "password",
                                  decoration: InputDecoration(
                                    labelText: translate("web.login.password"),
                                    labelStyle: const TextStyle(color: Color(0xFFDCA200)),
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0x00eeeeee)),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0x00eeeeee)),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFDCA200)),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                  ),
                                  obscureText: true,
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                  ]),
                                ),
                              ),
                              const SizedBox(height: 20),
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
                                      formValues['email'],
                                      formValues['password']);

                                  if (result['token'] != null) {
                                    await UserStore.setToken(result['token']);
                                  }

                                  setState(() {
                                    if (result['role'] != 'ROLE_ADMIN') {
                                      _apiMessage = translate(
                                          "web.login.error.not_admin");
                                      return;
                                    }
                                    if (result['token'] != null) {
                                      _apiMessage =
                                          translate("web.login.success");
                                      Navigator.of(context)
                                          .popUntil((route) => route.isFirst);
                                      context.read<AuthBloc>().add(AuthLogIn());
                                    } else if (result['message'] != null) {
                                      _apiMessage = result['message'];
                                    } else {
                                      _apiMessage =
                                          translate("web.login.error.unknown");
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  foregroundColor: const Color(0xFF131141),
                                  backgroundColor: const Color(0xFFDCA200)
                                ),
                                child: Text(translate("web.login.login")),
                              ),
                              Text(_apiMessage),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
