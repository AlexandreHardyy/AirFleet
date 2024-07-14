import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FilterModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        children: [
          AppBar(
            title: const Text('Filter Options'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Your filter options here
        ],
      ),
    );
  }
}