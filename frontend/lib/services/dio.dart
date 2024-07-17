import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/storage/user.dart';
import 'dart:io' show Platform;

final String apiUrl = kIsWeb ? const String.fromEnvironment('API_URL') : (Platform.isAndroid ? const String.fromEnvironment('API_URL_ANDROID') : const String.fromEnvironment('API_URL'));

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
