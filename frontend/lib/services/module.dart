import 'package:dio/dio.dart';
import 'package:frontend/models/module.dart';

import 'dio.dart';

class ModuleService {
  static Future<List<Module>> getModules() async {
    try {
      final response = await dioApi.get("/modules");

      if (response.data == null) {
        return [];
      }

      List<dynamic> data = response.data;
      return data.map((json) => Module.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Something went wrong during module retrieval: ${e.response}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  static Future<Module> getModuleByName(String name) async {
    try {
      final response = await dioApi.get("/modules/name/$name");

      return Module.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Something went wrong during module retrieval: ${e.response}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  static Future<Module> updateModule(int moduleId, UpdateModuleRequest moduleRequest) async {
    try {
      final response = await dioApi.put("/modules/$moduleId", data: moduleRequest.toJson());

      return Module.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Something went wrong during module update: ${e.response}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
}