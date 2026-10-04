import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/router/router.dart';
import '../../app/router/routes.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'device_repository.dart';
import 'push_route.dart';

part 'push_service.g.dart';

/// Push notifications through Firebase Cloud Messaging. There is no in-app
/// notification list: pushes live in the system tray and tapping one opens the
/// screen from [pushRoute]. Features listen to [received] to refresh what a
/// push is about (e.g. orders); push never imports them.
///
/// Started from `FreshHenApp`. Until the Firebase config files are added
/// (`flutterfire configure`) it stays off and logs "Push disabled".
@Riverpod(keepAlive: true)
PushService pushService(Ref ref) {
  final service = PushService(ref);
  ref.onDispose(service.dispose);
  unawaited(service.start());
  return service;
}

class PushService {
  PushService(this._ref);

  final Ref _ref;
  final _local = FlutterLocalNotificationsPlugin();
  final _subscriptions = <StreamSubscription<Object?>>[];
  final _received = StreamController<Map<String, dynamic>>.broadcast();
  var _started = false;

  /// A push arrived while the app was open; its `data`.
  Stream<Map<String, dynamic>> get received => _received.stream;

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  Future<void> start() async {
    try {
      // After `flutterfire configure`, pass `options: DefaultFirebaseOptions.currentPlatform`.
      await Firebase.initializeApp();
      await _initLocalNotifications();
      // iOS shows the banner itself while the app is open; Android needs
      // _showWhileOpen.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('Push disabled: $e');
      return;
    }
    _started = true;

    _subscriptions
      ..add(FirebaseMessaging.onMessage.listen(_onMessage))
      ..add(FirebaseMessaging.onMessageOpenedApp.listen((m) => _open(m.data)))
      ..add(_messaging.onTokenRefresh.listen(_register));

    // Ask for permission and register this phone once the customer is signed in.
    _ref.listen(authSessionProvider, (_, user) {
      if (user != null) unawaited(_onSignedIn());
    }, fireImmediately: true);

    // The app was opened by tapping a push while it was closed.
    final initial = await _messaging.getInitialMessage();
    final launch = await _local.getNotificationAppLaunchDetails();
    if (initial != null) {
      _open(initial.data);
    } else if (launch?.didNotificationLaunchApp ?? false) {
      _openPayload(launch!.notificationResponse?.payload);
    }
  }

  /// Call before signing out, while the session can still reach the API, so
  /// this phone stops getting the customer's pushes.
  Future<void> unregister() async {
    if (!_started) return;
    try {
      final token = await _messaging.getToken();
      if (token != null) await _ref.read(deviceRepositoryProvider).unregister(token);
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('Push unregister failed: $e');
    }
  }

  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _received.close();
  }

  Future<void> _initLocalNotifications() async {
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permission is asked through FirebaseMessaging after sign-in.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) => _openPayload(r.payload),
    );
    final android = _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    for (final c in PushChannel.values) {
      await android?.createNotificationChannel(
        AndroidNotificationChannel(
          c.id,
          c.label,
          description: c.description,
          importance: c == PushChannel.orderUpdates ? Importance.high : Importance.defaultImportance,
        ),
      );
    }
  }

  Future<void> _onSignedIn() async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;
    final token = await _messaging.getToken();
    if (token != null) await _register(token);
  }

  Future<void> _register(String token) async {
    if (_ref.read(authSessionProvider) == null) return;
    try {
      await _ref.read(deviceRepositoryProvider).register(token);
    } catch (e) {
      debugPrint('Push register failed: $e'); // retried on the next launch or token refresh
    }
  }

  void _onMessage(RemoteMessage message) {
    _received.add(message.data);
    _showWhileOpen(message);
  }

  /// FCM does not show a notification while the app is open on Android, so
  /// show it ourselves, like it would appear with the app closed.
  void _showWhileOpen(RemoteMessage message) {
    final n = message.notification;
    if (n == null || defaultTargetPlatform != TargetPlatform.android) return;
    final channel = PushChannel.forData(message.data);
    _local.show(
      id: (message.messageId ?? '${DateTime.now()}').hashCode & 0x7fffffff,
      title: n.title,
      body: n.body,
      payload: jsonEncode(message.data),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.label,
          channelDescription: channel.description,
          importance:
              channel == PushChannel.orderUpdates ? Importance.high : Importance.defaultImportance,
          priority: channel == PushChannel.orderUpdates ? Priority.high : Priority.defaultPriority,
        ),
      ),
    );
  }

  void _openPayload(String? payload) {
    if (payload == null) return;
    try {
      _open(jsonDecode(payload) as Map<String, dynamic>);
    } catch (_) {}
  }

  /// Opens the push's screen on top of Home, so back returns to Home.
  Future<void> _open(Map<String, dynamic> data) async {
    if (_ref.read(authSessionProvider) == null) return; // login comes first
    await WidgetsBinding.instance.endOfFrame;
    final router = _ref.read(goRouterProvider);
    final route = pushRoute(data);
    router.go(Routes.home);
    if (route != Routes.home) router.push(route);
  }
}
