import 'package:dio/dio.dart';
import 'package:frontend/models/monitoring_log.dart';

import 'dio.dart';

class MonitoringLogService {
  static Future<List<MonitoringLog>> fetchAll() async {
    try {
      final response = await dioApi.get("/monitoring-logs");

      List<dynamic> data = response.data;
      return data.map((json) => MonitoringLog.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Something went wrong during rating update: ${e.response}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
}