import 'package:flutter/material.dart';

import 'create_flight.dart';

class FlightsManagement extends StatefulWidget {
  const FlightsManagement({super.key});

  @override
  State<FlightsManagement> createState() => _FlightsManagementState();
}

class _FlightsManagementState extends State<FlightsManagement> {
  FocusNode departureTextFieldFocusNode = FocusNode();
  FocusNode arrivalTextFieldFocusNode = FocusNode();
  final DraggableScrollableController draggableController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    departureTextFieldFocusNode.addListener(() {
      if (departureTextFieldFocusNode.hasFocus) {
        draggableController.animateTo(0.8, duration: const Duration(microseconds: 500), curve: Curves.ease);
      }
    });
    arrivalTextFieldFocusNode.addListener(() {
      if (arrivalTextFieldFocusNode.hasFocus) {
        draggableController.animateTo(0.8, duration: const Duration(microseconds: 500), curve: Curves.ease);
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
      snap: true ,
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
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                  child: DefaultTabController(
                    length: 3,
                    child: Scaffold(
                      appBar: AppBar(
                        toolbarHeight: 0,
                        bottom: const TabBar(
                          tabs: [
                            Text("Search"),
                            Text("Create"),
                            Text("List"),
                          ],
                        ),
                      ),
                      body: TabBarView(
                        children: [
                          const Icon(Icons.directions_car),
                          CreateFlightWidget(departureTextFieldFocusNode: departureTextFieldFocusNode, arrivalTextFieldFocusNode: arrivalTextFieldFocusNode),
                          const Icon(Icons.directions_bike),
                        ],
                      ),
                    ),
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
