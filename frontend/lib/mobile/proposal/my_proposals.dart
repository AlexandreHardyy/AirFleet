import 'package:flutter/material.dart';
import 'package:frontend/models/proposal.dart';
import 'package:frontend/routes.dart';
import 'package:frontend/services/proposal.dart';

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
        print(snapshot.connectionState);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Proposal proposal = snapshot.data![index];
              return ListTile(
                title: Text(proposal.description),
                subtitle: Text('Departure: ${proposal.departureTime} - Seats: ${proposal.availableSeats}'),
                onTap: () async {
                  await Navigator.of(context).push(Routes.proposalDetail(context, proposalId: proposal.id));
                  refreshProposals();
                },
              );
            },
          );
        } else {
          return const Center(child: Text('Your are not part of any proposal'));
        }
      },
    );
  }
}


