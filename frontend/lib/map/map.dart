import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/map/utils.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';


class AirFleetMap extends StatefulWidget {
  const AirFleetMap({super.key});

  @override
  State createState() => AirFleetMapState();
}

class AirFleetMapState extends State<AirFleetMap> {
  late MapboxMap mapboxMap;
  Timer? timer;
  var trackLocation = true;

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    this.mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    await _getPermission();

    // var status = await Permission.locationWhenInUse.request();

    // if (status.isGranted) {
    //   this.mapboxMap.location.updateSettings(LocationComponentSettings(
    //       enabled: true,
    //       puckBearingEnabled: true,
    //       locationPuck: LocationPuck(locationPuck2D: DefaultLocationPuck2D())
    //   ));
    // }
  }

  _getPermission() async {
    await Permission.locationWhenInUse.request();
  }

  _onStyleLoadedCallback(StyleLoadedEventData data) {
      setLocationComponent();
      refreshTrackLocation();
  }

  _onScrollListener(ScreenCoordinate coordinates) {
    setState(() {
      if (trackLocation) {
        timer?.cancel();
        trackLocation = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //TODO Improve this
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
            heroTag: null,
            onPressed: () {
              setState(() {
                trackLocation = !trackLocation;
                refreshTrackLocation();
              });
            },
            backgroundColor: trackLocation ? Colors.blue : Colors.grey,
            child: const Icon(FontAwesomeIcons.locationCrosshairs)),
      ),
        body: MapWidget(
          key: const ValueKey("mapWidget"),
          cameraOptions: CameraOptions(zoom: 3.0),
          onMapCreated: _onMapCreated,
          onStyleLoadedListener: _onStyleLoadedCallback,
          onScrollListener: _onScrollListener,
        )
    );
  }

  setLocationComponent() async {
    await mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
      ),
    );
  }

  refreshTrackLocation() async {
    timer?.cancel();
    if (trackLocation) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        final position = await mapboxMap.style.getPuckPosition();
        setCameraPosition(position);
      });
    }
  }

  setCameraPosition(Position position) {
    mapboxMap.flyTo(
        CameraOptions(
          center: Point(coordinates: position).toJson(),
          zoom: 10,
        ),
        null);
  }
}
