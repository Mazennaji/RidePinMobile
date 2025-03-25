import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

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
