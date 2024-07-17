import 'package:flutter/material.dart';
import 'package:frontend/mobile/proposal/proposal_detail.dart';
import 'package:frontend/mobile/proposal/search_filter.dart';
import 'package:frontend/models/proposal.dart';
import 'package:frontend/services/proposal.dart';
import 'package:intl/intl.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late Future<List<Proposal>> _proposalsFuture;
  double? maxPrice;
  int? minSeatsAvailable;

  @override
  void initState() {
    super.initState();
    _proposalsFuture = ProposalService.getProposals(maxPrice: maxPrice, minSeatsAvailable: minSeatsAvailable);
  }

  void refreshProposals() {
    setState(() {
      _proposalsFuture = ProposalService.getProposals(maxPrice: maxPrice, minSeatsAvailable: minSeatsAvailable);
    });
  }

  void onMaxPriceChanged(double? price) {
    setState(() {
      maxPrice = price;
    });
  }

  void onMinSeatsChanged(int? seats) {
    setState(() {
      minSeatsAvailable = seats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Proposal>>(
      future: _proposalsFuture,
      builder: (context, snapshot) {
        List<Widget> children = [
          Center(
            child: SearchFilterWidget(
              onMaxPriceChanged: onMaxPriceChanged,
              onMinSeatsChanged: onMinSeatsChanged,
              refreshProposals: refreshProposals,
              maxPrice: maxPrice ?? 0,
              minSeatsAvailable: minSeatsAvailable ?? 0,
            ),
          )
        ];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          children.add(
            Expanded(
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Proposal proposal = snapshot.data![index];
                  DateTime parsedDepartureTime = DateTime.parse(proposal.departureTime);
                  String formattedDepartureTime = DateFormat('dd/MM/yyyy HH:mm').format(parsedDepartureTime);
                  return Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(proposal.flight.departure.name,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(proposal.flight.arrival.name,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Divider(color: Colors.grey[400]), // Separator
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Departure Time: $formattedDepartureTime',
                                      style: const TextStyle(fontSize: 12)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        backgroundImage: AssetImage('assets/images/avatar.png'),
                                        radius: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('${proposal.flight.pilot?.firstName} ${proposal.flight.pilot?.lastName}',
                                          style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Seats available: ${proposal.flight.users?.length ?? 0} / ${proposal.availableSeats}',
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          await ProposalDetail.navigateTo(context, proposalId: proposal.id);
                          refreshProposals();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          children.add(const Center(child: Text('No proposals found')));
        }
        return Column(children: children);
      },
    );
  }
}
