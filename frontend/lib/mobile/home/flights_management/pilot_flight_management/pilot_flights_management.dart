import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/home/flights_management/current_flight_management/index.dart';
import 'package:frontend/mobile/home/flights_management/pilot_flight_management/pilot_not_ready.dart';

import '../create_flight.dart';

class PilotFlightsManagement extends StatefulWidget {
  const PilotFlightsManagement({super.key});

  @override
  State<PilotFlightsManagement> createState() => _PilotFlightsManagementState();
}

class _PilotFlightsManagementState extends State<PilotFlightsManagement> {
  FocusNode departureTextFieldFocusNode = FocusNode();
  FocusNode arrivalTextFieldFocusNode = FocusNode();
  final DraggableScrollableController draggableController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    departureTextFieldFocusNode.addListener(() {
      if (departureTextFieldFocusNode.hasFocus) {
        draggableController.animateTo(
          0.8,
          duration: const Duration(microseconds: 500),
          curve: Curves.ease,
        );
      }

      if (!departureTextFieldFocusNode.hasFocus &&
          !arrivalTextFieldFocusNode.hasFocus) {
        draggableController.animateTo(
          0.4,
          duration: const Duration(microseconds: 500),
          curve: Curves.ease,
        );
      }
    });
    arrivalTextFieldFocusNode.addListener(() {
      if (arrivalTextFieldFocusNode.hasFocus) {
        draggableController.animateTo(
          0.8,
          duration: const Duration(microseconds: 500),
          curve: Curves.ease,
        );
      }

      if (!departureTextFieldFocusNode.hasFocus &&
          !arrivalTextFieldFocusNode.hasFocus) {
        draggableController.animateTo(
          0.4,
          duration: const Duration(microseconds: 500),
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  void dispose() {
    departureTextFieldFocusNode.dispose();
    arrivalTextFieldFocusNode.dispose();
    draggableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: draggableController,
      initialChildSize: 0.4,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      snapSizes: const [0.4, 0.8],
      snap: true,
      builder: (BuildContext context, scrollController) {
        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              SliverFillRemaining(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: BlocBuilder<CurrentFlightBloc, CurrentFlightState>(
                    builder: (context, state) {
                      if (state.status == CurrentFlightStatus.loading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state.status == CurrentFlightStatus.loaded &&
                          state.flight != null) {
                        return const CurrentFlightManagement();
                      }

                      return DefaultTabController(
                        length: 2,
                        child: Scaffold(
                          appBar: AppBar(
                            toolbarHeight: 0,
                            bottom: const TabBar(
                              tabs: [
                                Text("Create"),
                                Text("List"),
                              ],
                            ),
                          ),
                          body: TabBarView(
                            children: [
                              CreateFlightWidget(
                                departureTextFieldFocusNode:
                                    departureTextFieldFocusNode,
                                arrivalTextFieldFocusNode:
                                    arrivalTextFieldFocusNode,
                              ),
                              PilotNotReadyScreen(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
