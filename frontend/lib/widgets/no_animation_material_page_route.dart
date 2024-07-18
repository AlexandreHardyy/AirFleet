// import 'package:flutter/material.dart';
//
// class NoAnimationPageRoute extends PageRouteBuilder {
//   final Widget page;
//
//   NoAnimationPageRoute({required this.page})
//       : super(
//     pageBuilder: (context, animation, secondaryAnimation) => page,
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       return child;
//     },
//   );
// }
import 'package:flutter/material.dart';

class NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationMaterialPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
