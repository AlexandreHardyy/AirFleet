import 'dart:io';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

extension PuckPosition on StyleManager {
  Future<Position> getPuckPosition() async {
    Layer? layer;
    if (Platform.isAndroid) {
      layer = await getLayer("mapbox-location-indicator-layer");
    } else {
      layer = await getLayer("puck");
    }
    final location = (layer as LocationIndicatorLayer).location;
    return Future.value(Position(location![1]!, location[0]!));
  }
}