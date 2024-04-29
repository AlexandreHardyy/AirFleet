import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;

final String? apiUrl =  Platform.isAndroid ? dotenv.env['API_URL_ANDROID'] : dotenv.env['API_URL'];

Dio dioApi = Dio(
  BaseOptions(
    baseUrl: apiUrl ?? "",
    followRedirects: false,
    validateStatus: (status) {
      return status == null || status < 500;
    },
  ),
);

final dioMapbox = Dio(
  BaseOptions(
      baseUrl: "https://api.mapbox.com/"
  ),
);
