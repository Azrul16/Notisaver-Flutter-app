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

class BackgroundReliabilityStatus {
  const BackgroundReliabilityStatus({
    required this.notificationAccessEnabled,
    required this.batteryOptimizationIgnored,
    required this.lastListenerConnectedAt,
    required this.lastNotificationCapturedAt,
    required this.lastRebindRequestedAt,
    required this.pendingCount,
  });

  final bool notificationAccessEnabled;
  final bool batteryOptimizationIgnored;
  final DateTime? lastListenerConnectedAt;
  final DateTime? lastNotificationCapturedAt;
  final DateTime? lastRebindRequestedAt;
  final int pendingCount;

  factory BackgroundReliabilityStatus.fromMap(Map<Object?, Object?> map) {
    DateTime? parseTimestamp(Object? value) {
      final raw = (value as num?)?.toInt() ?? 0;
      if (raw <= 0) return null;
      return DateTime.fromMillisecondsSinceEpoch(raw);
    }

    return BackgroundReliabilityStatus(
      notificationAccessEnabled:
          (map['notificationAccessEnabled'] as bool?) ?? false,
      batteryOptimizationIgnored:
          (map['batteryOptimizationIgnored'] as bool?) ?? false,
      lastListenerConnectedAt: parseTimestamp(map['lastListenerConnectedAt']),
      lastNotificationCapturedAt:
          parseTimestamp(map['lastNotificationCapturedAt']),
      lastRebindRequestedAt: parseTimestamp(map['lastRebindRequestedAt']),
      pendingCount: (map['pendingCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class DevicePowerProfile {
  const DevicePowerProfile({
    required this.manufacturer,
    required this.brand,
    required this.model,
    required this.isXiaomiFamily,
  });

  final String manufacturer;
  final String brand;
  final String model;
  final bool isXiaomiFamily;

  factory DevicePowerProfile.fromMap(Map<Object?, Object?> map) {
    return DevicePowerProfile(
      manufacturer: (map['manufacturer'] as String?) ?? '',
      brand: (map['brand'] as String?) ?? '',
      model: (map['model'] as String?) ?? '',
      isXiaomiFamily: (map['isXiaomiFamily'] as bool?) ?? false,
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

  Future<DevicePowerProfile> getDevicePowerProfile() async {
    final rawProfile =
        await _methodChannel.invokeMethod<Map<Object?, Object?>>(
              'getDevicePowerProfile',
            ) ??
            <Object?, Object?>{};
    return DevicePowerProfile.fromMap(rawProfile);
  }

  Future<bool> openAutoStartSettings() async {
    return (await _methodChannel.invokeMethod<bool>('openAutoStartSettings')) ??
        false;
  }

  Future<bool> openAppDetailsSettings() async {
    return (await _methodChannel.invokeMethod<bool>('openAppDetailsSettings')) ??
        false;
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

  Future<BackgroundReliabilityStatus> getReliabilityStatus() async {
    final rawStatus =
        await _methodChannel.invokeMethod<Map<Object?, Object?>>(
              'getReliabilityStatus',
            ) ??
            <Object?, Object?>{};
    return BackgroundReliabilityStatus.fromMap(rawStatus);
  }

  Future<void> refreshListenerBinding() async {
    await _methodChannel.invokeMethod<void>('refreshListenerBinding');
  }
}
