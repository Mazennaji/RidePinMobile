import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future<void> saveUser(String userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', userJson);
  }

  static Future<String?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user');
  }
}
