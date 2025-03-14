import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api',
      headers: {'Accept': 'application/json'},
    ),
  );

  static Dio get dio => _dio;
}
