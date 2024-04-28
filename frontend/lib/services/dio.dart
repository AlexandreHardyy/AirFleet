import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/storage/user.dart';
import 'dart:io' show Platform;

final String? apiUrl = kIsWeb ? dotenv.env['API_URL'] : (Platform.isAndroid ? dotenv.env['API_URL_ANDROID'] : dotenv.env['API_URL']);

final dioMapbox = Dio(
  BaseOptions(
      baseUrl: "https://api.mapbox.com/"
  ),
);

class DioBuilder {
  DioBuilder() {
    dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          final bearerToken = await UserStore.getToken();

          if (bearerToken != null) {
            options.headers['Authorization'] = 'Bearer $bearerToken';
          }
          return handler.next(options); 
        },
      )
    );
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: apiUrl ?? "",
      followRedirects: false,
      validateStatus: (status) {
        return status == null || status < 500;
      },
    ),
  );
}

final dioApi = DioBuilder().dio;
