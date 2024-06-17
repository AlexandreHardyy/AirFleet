import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/mobile/blocs/current_flight/current_flight_bloc.dart';
import 'package:frontend/mobile/blocs/socket_io/socket_io_bloc.dart';
import 'package:frontend/mobile/map/utils.dart';
import 'package:frontend/models/flight.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class AirFleetMap extends StatefulWidget {
  final Flight? currentFlight;

  const AirFleetMap({super.key, this.currentFlight});

  @override
  State createState() => AirFleetMapState();
}

class AirFleetMapState extends State<AirFleetMap> {
  Timer? _timer;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;
  PointAnnotation? _pilotAnnotation;

  var _trackLocation = true;

  late MapboxMap _mapboxMap;

  _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    _mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    _mapboxMap.annotations.createPointAnnotationManager().then((value) async {
      _pointAnnotationManager = value;
    });

    _mapboxMap.annotations
        .createPolylineAnnotationManager()
        .then((value) async {
      _polylineAnnotationManager = value;
    });

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
    _setLocationComponent();
    _refreshTrackLocation();
  }

  _onScrollListener(ScreenCoordinate coordinates) {
    if (_trackLocation) {
      setState(() {
        _timer?.cancel();
        _trackLocation = false;
      });
    }
  }

  Future<PointAnnotation>? _createOnePointAnnotation(
      Position position, Uint8List icon) {
    return _pointAnnotationManager?.create(PointAnnotationOptions(
      geometry: Point(coordinates: position).toJson(),
      image: icon,
      iconSize: 3.0,
      iconOffset: [0.0, -5.0],
      symbolSortKey: 10,
    ));
  }

  void _createOneLineAnnotation(Position position1, Position position2) {
    _polylineAnnotationManager?.create(PolylineAnnotationOptions(
      geometry: LineString(coordinates: [position1, position2]).toJson(),
      lineColor: const Color(0xFF131141).value,
      lineWidth: 3,
    ));
  }

  void _setLocationComponent() async {
    await _mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
      ),
    );
  }

  void _refreshTrackLocation() async {
    _timer?.cancel();
    if (_trackLocation) {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) async {
          final position = await _mapboxMap.style.getPuckPosition();
          _setCameraPosition(position);
        },
      );
    }
  }

  void _setCameraPosition(Position position) {
    _mapboxMap.flyTo(
        CameraOptions(
          center: Point(coordinates: position).toJson(),
          zoom: 10,
        ),
        null);
  }

  Future<void> _createRouteOnMap(Airport departure, Airport arrival) async {
    final departurePosition = Position(departure.longitude, departure.latitude);
    final arrivalPosition = Position(arrival.longitude, arrival.latitude);

    final ByteData bytes =
        await rootBundle.load('assets/symbols/location-pin.png');
    final locationPin = bytes.buffer.asUint8List();

    _createOnePointAnnotation(departurePosition, locationPin);
    _createOnePointAnnotation(arrivalPosition, locationPin);
    _createOneLineAnnotation(departurePosition, arrivalPosition);

    setState(() {
      _trackLocation = false;
      _refreshTrackLocation();
    });

    _mapboxMap
        .cameraForCoordinateBounds(
          CoordinateBounds(
            southwest: Point(coordinates: departurePosition).toJson(),
            northeast: Point(coordinates: arrivalPosition).toJson(),
            infiniteBounds: true,
          ),
          MbxEdgeInsets(
            top: 1,
            left: 2,
            bottom: 3,
            right: 4,
          ),
          10,
          20,
          null,
          null,
        )
        .then((value) => _mapboxMap.flyTo(value, null));
  }

  Future<void> _createPilotPositionOnMap(Position position) async {
    final ByteData planeBytes =
        await rootBundle.load('assets/symbols/plane-icon.png');
    final planeIcon = planeBytes.buffer.asUint8List();

    if (_pilotAnnotation != null) {
      _pointAnnotationManager?.delete(_pilotAnnotation!);
    }
    _createOnePointAnnotation(position, planeIcon)?.then(
      (value) => {_pilotAnnotation = value},
    );
  }

  void _clearMap() {
    _pointAnnotationManager?.deleteAll();
    _polylineAnnotationManager?.deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    if (context.read<SocketIoBloc>().state.socket != null) {
      context.read<SocketIoBloc>().add(SocketIoListenEvent(
          eventId: "pilotPositionUpdated",
          event: "pilotPositionUpdated",
          callback: (data) {
            Map<String, dynamic> jsonData = jsonDecode(data);
            final position =
                Position(jsonData['longitude'], jsonData['latitude']);
            _createPilotPositionOnMap(position);
          }));
    }

    return BlocListener<CurrentFlightBloc, CurrentFlightState>(
      listener: (context, state) {
        //TODO Remove duplicated code
        if (state.status == CurrentFlightStatus.loaded) {
          _clearMap();
          final flight = state.flight;
          if (flight != null) {
            final departure = flight.departure;
            final arrival = flight.arrival;
            _createRouteOnMap(departure, arrival);
          } else {
            setState(() {
              _trackLocation = true;
              _refreshTrackLocation();
            });
          }
        }

        if (state.status == CurrentFlightStatus.selected) {
          _clearMap();
          final flightRequest = state.flightRequest;
          if (flightRequest != null) {
            final departure = flightRequest.departure;
            final arrival = flightRequest.arrival;
            _createRouteOnMap(departure, arrival);
          } else {
            setState(() {
              _trackLocation = true;
              _refreshTrackLocation();
            });
          }
        }
      },
      child: Scaffold(
          //TODO Improve this
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  setState(() {
                    _trackLocation = !_trackLocation;
                    _refreshTrackLocation();
                  });
                },
                backgroundColor:
                    _trackLocation ? const Color(0xFF131141) : Colors.grey,
                child: Icon(FontAwesomeIcons.locationCrosshairs,
                    color: _trackLocation
                        ? const Color(0xFFDCA200)
                        : Colors.black)),
          ),
          body: MapWidget(
            key: const ValueKey("mapWidget"),
            cameraOptions: CameraOptions(zoom: 3.0),
            onMapCreated: _onMapCreated,
            onStyleLoadedListener: _onStyleLoadedCallback,
            onScrollListener: _onScrollListener,
          )),
    );
  }
}
