import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/models/proposal.dart';
import 'package:frontend/services/proposal.dart';
import 'package:frontend/storage/user.dart';
import 'package:intl/intl.dart';

class ProposalDetail extends StatefulWidget {
  static const routeName = '/proposal-detail';

  static Future<void> navigateTo(BuildContext context, {required int proposalId}) {
    return Navigator.of(context).pushNamed(routeName, arguments: proposalId);
  }

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

  bool isDepartureWithinOneHour(DateTime departureTime) {
    final currentTime = DateTime.now().toUtc();
    final difference = departureTime.difference(currentTime).inMinutes;
    return difference < 60;
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
            DateTime parsedDepartureTime = DateTime.parse(proposal.departureTime);
            String formattedDepartureTime = DateFormat('dd/MM/yyyy HH:mm').format(parsedDepartureTime);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          proposal.flight.departure.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formattedDepartureTime,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const Icon(Icons.arrow_downward),
                        Text(
                          proposal.flight.arrival.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          const CircleAvatar(
                            backgroundImage: AssetImage('assets/images/default_profile.png'),
                          ),
                          const SizedBox(width: 10), // Add some spacing between the image and the text
                          Text('${proposal.flight.pilot?.firstName} ${proposal.flight.pilot?.lastName}',
                              style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(proposal.description, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  Text(
                    'People already in flight: ${proposal.flight.users?.length ?? 0} / ${proposal.availableSeats}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: proposal.flight.users?.length ?? 0,
                      itemBuilder: (context, index) {
                        final user = proposal.flight.users![index];
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundImage: AssetImage('assets/images/default_profile.png'),
                          ),
                          title: Text('${user.firstName} ${user.lastName}'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Price: ${proposal.flight.price} €',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (_isPilot && isDepartureWithinOneHour(parsedDepartureTime) && proposal.flight.status != "waiting_takeoff")
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm'),
                                content: const Text('Are you sure you want to start this proposal?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Yes'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('No'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            try {
                              var proposalResult = await ProposalService.startProposal(proposal.id);
                              if (context.mounted) {
                                context
                                    .read<CurrentFlightBloc>()
                                    .add(CurrentFlightLoaded(flight: proposalResult.flight));
                              }
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            } on DioException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.response?.data['message']}'),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Start Proposal'),
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (_isPilot)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm'),
                                content: const Text('Are you sure you want to delete this proposal?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Yes'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.response?.data['message']}'),
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
                    ),
                  if (!_isUserInProposal && !_isPilot)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0), // Add padding at the bottom
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _joinProposal(id: proposal.id),
                          child: const Text('Join Flight'),
                        ),
                      ),
                    ),
                  if (_isUserInProposal && !_isPilot)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0), // Add padding at the bottom
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _leaveProposal(id: proposal.id),
                          child: const Text('Leave Flight'),
                        ),
                      ),
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