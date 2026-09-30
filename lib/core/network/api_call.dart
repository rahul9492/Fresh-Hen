import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

/// Runs a Dio call and converts any [DioException] into an [AppException] with
/// a user-facing message. Wrap every remote repository method in this.
Future<T> apiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    throw mapDioError(e);
  }
}

AppException mapDioError(DioException e) {
  final status = e.response?.statusCode;
  final serverMessage = _serverMessage(e.response?.data);

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return AppException('The request timed out. Please try again.', statusCode: status);
    case DioExceptionType.connectionError:
      return AppException('No internet connection.', statusCode: status);
    case DioExceptionType.cancel:
      return const AppException('Request cancelled.');
    default:
      break;
  }

  if (serverMessage != null) return AppException(serverMessage, statusCode: status);
  return switch (status) {
    401 => AppException('Your session has expired. Please log in again.', statusCode: status),
    404 => AppException('We could not find what you were looking for.', statusCode: status),
    final s? when s >= 500 => AppException('Server error. Please try again later.', statusCode: s),
    _ => AppException('Something went wrong. Please try again.', statusCode: status),
  };
}

String? _serverMessage(Object? data) {
  if (data is Map<String, dynamic>) {
    final m = data['message'] ?? data['error'];
    if (m is String && m.trim().isNotEmpty) return m;
  }
  return null;
}
