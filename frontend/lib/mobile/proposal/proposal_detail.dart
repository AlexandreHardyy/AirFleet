import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/payment_screen.dart';
import 'package:frontend/mobile/proposal/confirm_animation.dart';
import 'package:frontend/models/proposal.dart';
import 'package:frontend/services/proposal.dart';
import 'package:frontend/storage/user.dart';
import 'package:frontend/widgets/profile_image.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class ProposalDetail extends StatefulWidget {
  static const routeName = '/proposal-detail';

  static Future<void> navigateTo(BuildContext context,
      {required int proposalId}) {
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

  void _joinProposal({required Proposal proposal}) async {
    try {
      PaymentScreen.navigateTo(
        context,
        flight: proposal.flight,
        callbackSuccess: () async {
          Navigator.of(context).pop();
          _showConfirmation(context);
          await ProposalService.joinProposal(proposal.id);
          final updatedProposal =
              await ProposalService.getProposalById(widget.proposalId);
          setState(() {
            _proposal = Future.value(updatedProposal);
            _isUserInProposal = true;
          });
        },
      );
    } catch (e) {
      toastification.show(
        title: const Text('Error, could not join proposal'),
        autoCloseDuration: const Duration(seconds: 5),
        primaryColor: CupertinoColors.systemRed,
      );
    }
  }

  void _leaveProposal({required int id}) async {
    try {
      await ProposalService.leaveProposal(id);
      final updatedProposal =
          await ProposalService.getProposalById(widget.proposalId);
      setState(() {
        _proposal = Future.value(updatedProposal);
        _isUserInProposal = false;
      });
    } catch (e) {
      toastification.show(
        title: const Text('Error, could not leave proposal'),
        autoCloseDuration: const Duration(seconds: 5),
        primaryColor: CupertinoColors.systemRed,
      );
    }
  }

  void _showConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmationScreen(
          onCompleted: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
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
        title: Text(translate('proposal.proposal_details')),
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
            _isUserInProposal = proposal.flight.users
                    ?.any((user) => user.id == UserStore.user?.id) ??
                false;
            DateTime parsedDepartureTime =
                DateTime.parse(proposal.departureTime);
            String formattedDepartureTime =
                DateFormat('dd/MM/yyyy HH:mm').format(parsedDepartureTime);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          proposal.flight.departure.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          proposal.flight.arrival.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formattedDepartureTime,
                          style: const TextStyle(fontSize: 20),
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
                          ClipOval(
                            child: SizedBox(
                              width: 45,
                              height: 45,
                              child: ProfileImage(
                                  profileID:
                                      proposal.flight.pilot?.id.toString()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                              '${proposal.flight.pilot?.firstName} ${proposal.flight.pilot?.lastName}',
                              style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(proposal.description,
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  Text(
                    '${translate('proposal.people_in_flight')}: ${proposal.flight.users?.length ?? 0} / ${proposal.availableSeats}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: proposal.flight.users?.length ?? 0,
                      itemBuilder: (context, index) {
                        final user = proposal.flight.users![index];
                        return ListTile(
                          leading: ClipOval(
                            child: SizedBox(
                              width: 45,
                              height: 45,
                              child: ProfileImage(
                                  profileID: proposal.flight.users![index].id
                                      .toString()),
                            ),
                          ),
                          title: Text('${user.firstName} ${user.lastName}'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${translate('common.input.price')}: ${proposal.flight.price} €',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (_isPilot &&
                      isDepartureWithinOneHour(parsedDepartureTime) &&
                      proposal.flight.status != "waiting_takeoff")
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(translate('common.confirm')),
                                content: Text(translate(
                                    'proposal.confirm_start_proposal')),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(translate('common.yes')),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(translate('common.no')),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            try {
                              var proposalResult =
                                  await ProposalService.startProposal(
                                      proposal.id);
                              if (context.mounted) {
                                context.read<CurrentFlightBloc>().add(
                                    CurrentFlightLoaded(
                                        flight: proposalResult.flight));
                              }
                              ProposalService.deleteProposal(proposal.id);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            } on DioException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Error: ${e.response?.data['message']}'),
                                ),
                              );
                            }
                          }
                        },
                        child: Text(translate('proposal.start_proposal')),
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
                                title: Text(translate('common.confirm')),
                                content: Text(translate(
                                    'proposal.confirm_delete_proposal')),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(translate('common.yes')),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(translate('common.no')),
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
                        child: Text(translate('proposal.delete_proposal')),
                      ),
                    ),
                  if (!_isUserInProposal && !_isPilot)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => {
                            _joinProposal(proposal: proposal),
                          },
                          child: Text(translate('proposal.join_proposal')),
                        ),
                      ),
                    ),
                  if (_isUserInProposal && !_isPilot)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final confirm = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(translate('common.confirm')),
                                  content: Text(translate(
                                      'proposal.confirm_leave_proposal')),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text(translate('common.yes')),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text(translate('common.no')),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              try {
                                _leaveProposal(id: proposal.id);
                                Navigator.of(context).pop();
                              } on DioException catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Error: ${e.response?.data['message']}'),
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(translate('proposal.leave_proposal')),
                        ),
                      ),
                    ),
                ],
              ),
            );
          } else {
            return Center(child: Text(translate('proposal.empty_proposal')));
          }
        },
      ),
    );
  }
}
