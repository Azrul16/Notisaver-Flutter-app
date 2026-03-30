import 'package:flutter/services.dart';

import '../data/models/saved_notification.dart';

class InstalledApp {
  const InstalledApp({
    required this.appName,
    required this.packageName,
  });

  final String appName;
  final String packageName;

  factory InstalledApp.fromMap(Map<Object?, Object?> map) {
    return InstalledApp(
      appName: (map['appName'] as String?) ?? 'Unknown app',
      packageName: (map['packageName'] as String?) ?? '',
    );
  }
}

class AndroidBridgeService {
  static const MethodChannel _methodChannel =
      MethodChannel('notisaver/methods');
  static const EventChannel _eventChannel = EventChannel('notisaver/events');

  Stream<SavedNotification> get notifications => _eventChannel
      .receiveBroadcastStream()
      .where((event) => event is Map)
      .map(
        (event) => SavedNotification.fromChannelMap(
          Map<Object?, Object?>.from(event as Map),
        ),
      );

  Future<bool> isNotificationAccessEnabled() async {
    return (await _methodChannel
            .invokeMethod<bool>('isNotificationAccessEnabled')) ??
        false;
  }

  Future<void> openNotificationAccessSettings() async {
    await _methodChannel.invokeMethod<void>('openNotificationAccessSettings');
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    return (await _methodChannel
            .invokeMethod<bool>('isIgnoringBatteryOptimizations')) ??
        false;
  }

  Future<void> requestIgnoreBatteryOptimizations() async {
    await _methodChannel.invokeMethod<void>(
      'requestIgnoreBatteryOptimizations',
    );
  }

  Future<List<InstalledApp>> getInstalledApps() async {
    final rawApps = await _methodChannel.invokeMethod<List<Object?>>(
          'getInstalledApps',
        ) ??
        <Object?>[];

    return rawApps
        .whereType<Map>()
        .map((app) => InstalledApp.fromMap(Map<Object?, Object?>.from(app)))
        .toList();
  }

  Future<List<SavedNotification>> consumePendingNotifications() async {
    final rawNotifications = await _methodChannel.invokeMethod<List<Object?>>(
          'consumePendingNotifications',
        ) ??
        <Object?>[];

    return rawNotifications
        .whereType<Map>()
        .map(
          (notification) => SavedNotification.fromChannelMap(
            Map<Object?, Object?>.from(notification),
          ),
        )
        .toList();
  }
}
