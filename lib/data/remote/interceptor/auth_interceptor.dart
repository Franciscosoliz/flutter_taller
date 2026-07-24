// lib/data/remote/interceptor/auth_interceptor.dart
import 'package:dio/dio.dart';
import '../../local/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;
  final Dio _dio;

  AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccess();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;

    // Solo actuar en 401 (No autorizado) y si no proviene de la ruta de refresh
    if (response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    if (err.requestOptions.path.contains('/auth/token/refresh/')) {
      await _storage.clearSession();
      handler.next(err);
      return;
    }

    // Prevenir ciclos infinitos si el reintento vuelve a fallar
    if (err.requestOptions.extra['_retry'] == true) {
      await _storage.clearSession();
      handler.next(err);
      return;
    }

    // Renovar JWT con Refresh Token
    final refresh = await _storage.getRefresh();
    if (refresh == null || refresh.isEmpty) {
      await _storage.clearSession();
      handler.next(err);
      return;
    }

    try {
      final refreshResponse = await _dio.post(
        '/auth/token/refresh/',
        data: {'refresh': refresh},
        options: Options(extra: {'_retry': true}),
      );

      final newAccess = refreshResponse.data['access'] as String;
      final newRefresh = refreshResponse.data['refresh'] as String?;

      await _storage.saveAccessToken(newAccess);
      if (newRefresh != null) {
        await _storage.saveTokens(newAccess, newRefresh);
      }

      // Reintentar la petición original con el nuevo token
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccess';
      retryOptions.extra['_retry'] = true;

      final retryResponse = await _dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } on DioException {
      await _storage.clearSession();
      handler.next(err);
    }
  }
}