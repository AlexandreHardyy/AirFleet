import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/mobile/profile/user_profile.dart';
import 'package:frontend/mobile/proposal/proposals_management.dart';
import 'package:frontend/mobile/vehicles_management.dart';
import 'package:frontend/services/user.dart';
import 'package:frontend/storage/user.dart';
import 'package:frontend/widgets/profile_image.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.only(top: 32.0, bottom: 32.0, left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipOval(
                      child: Container(
                          // decoration: const BoxDecoration(
                          //   color: Color(0xFF131141),
                          // ),
                          width: 80,
                          height: 80,
                          // padding: const EdgeInsets.all(12.0),
                          child: const ProfileImage(),
                        ),
                    ),
                    const SizedBox(height: 16.0),
                    AutoSizeText(
                      '${UserStore.user?.firstName ?? ''} ${UserStore.user?.lastName?.toUpperCase() ?? ''}',
                      style: const TextStyle(fontSize: 18.0),
                      maxLines: 2,
                    ),
                    Text(
                      _displayRole(UserStore.user!.role.toString()),
                      style: const TextStyle(
                        color: Color(0xFF131141),
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.userLarge,
                    color: Color(0xFF131141)),
                title: Text(
                  translate('home.drawer.profile'),
                  style: const TextStyle(color: Color(0xFF131141)),
                ),
                onTap: () {
                  UserProfileScreen.navigateTo(context);
                },
              ),
              UserStore.user?.role == Roles.pilot
                  ? ListTile(
                      leading: const Icon(FontAwesomeIcons.plane,
                          color: Color(0xFF131141)),
                      title: Text(translate('home.drawer.vehicle'),
                          style: const TextStyle(color: Color(0xFF131141))),
                      onTap: () async {
                        VehiclesManagementScreen.navigateTo(context);
                      },
                    )
                  : const SizedBox.shrink(),
              ListTile(
                leading: const Icon(FontAwesomeIcons.planeDeparture,
                    color: Color(0xFF131141)),
                title: Text(translate('home.drawer.offerFlight'),
                    style: const TextStyle(color: Color(0xFF131141))),
                onTap: () async {
                  ProposalsManagementScreen.navigateTo(context);
                },
              ),
            ],
          ),
          ListTile(
            tileColor: Colors.red.shade100,
            leading: const Icon(FontAwesomeIcons.rightFromBracket,
                color: Colors.red),
            title: Text(translate('home.drawer.logout'),
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              await UserService.logOut(context);
            },
          ),
        ],
      ),
    );
  }
}

String _displayRole(String role) {
  switch (role) {
    case 'ROLE_ADMIN':
      return translate('common.role.admin');
    case 'ROLE_USER':
      return translate('common.role.user');
    case 'ROLE_PILOT':
      return translate('common.role.pilot');
    default:
      return translate('common.role.unknown');
  }
}