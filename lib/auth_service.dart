import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      final token = response.data['token'];
      final pref = await SharedPreferences.getInstance();
      await pref.setString('authToken', token);
      return true;
    } catch (e) {
      print('Login failed: $e');
      return false;
    }
  }

  static Future<bool> logout() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final token = pref.getString('authToken');
      if (token != null) {
        await ApiService.dio.post(
          '/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        await pref.remove('authToken');
      }
      return true;
    } catch (e) {
      print('Logout failed: $e');
      return false;
    }
  }
}
