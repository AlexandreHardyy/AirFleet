import 'package:flutter/material.dart';

class InfoBox extends StatelessWidget {
  final String content;

  const InfoBox({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    if (content == "") {
      return SizedBox();
    }
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color.fromARGB(255, 4, 34, 78),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Color.fromARGB(255, 4, 34, 78),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16.0,
                color: Color.fromARGB(255, 4, 34, 78),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
