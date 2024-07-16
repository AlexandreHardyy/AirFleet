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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          double modalHeight = MediaQuery.of(context).size.height * 0.7;
          return SizedBox(
            height: modalHeight,
            child: const FilterModal(),
          );
        },
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 2.0,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(Icons.filter_list),
              SizedBox(width: 8),
              Text('Filter Options'),
            ],
          ),
        ),
      ),
    );
  }
}
