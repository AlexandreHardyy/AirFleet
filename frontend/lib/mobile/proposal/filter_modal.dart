import 'package:flutter/material.dart';

class FilterModal extends StatelessWidget {
  final Function(double?) onMaxPriceChanged;
  final Function(int?) onMinSeatsChanged;
  final Function refreshProposals;
  final double? maxPrice;
  final int? minSeatsAvailable;

  final TextEditingController maxPriceController;
  final TextEditingController minSeatsAvailableController;

  FilterModal({
    super.key,
    required this.onMaxPriceChanged,
    required this.onMinSeatsChanged,
    required this.refreshProposals,
    required this.maxPrice,
    required this.minSeatsAvailable,
  })  : maxPriceController = TextEditingController(text: maxPrice.toString()),
        minSeatsAvailableController = TextEditingController(text: minSeatsAvailable.toString());

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
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: maxPriceController,
                decoration: InputDecoration(
                  labelText: 'Maximum Price',
                  hintText: 'Enter maximum price',
                  prefixIcon: Icon(Icons.monetization_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => onMaxPriceChanged(double.tryParse(value)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: minSeatsAvailableController,
                decoration: InputDecoration(
                  labelText: 'Minimum Seats Available',
                  hintText: 'Enter minimum seats available',
                  prefixIcon: Icon(Icons.event_seat),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => onMinSeatsChanged(int.tryParse(value)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  refreshProposals();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}