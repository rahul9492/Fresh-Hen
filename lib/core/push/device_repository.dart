import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/env.dart';
import '../network/api_call.dart';
import '../network/dio_provider.dart';
import '../network/endpoints.dart';

part 'device_repository.g.dart';

/// Tells the backend which phone to send the signed-in customer's pushes to.
abstract interface class DeviceRepository {
  Future<void> register(String token);

  Future<void> unregister(String token);
}

/// No backend yet: just log the token so it can be used to send a test push
/// from the Firebase console.
class MockDeviceRepository implements DeviceRepository {
  @override
  Future<void> register(String token) async => debugPrint('FCM token: $token');

  @override
  Future<void> unregister(String token) async {}
}

/// Assumed API shape (adjust when the contract lands):
/// `POST /devices` `{ token, platform }` and `DELETE /devices/{token}`.
class RemoteDeviceRepository implements DeviceRepository {
  RemoteDeviceRepository(this._dio);

  final Dio _dio;

  @override
  Future<void> register(String token) => apiCall(() async {
        await _dio.post<void>(
          Endpoints.devices,
          data: {'token': token, 'platform': defaultTargetPlatform.name},
        );
      });

  @override
  Future<void> unregister(String token) => apiCall(() async {
        await _dio.delete<void>(Endpoints.device(token));
      });
}

/// The only place that decides mock vs remote for device registration.
@Riverpod(keepAlive: true)
DeviceRepository deviceRepository(Ref ref) {
  if (Env.useMock) return MockDeviceRepository();
  return RemoteDeviceRepository(ref.watch(dioProvider));
}
