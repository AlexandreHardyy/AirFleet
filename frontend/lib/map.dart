import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';


class AirFleetMap extends StatefulWidget {
  const AirFleetMap({super.key});

  @override
  State createState() => AirFleetMapState();
}

class AirFleetMapState extends State<AirFleetMap> {
  MapboxMap? mapboxMap;

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    var status = await Permission.locationWhenInUse.request();

    print("Armand 4");
    print(status);
    if (status.isGranted) {
      print("Armand");
      print(status);
      this.mapboxMap?.location.updateSettings(LocationComponentSettings(
          enabled: true,
          puckBearingEnabled: true,
          locationPuck: LocationPuck(locationPuck2D: DefaultLocationPuck2D())
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MapWidget(
          key: const ValueKey("mapWidget"),
          onMapCreated: _onMapCreated,
          cameraOptions: CameraOptions(
              center: Point(coordinates: Position(2.333333,48.866667)).toJson(),
              zoom: 12.0),
        ));
  }
}
