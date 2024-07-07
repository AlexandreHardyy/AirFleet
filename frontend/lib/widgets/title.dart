import 'package:flutter/material.dart';

class MainTitle extends StatelessWidget {
  final String content;
const MainTitle({ super.key, required this.content });

  @override
  Widget build(BuildContext context){
    return Text(
        content,
        style: const TextStyle(
          fontSize: 28, // Taille de la police
          fontWeight: FontWeight.bold, // Gras
          color: Colors.black, // Couleur du texte
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
          fontSize: 20, // Taille de la police
          fontWeight: FontWeight.w500, // Gras
          color: Colors.black, // Couleur du texte
        ));
  }
}