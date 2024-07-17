import 'package:flutter/material.dart';
import 'package:frontend/mobile/proposal/filter_modal.dart';

class SearchFilterWidget extends StatefulWidget {
  final Function(double?) onMaxPriceChanged;
  final Function(int?) onMinSeatsChanged;
  final Function refreshProposals;
  final double? maxPrice;
  final int? minSeatsAvailable;

  const SearchFilterWidget({
    super.key,
    required this.onMaxPriceChanged,
    required this.onMinSeatsChanged,
    required this.refreshProposals,
    required this.maxPrice,
    required this.minSeatsAvailable,
  });

  @override
  _SearchFilterWidgetState createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {

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
            child: FilterModal(
              onMaxPriceChanged: (price) => widget.onMaxPriceChanged(price),
              onMinSeatsChanged: (seats) => widget.onMinSeatsChanged(seats),
              refreshProposals: () => widget.refreshProposals(),
              maxPrice: widget.maxPrice,
              minSeatsAvailable: widget.minSeatsAvailable,
            ),
          );
        },
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 1.0,
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
