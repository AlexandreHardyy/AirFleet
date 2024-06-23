import 'package:flutter/material.dart';

getInputDecoration({required hintText}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.grey.shade400),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: Colors.grey.shade300,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(
        color:  Color(0xFFDCA200),
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: Colors.grey.shade300,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
  );
}
