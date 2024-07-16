import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/mobile/proposal/create_proposal.dart';
import 'package:frontend/mobile/proposal/my_proposals.dart';
import 'package:frontend/mobile/proposal/search.dart';
import 'package:frontend/services/vehicle.dart';
import 'package:frontend/models/vehicle.dart';
import 'package:frontend/storage/user.dart';

class ProposalsManagementScreen extends StatefulWidget {
  static const routeName = '/proposals-management';

  static Future<void> navigateTo(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  const ProposalsManagementScreen({super.key});

  @override
  _ProposalsManagementScreenState createState() => _ProposalsManagementScreenState();
}

class _ProposalsManagementScreenState extends State<ProposalsManagementScreen> {
  late Future<List<Vehicle>> _proposalsFuture;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _proposalsFuture = VehicleService.getVehiclesForMe();
  }

  void refreshProposals() {
    setState(() {
      _proposalsFuture = VehicleService.getVehiclesForMe();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPilot = UserStore.user?.role == Roles.pilot;

    List<BottomNavigationBarItem> navBarItems = [
      if (!isPilot)
        BottomNavigationBarItem(
          icon: const Icon(Icons.search),
          label: translate('common.input.search'),
        ),
      if (isPilot)
        BottomNavigationBarItem(
          icon: const Icon(Icons.local_offer),
          label: translate('proposal.create_proposal'),
        ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.flight),
        label: translate('proposal.my_proposals'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(translate('proposal.proposal_management')),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: navBarItems,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    bool isPilot = UserStore.user?.role == Roles.pilot;
    if (isPilot && _currentIndex == 0) {
      return const CreateProposalView();
    }

    switch (_currentIndex) {
      case 0:
        return const SearchView();
      case 1:
        return const MyProposalView();
      case 2:
        return const CreateProposalView();
      default:
        return const CreateProposalView();
    }
  }
}


