import 'package:flutter/material.dart';
import 'package:frontend/mobile/proposal/filter_view.dart';
import 'package:frontend/models/flight.dart';

class SearchFilterWidget extends StatefulWidget {
  final Function(double?) onMaxPriceChanged;
  final Function(int?) onMinSeatsChanged;
  final Function(Airport?) onDepartureLocationChanged;
  final Function(Airport?) onArrivalLocationChanged;
  final Function refreshProposals;
  final double? maxPrice;
  final int? minSeatsAvailable;
  final Airport? departureLocation;
  final Airport? arrivalLocation;
  final Function resetFilters;

  const SearchFilterWidget({
    super.key,
    required this.onMaxPriceChanged,
    required this.onMinSeatsChanged,
    required this.onDepartureLocationChanged,
    required this.onArrivalLocationChanged,
    required this.refreshProposals,
    required this.maxPrice,
    required this.minSeatsAvailable,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.resetFilters,
  });

  @override
  _SearchFilterWidgetState createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FilterView(
              onMaxPriceChanged: widget.onMaxPriceChanged,
              onMinSeatsChanged: widget.onMinSeatsChanged,
              onDepartureLocationChanged: widget.onDepartureLocationChanged,
              onArrivalLocationChanged: widget.onArrivalLocationChanged,
              refreshProposals: widget.refreshProposals,
              maxPrice: widget.maxPrice,
              minSeatsAvailable: widget.minSeatsAvailable,
              resetFilters: widget.resetFilters,
            ),
          ),
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
