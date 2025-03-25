import 'package:dio/dio.dart';

class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.ridepin.com',
      connectTimeout: Duration(milliseconds: 5000),
    ),
  );

  Future<Response> register(Map<String, dynamic> data) async {
    return await dio.post('/register', data: data);
  }

  Future<Response> login(String email, String password) async {
    return await dio.post(
      '/login',
      data: {'email': email, 'password': password},
    );
  }
}
