import 'dart:io';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:math' as math;

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

double getDistanceFromLatLonInKm(double lat1, double lon1, double lat2, double lon2) {
  var R = 6371; // Radius of the earth in km
  var dLat = deg2rad(lat2-lat1);  // deg2rad below
  var dLon = deg2rad(lon2-lon1);
  var a =
      math.sin(dLat/2) * math.sin(dLat/2) +
          math.cos(deg2rad(lat1)) * math.cos(deg2rad(lat2)) *
              math.sin(dLon/2) * math.sin(dLon/2)
  ;
  var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a));
  var d = R * c; // Distance in km
  return d;
}

double deg2rad(double deg) {
  return deg * (math.pi/180);
}