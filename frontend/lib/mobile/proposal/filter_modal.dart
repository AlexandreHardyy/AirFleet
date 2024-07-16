import 'package:flutter/material.dart';

class FilterModal extends StatelessWidget {
  const FilterModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        AppBar(
          title: const Text('Filter Options'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Departure',
              hintText: 'Enter departure location',
            ),
          ),
        ),
      ],
    );
  }
}