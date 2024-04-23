
import 'package:dio/dio.dart';
import 'dart:io' show Platform;

final dioApi = Dio(
  BaseOptions(
    baseUrl: Platform.isAndroid ? "http://10.0.2.2:3001/api/" : "http://localhost:3001/api/"
  ),
);

final dioMapbox = Dio(
  BaseOptions(
    baseUrl: "https://api.mapbox.com/"
  ),
);