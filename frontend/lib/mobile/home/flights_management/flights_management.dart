import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/home/flights_management/pilot_flight_management/pilot_current_flight_management/index.dart';
import 'package:frontend/mobile/home/flights_management/pilot_flight_management/search_flights.dart';
import 'package:frontend/models/rating.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/rating.dart';
import 'package:frontend/storage/user.dart';

import 'user_flight_management/create_flight.dart';
import 'user_flight_management/user_current_flight_management/index.dart';

class FlightsManagement extends StatefulWidget {
  const FlightsManagement({super.key});

  @override
  State<FlightsManagement> createState() => _FlightsManagementState();
}

class _FlightsManagementState extends State<FlightsManagement> {
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
                  child: BlocConsumer<CurrentFlightBloc, CurrentFlightState>(
                    listener: (context, state) {
                      if (state.status == CurrentFlightStatus.loaded &&
                          state.flight == null &&
                          state.pendingRating != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _dialogBuilder(context);
                        });
                      }
                    },
                    builder: (context, state) {
                      if (state.status == CurrentFlightStatus.loading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state.status == CurrentFlightStatus.loaded && !state.isModuleEnabled) {
                        return const Center(
                          child: Text("Module flight is disabled"),
                        );
                      }

                      if (state.status == CurrentFlightStatus.loaded &&
                          state.flight != null) {
                        return UserStore.user?.role == Roles.pilot
                            ? const CurrentPilotFlightManagement()
                            : const CurrentFlightManagement();
                      }

                      return UserStore.user?.role == Roles.pilot
                          ? DefaultTabController(
                              length: 1,
                              child: Scaffold(
                                appBar: AppBar(
                                  toolbarHeight: 0,
                                  bottom: const TabBar(
                                    tabs: [
                                      Text("List"),
                                    ],
                                  ),
                                ),
                                body: TabBarView(
                                  children: [
                                    SearchFlights(),
                                  ],
                                ),
                              ),
                            )
                          : DefaultTabController(
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
                                    CreateFlightWidget(
                                      departureTextFieldFocusNode:
                                          departureTextFieldFocusNode,
                                      arrivalTextFieldFocusNode:
                                          arrivalTextFieldFocusNode,
                                    ),
                                    const Icon(Icons.directions_bike),
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

Future<void> _dialogBuilder(BuildContext context) async {
  final Rating? pendingRating = context.read<CurrentFlightBloc>().state.pendingRating;

  if (pendingRating == null) {
    return;
  }

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (BuildContext context) {
      return RateFlightWidget(pilot: pendingRating.pilot,);
    },
  );

  final ratingId = pendingRating.id;
  if (result != null) {
    try {
      await RatingService.updateRating(
          ratingId, UpdateRatingRequest(rating: result['rating'], comment: result['comment']));
    } catch (e) {
      print(e);
    }
  } else {
    await RatingService.updateRating(
        ratingId, UpdateRatingRequest(rating: null, comment: null));
  }
}

class RateFlightWidget extends StatefulWidget {
  final User pilot;

  const RateFlightWidget({
    super.key,
    required this.pilot,
  });

  @override
  State<RateFlightWidget> createState() => _RateFlightWidgetState();
}

class _RateFlightWidgetState extends State<RateFlightWidget> {
  double rating = 0.0;
  String comment = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: Text(
        translate('home.flight_management.rating.title'),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(translate('home.flight_management.rating.subtitle', args: {'pilotName': widget.pilot.firstName}), style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 20),
          PannableRatingBar(
            rate: rating,
            items: List.generate(
              5,
                  (index) => const RatingWidget(
                selectedColor: Color(0xFFDCA200),
                unSelectedColor: Colors.grey,
                child: Icon(
                  Icons.star,
                  size: 40,
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {
                rating = value;
              });
            },
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              labelText: translate('home.flight_management.rating.input_label'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            keyboardType: TextInputType.multiline,
            maxLines: null,
            onChanged: (value) {
              setState(() {
                comment = value;
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: Text(translate('common.input.ignore')),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDCA200),
            textStyle: const TextStyle(color: Colors.white),
          ),
          child: Text(translate('common.input.submit')),
          onPressed: () {
            Navigator.of(context).pop({'rating': rating, 'comment': comment});
          },
        ),
      ],
    );
  }
}
