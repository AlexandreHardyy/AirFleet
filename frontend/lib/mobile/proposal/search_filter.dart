import 'package:flutter/material.dart';
import 'package:frontend/mobile/proposal/filter_modal.dart';

class SearchFilterWidget extends StatefulWidget {
  const SearchFilterWidget({super.key});

  @override
  _SearchFilterWidgetState createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();

  // @override
  // Widget build(BuildContext context) {
  //   return Column(
  //     children: [
  //       TextField(
  //         controller: _departureController,
  //         decoration: const InputDecoration(labelText: 'Departure'),
  //       ),
  //       TextField(
  //         controller: _arrivalController,
  //         decoration: const InputDecoration(labelText: 'Arrival'),
  //       ),
  //       ElevatedButton(
  //         onPressed: () {  },
  //         child: const Text('Apply Filter'),
  //       ),
  //     ],
  //   );
  //}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>  showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => FilterModal(),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(Icons.filter_list),
            SizedBox(width: 8),
            Text('test → test'),
          ],
        ),
      ),
    );
  }
}