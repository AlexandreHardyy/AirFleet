import 'package:flutter/material.dart';

class MainTitle extends StatelessWidget {
  final String content;
const MainTitle({ super.key, required this.content });

  @override
  Widget build(BuildContext context){
    return Text(
        content,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ));
  }
}

class SecondaryTitle extends StatelessWidget {
  final String content;
const SecondaryTitle({ super.key, required this.content });

  @override
  Widget build(BuildContext context){
    return Text(
        content,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ));
  }
}