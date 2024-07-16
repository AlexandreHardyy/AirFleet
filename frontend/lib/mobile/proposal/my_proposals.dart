import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/mobile/proposal/proposal_detail.dart';
import 'package:frontend/models/proposal.dart';
import 'package:frontend/services/proposal.dart';
import 'package:intl/intl.dart';

class MyProposalView extends StatefulWidget {
  const MyProposalView({super.key});

  @override
  _MyProposalViewState createState() => _MyProposalViewState();
}

class _MyProposalViewState extends State<MyProposalView> {
  late Future<List<Proposal>> _proposalsFuture;

  @override
  void initState() {
    super.initState();
    _proposalsFuture = ProposalService.getProposalsForMe();
  }

  void refreshProposals() {
    setState(() {
      _proposalsFuture = ProposalService.getProposalsForMe();
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
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
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
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text('${translate('common.departure')}: $formattedDepartureTime', style: const TextStyle(fontSize: 12)),
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
          );
        } else {
          return const Center(child: Text('You are not part of any proposal'));
        }
      },
    );
  }
}


