import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Dio dio = Dio(
  BaseOptions(
    baseUrl: dotenv.env['API_URL'] ?? "",
    followRedirects: false,
    validateStatus: (status) {
      return status == null || status < 500;
    },
  ),
);
