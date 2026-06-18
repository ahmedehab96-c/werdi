import 'package:dio/dio.dart';
import 'package:werdi/core/constants/app_constants.dart';

class LaravelApiClient {
  LaravelApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.laravelBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

  final Dio dio;
  String? _token;

  void setToken(String? token) {
    _token = token;
    if (token == null || token.isEmpty) {
      dio.options.headers.remove('Authorization');
      return;
    }
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  String? get token => _token;
}
