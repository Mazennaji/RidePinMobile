import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static final cacheStore = MemCacheStore();
  static final cacheOptions = CacheOptions(store: cacheStore);
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.ridepin.com',
      connectTimeout: Duration(milliseconds: 5000),
    ),
  )..interceptors.add(DioCacheInterceptor(options: cacheOptions));

  Future<Response> register(Map<String, dynamic> data) async {
    return await dio.post('/register', data: data);
  }

  Future<Response> login(String email, String password) async {
    return await dio.post(
      '/login',
      data: {'email': email, 'password': password},
    );
  }

  final Dio _dio = Dio();

  ApiService() {
    // Add cache interceptor
    _dio.interceptors.add(
      DioCacheInterceptor(
        options: CacheOptions(
          store: MemCacheStore(), // Use memory cache
          policy: CachePolicy.request, // Cache all requests
          hitCacheOnErrorExcept: [401, 403], // Don't cache auth errors
          maxStale: const Duration(days: 7), // Max cache duration
        ),
      ),
    );
    _dio.interceptors.add(LogInterceptor());
  }
}

final String _baseUrl = 'https://your-api-url.com/api';

Future<Map<String, dynamic>> post(
  String endpoint,
  Map<String, dynamic> data,
) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/$endpoint'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to post data: ${response.body}');
  }
}

Future<Map<String, dynamic>> simulatePost(
  String endpoint,
  Map<String, dynamic> data,
) async {
  // Replace with actual API call logic
  await Future.delayed(Duration(seconds: 1)); // Simulate network delay
  return {'ride_id': '12345'}; // Simulated response
}

Future<Map<String, dynamic>> postRequest(
  String endpoint,
  Map<String, dynamic> data,
) async {
  final url = Uri.parse('$_baseUrl/$endpoint');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to post data: ${response.body}');
  }
}
