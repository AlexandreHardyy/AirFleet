import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/user.dart';

class UserStore {
  static const storage = FlutterSecureStorage();

  static User? user;

  static getUser() async {
    user ??= await UserService.getCurrentUser();
    return user;
  }

  static getToken() async {
    return storage.read(key: "token");
  }

  static setToken(String token) async {
    return storage.write(key: "token", value: token);
  }

  static removeToken() async {
    return storage.delete(key: "token");
  }
}