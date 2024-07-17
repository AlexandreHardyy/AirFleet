import 'package:flutter/material.dart';

ButtonStyle dangerButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.white,
  foregroundColor: const Color.fromARGB(255, 253, 70, 56),
  textStyle: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8.0),
    side: const BorderSide(color: Color.fromARGB(255, 253, 70, 56)),
  ),
  padding: const EdgeInsets.all(14),
);

