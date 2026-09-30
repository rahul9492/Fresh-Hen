import 'package:dio/dio.dart';

import '../storage/token_store.dart';
import 'endpoints.dart';

/// Adds the bearer token to outgoing requests and reports 401s.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.tokens, required this.onUnauthorized});

  final TokenStore tokens;
  final Future<void> Function() onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokens.read();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isPublic = Endpoints.public.contains(err.requestOptions.path);
    if (err.response?.statusCode == 401 && !isPublic && tokens.read() != null) {
      await onUnauthorized();
    }
    handler.next(err);
  }
}
