import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/models/saved_notification.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'features/notifications/detail_screen.dart';
import 'features/notifications/home_screen.dart';
import 'features/permissions/permission_setup_screen.dart';
import 'features/settings/app_filter_screen.dart';
import 'features/splash/splash_screen.dart';
import 'services/android_bridge_service.dart';

class NotiSaverApp extends StatefulWidget {
  const NotiSaverApp({super.key});

  @override
  State<NotiSaverApp> createState() => _NotiSaverAppState();
}

class _NotiSaverAppState extends State<NotiSaverApp>
    with WidgetsBindingObserver {
  final SettingsRepository _settingsRepository = SettingsRepository();
  final NotificationRepository _notificationRepository = NotificationRepository();
  final AndroidBridgeService _androidBridgeService = AndroidBridgeService();

  StreamSubscription<SavedNotification>? _liveSubscription;

  bool _isReady = false;
  bool _hasCompletedPermissionSetup = false;
  bool _notificationAccessEnabled = false;
  bool _batteryOptimizationIgnored = false;
  bool _darkModeEnabled = false;
  bool _unreadFirstEnabled = true;
  bool _appGroupingEnabled = true;
  SearchScope _searchScope = SearchScope.fullContent;
  bool _exactMatchSearchEnabled = false;
  Set<String> _excludedPackages = <String>{};
  List<SavedNotification> _notifications = <SavedNotification>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isAndroid) {
      _bootstrap();
    } else {
      _isReady = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _liveSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && Platform.isAndroid) {
      _handleResume();
    }
  }

  Future<void> _bootstrap() async {
    final splashDelay = Future<void>.delayed(const Duration(milliseconds: 1500));
    final hasCompletedPermissionSetupFuture =
        _settingsRepository.getPermissionsSetupCompleted();
    final darkModeEnabledFuture = _settingsRepository.getDarkModeEnabled();
    final unreadFirstEnabledFuture = _settingsRepository.getUnreadFirstEnabled();
    final appGroupingEnabledFuture = _settingsRepository.getAppGroupingEnabled();
    final searchScopeFuture = _settingsRepository.getSearchScope();
    final exactMatchSearchEnabledFuture =
        _settingsRepository.getExactMatchSearchEnabled();
    final excludedPackagesFuture = _settingsRepository.getExcludedPackages();

    final hasCompletedPermissionSetup = await hasCompletedPermissionSetupFuture;
    final darkModeEnabled = await darkModeEnabledFuture;
    final unreadFirstEnabled = await unreadFirstEnabledFuture;
    final appGroupingEnabled = await appGroupingEnabledFuture;
    final searchScopeValue = await searchScopeFuture;
    final exactMatchSearchEnabled = await exactMatchSearchEnabledFuture;
    final excludedPackages = await excludedPackagesFuture;

    await _notificationRepository
        .purgeOlderThan(SettingsRepository.defaultAutoDeleteDays);

    _liveSubscription?.cancel();
    _liveSubscription = _androidBridgeService.notifications.listen(
      _handleIncomingNotification,
      onError: (_) {},
    );

    final statuses = await _loadPermissionStatus();
    await _syncPendingNotifications();

    final notifications = await _notificationRepository.fetchNotifications();
    await splashDelay;
    if (!mounted) {
      return;
    }

    setState(() {
      _hasCompletedPermissionSetup = hasCompletedPermissionSetup &&
          statuses.notificationAccessEnabled &&
          statuses.batteryOptimizationIgnored;
      _darkModeEnabled = darkModeEnabled;
      _unreadFirstEnabled = unreadFirstEnabled;
      _appGroupingEnabled = appGroupingEnabled;
      _searchScope = SearchScope.values.firstWhere(
        (scope) => scope.name == searchScopeValue,
        orElse: () => SearchScope.fullContent,
      );
      _exactMatchSearchEnabled = exactMatchSearchEnabled;
      _excludedPackages = excludedPackages;
      _notificationAccessEnabled = statuses.notificationAccessEnabled;
      _batteryOptimizationIgnored = statuses.batteryOptimizationIgnored;
      _notifications = notifications;
      _isReady = true;
    });
  }

  Future<_PermissionSnapshot> _loadPermissionStatus() async {
    final notificationAccessEnabled =
        await _androidBridgeService.isNotificationAccessEnabled();
    final batteryOptimizationIgnored =
        await _androidBridgeService.isIgnoringBatteryOptimizations();

    return _PermissionSnapshot(
      notificationAccessEnabled: notificationAccessEnabled,
      batteryOptimizationIgnored: batteryOptimizationIgnored,
    );
  }

  Future<void> _refreshPermissionStatus() async {
    final statuses = await _loadPermissionStatus();
    final permissionsReady = statuses.notificationAccessEnabled &&
        statuses.batteryOptimizationIgnored;
    if (!permissionsReady) {
      await _settingsRepository.setPermissionsSetupCompleted(false);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _notificationAccessEnabled = statuses.notificationAccessEnabled;
      _batteryOptimizationIgnored = statuses.batteryOptimizationIgnored;
      _hasCompletedPermissionSetup =
          permissionsReady ? _hasCompletedPermissionSetup : false;
    });
  }

  Future<void> _handleIncomingNotification(
    SavedNotification notification, {
    bool reload = true,
  }) async {
    final excludedPackages = await _settingsRepository.getExcludedPackages();
    if (excludedPackages.contains(notification.packageName)) {
      return;
    }

    await _notificationRepository.saveNotification(notification);
    if (!reload) {
      return;
    }

    final notifications = await _notificationRepository.fetchNotifications();
    if (!mounted) {
      return;
    }
    setState(() {
      _notifications = notifications;
    });
  }

  Future<void> _refreshNotifications() async {
    final notifications = await _notificationRepository.fetchNotifications();
    if (!mounted) {
      return;
    }
    setState(() {
      _notifications = notifications;
    });
  }

  Future<void> _completePermissionSetup() async {
    await _refreshPermissionStatus();
    if (!_notificationAccessEnabled || !_batteryOptimizationIgnored) {
      return;
    }
    await _settingsRepository.setPermissionsSetupCompleted(true);
    if (!mounted) {
      return;
    }
    setState(() {
      _hasCompletedPermissionSetup = true;
    });
  }

  Future<void> _toggleFavorite(SavedNotification notification) async {
    await _notificationRepository.updateFavorite(
      notification.id!,
      !notification.isFavorite,
    );
    await _refreshNotifications();
  }

  Future<void> _markNotificationAsRead(SavedNotification notification) async {
    if (notification.id == null || notification.isRead) {
      return;
    }
    await _notificationRepository.updateRead(notification.id!, true);
    await _refreshNotifications();
  }

  Future<void> _deleteNotification(int id) async {
    await _notificationRepository.deleteNotification(id);
    await _refreshNotifications();
  }

  Future<void> _markAllNotificationsAsRead() async {
    await _notificationRepository.markAllAsRead();
    await _refreshNotifications();
  }

  Future<void> _toggleDarkMode(bool value) async {
    await _settingsRepository.setDarkModeEnabled(value);
    if (!mounted) {
      return;
    }
    setState(() {
      _darkModeEnabled = value;
    });
  }

  Future<void> _updateExcludedPackages(Set<String> value) async {
    await _settingsRepository.setExcludedPackages(value);
    await _refreshNotifications();
    if (!mounted) {
      return;
    }
    setState(() {
      _excludedPackages = value;
    });
  }

  Future<void> _updateUnreadFirstEnabled(bool value) async {
    await _settingsRepository.setUnreadFirstEnabled(value);
    if (!mounted) {
      return;
    }
    setState(() {
      _unreadFirstEnabled = value;
    });
  }

  Future<void> _updateAppGroupingEnabled(bool value) async {
    await _settingsRepository.setAppGroupingEnabled(value);
    if (!mounted) {
      return;
    }
    setState(() {
      _appGroupingEnabled = value;
    });
  }

  Future<void> _updateSearchScope(SearchScope value) async {
    await _settingsRepository.setSearchScope(value.name);
    if (!mounted) {
      return;
    }
    setState(() {
      _searchScope = value;
    });
  }

  Future<void> _updateExactMatchSearchEnabled(bool value) async {
    await _settingsRepository.setExactMatchSearchEnabled(value);
    if (!mounted) {
      return;
    }
    setState(() {
      _exactMatchSearchEnabled = value;
    });
  }

  Future<void> _navigateToDetail(SavedNotification notification) async {
    final navigator = Navigator.of(context);
    await _markNotificationAsRead(notification);
    final refreshedNotification = _notifications.firstWhere(
      (item) => item.id == notification.id,
      orElse: () => notification,
    );
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (context) => NotificationDetailScreen(
          notification: refreshedNotification,
          onDelete: () async {
            await _deleteNotification(refreshedNotification.id!);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          onToggleFavorite: () => _toggleFavorite(refreshedNotification),
        ),
      ),
    );
    await _refreshNotifications();
  }

  Future<void> _openAppFilter() async {
    final apps = await _androidBridgeService.getInstalledApps();
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AppFilterScreen(
          apps: apps,
          excludedPackages: _excludedPackages,
          onChanged: _updateExcludedPackages,
        ),
      ),
    );
    await _refreshNotifications();
  }

  Future<void> _handleResume() async {
    await _refreshPermissionStatus();
    await _syncPendingNotifications();
    await _refreshNotifications();
  }

  Future<void> _syncPendingNotifications() async {
    final pending = await _androidBridgeService.consumePendingNotifications();
    for (final notification in pending) {
      await _handleIncomingNotification(notification, reload: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotiSaver',
      debugShowCheckedModeBanner: false,
      themeMode: _darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme.copyWith(platform: TargetPlatform.android),
      darkTheme: AppTheme.darkTheme.copyWith(platform: TargetPlatform.android),
      home: !Platform.isAndroid
          ? const _AndroidOnlyScreen()
          : !_isReady
          ? const SplashScreen()
          : !_hasCompletedPermissionSetup
                  ? PermissionSetupScreen(
                      notificationAccessEnabled: _notificationAccessEnabled,
                      batteryOptimizationIgnored: _batteryOptimizationIgnored,
                      onOpenNotificationAccess: () async {
                        await _androidBridgeService
                            .openNotificationAccessSettings();
                      },
                      onOpenBatteryOptimization: () async {
                        await _androidBridgeService
                            .requestIgnoreBatteryOptimizations();
                      },
                      onContinue: _completePermissionSetup,
                    )
                  : HomeScreen(
                      notifications: _notifications
                          .where(
                            (notification) => !_excludedPackages
                                .contains(notification.packageName),
                          )
                          .toList(),
                      onRefresh: () async {
                        await _refreshNotifications();
                        await _refreshPermissionStatus();
                      },
                      onToggleFavorite: _toggleFavorite,
                      onMarkAllAsRead: _markAllNotificationsAsRead,
                      onOpenDetail: _navigateToDetail,
                      darkModeEnabled: _darkModeEnabled,
                      excludedAppsCount: _excludedPackages.length,
                      unreadFirstEnabled: _unreadFirstEnabled,
                      appGroupingEnabled: _appGroupingEnabled,
                      searchScope: _searchScope,
                      exactMatchSearchEnabled: _exactMatchSearchEnabled,
                      notificationAccessEnabled: _notificationAccessEnabled,
                      batteryOptimizationIgnored: _batteryOptimizationIgnored,
                      onDarkModeChanged: _toggleDarkMode,
                      onUnreadFirstChanged: _updateUnreadFirstEnabled,
                      onAppGroupingChanged: _updateAppGroupingEnabled,
                      onSearchScopeChanged: _updateSearchScope,
                      onExactMatchSearchChanged:
                          _updateExactMatchSearchEnabled,
                      onOpenNotificationAccess: () async {
                        await _androidBridgeService
                            .openNotificationAccessSettings();
                        await _refreshPermissionStatus();
                      },
                      onOpenBatteryOptimization: () async {
                        await _androidBridgeService
                            .requestIgnoreBatteryOptimizations();
                        await _refreshPermissionStatus();
                      },
                      onOpenAppFilter: _openAppFilter,
                      onLoadReliabilityStatus:
                          _androidBridgeService.getReliabilityStatus,
                      onRefreshListenerBinding:
                          _androidBridgeService.refreshListenerBinding,
                    ),
    );
  }
}

class _PermissionSnapshot {
  const _PermissionSnapshot({
    required this.notificationAccessEnabled,
    required this.batteryOptimizationIgnored,
  });

  final bool notificationAccessEnabled;
  final bool batteryOptimizationIgnored;
}

class _AndroidOnlyScreen extends StatelessWidget {
  const _AndroidOnlyScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.android_rounded,
                size: 72,
                color: Color(0xFF3DDC84),
              ),
              const SizedBox(height: 20),
              Text(
                'Android Only',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'NotiSaver is built specifically for Android notification access and background capture.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
