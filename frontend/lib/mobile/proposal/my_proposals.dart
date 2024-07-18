import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
          return RefreshIndicator(
            onRefresh: () async {
              refreshProposals();
            },
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
          );
        } else {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/plane.svg',
                    semanticsLabel: 'Plane icon',
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'You are not part of any proposal',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}


