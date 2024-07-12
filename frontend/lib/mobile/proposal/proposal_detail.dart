import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/proposal.dart';
import 'package:frontend/services/proposal.dart';
import 'package:frontend/storage/user.dart';

class ProposalDetail extends StatefulWidget {
  final int proposalId;

  const ProposalDetail({super.key, required this.proposalId});

  @override
  _ProposalDetailState createState() => _ProposalDetailState();
}

class _ProposalDetailState extends State<ProposalDetail> {
  final bool _isPilot = UserStore.user?.role == Roles.pilot;
  bool _isUserInProposal = false;
  late Future<Proposal?> _proposal;

  @override
  void initState() {
    super.initState();
    _proposal = ProposalService.getProposalById(widget.proposalId);
  }

  void _joinProposal({required int id}) async {
    try {
      await ProposalService.joinProposal(id);
      final updatedProposal = await ProposalService.getProposalById(widget.proposalId);
      setState(() {
        _proposal = Future.value(updatedProposal);
        _isUserInProposal = true;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _leaveProposal({required int id}) async {
    try {
      await ProposalService.leaveProposal(id);
      final updatedProposal = await ProposalService.getProposalById(widget.proposalId);
      setState(() {
        _proposal = Future.value(updatedProposal);
        _isUserInProposal = false;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposal Detail'),
      ),
      body: FutureBuilder<Proposal?>(
        future: _proposal,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final proposal = snapshot.data!;
            _isUserInProposal = proposal.flight.users?.any((user) => user.id == UserStore.user?.id) ?? false;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Description: ${proposal.description}'),
                  Text('Departure Time: ${proposal.departureTime}'),
                  Text('Seats Available: ${proposal.availableSeats}'),
                  const SizedBox(height: 20),
                  if (_isPilot)
                    ElevatedButton(
                      onPressed: () async {
                        //await Navigator.of(context).push(Routes.editProposal(context, proposalId: proposal.id));
                      },
                      child: const Text('Edit Proposal'),
                    ),
                  if (_isPilot)
                  ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm'),
                            content: const Text(
                                'Are you sure you want to delete this proposal ?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Yes'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context)
                                        .pop(false),
                                child: const Text('No'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        try {
                          await ProposalService.deleteProposal(proposal.id);
                          Navigator.of(context).pop();
                        } on DioException catch (e) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Error: ${e.response?.data['message']}'),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Delete Proposal'),
                  ),
                  if (!_isUserInProposal && !_isPilot)
                    ElevatedButton(
                      onPressed: () => _joinProposal(id: proposal.id),
                      child: const Text('Join Flight'),
                    ),
                  if (_isUserInProposal && !_isPilot)
                    ElevatedButton(
                      onPressed: () => _leaveProposal(id: proposal.id),
                      child: const Text('Leave Flight'),
                    ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No proposal found'));
          }
        },
      ),
    );
  }
}