import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/env.dart';
import '../storage/token_store.dart';
import 'auth_interceptor.dart';
import 'session_expired_provider.dart';

part 'dio_provider.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final tokens = ref.watch(tokenStoreProvider);
  final client = Dio(
    BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
    ),
  );

  client.interceptors.add(
    AuthInterceptor(
      dio: client,
      tokens: tokens,
      onUnauthorized: () async {
        await tokens.clear();
        ref.read(sessionExpiredProvider.notifier).notify();
      },
    ),
  );
  if (kDebugMode) {
    client.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }
  return client;
}
