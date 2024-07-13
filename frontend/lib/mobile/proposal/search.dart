import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/proposal.dart';
import 'package:frontend/routes.dart';
import 'package:frontend/services/proposal.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late Future<List<Proposal>> _proposalsFuture;

  @override
  void initState() {
    super.initState();
    _proposalsFuture = ProposalService.getProposals();
  }

  void refreshProposals() {
    setState(() {
      _proposalsFuture = ProposalService.getProposals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Proposal>>(
      future: _proposalsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Proposal proposal = snapshot.data![index];
              DateTime parsedDepartureTime = DateTime.parse(proposal.departureTime);
              String formattedDepartureTime = DateFormat('dd/MM/yyyy HH:mm').format(parsedDepartureTime);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.grey[200],
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: proposal.flight.departure.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const TextSpan(text: ' → '),
                                TextSpan(text: proposal.flight.arrival.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text('Departure: $formattedDepartureTime', style: const TextStyle(fontSize: 12)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundImage: AssetImage('assets/images/avatar.png'),
                                radius: 16,
                              ),
                              const SizedBox(width: 8),
                              Text('${proposal.flight.pilot?.firstName} ${proposal.flight.pilot?.lastName}'),
                            ],
                          ),
                        ),
                        Text('Seats available: ${proposal.flight.users?.length ?? 0} / ${proposal.availableSeats}'),
                      ],
                    ),
                    onTap: () async {
                      await Navigator.of(context).push(Routes.proposalDetail(context, proposalId: proposal.id));
                      refreshProposals();
                    },
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No proposals found'));
        }
      },
    );
  }
}