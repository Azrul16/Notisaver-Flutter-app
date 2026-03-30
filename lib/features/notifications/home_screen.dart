import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/saved_notification.dart';
import '../../services/android_bridge_service.dart';
import 'notification_history_screen.dart';

enum HomeSection { messages, apps, settings }

enum MessageTab { unread, read, all }

enum SmartFilter { all, messages, calls, otp, social }

enum SearchScope { fullContent, titleOnly, appNames }

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.notifications,
    required this.onRefresh,
    required this.onToggleFavorite,
    required this.onMarkAllAsRead,
    required this.onOpenDetail,
    required this.darkModeEnabled,
    required this.excludedAppsCount,
    required this.unreadFirstEnabled,
    required this.appGroupingEnabled,
    required this.searchScope,
    required this.exactMatchSearchEnabled,
    required this.notificationAccessEnabled,
    required this.batteryOptimizationIgnored,
    required this.onDarkModeChanged,
    required this.onUnreadFirstChanged,
    required this.onAppGroupingChanged,
    required this.onSearchScopeChanged,
    required this.onExactMatchSearchChanged,
    required this.onOpenNotificationAccess,
    required this.onOpenBatteryOptimization,
    required this.onOpenAppFilter,
    required this.onLoadReliabilityStatus,
    required this.onRefreshListenerBinding,
  });

  final List<SavedNotification> notifications;
  final Future<void> Function() onRefresh;
  final Future<void> Function(SavedNotification notification) onToggleFavorite;
  final Future<void> Function() onMarkAllAsRead;
  final Future<void> Function(SavedNotification notification) onOpenDetail;
  final bool darkModeEnabled;
  final int excludedAppsCount;
  final bool unreadFirstEnabled;
  final bool appGroupingEnabled;
  final SearchScope searchScope;
  final bool exactMatchSearchEnabled;
  final bool notificationAccessEnabled;
  final bool batteryOptimizationIgnored;
  final Future<void> Function(bool value) onDarkModeChanged;
  final Future<void> Function(bool value) onUnreadFirstChanged;
  final Future<void> Function(bool value) onAppGroupingChanged;
  final Future<void> Function(SearchScope value) onSearchScopeChanged;
  final Future<void> Function(bool value) onExactMatchSearchChanged;
  final Future<void> Function() onOpenNotificationAccess;
  final Future<void> Function() onOpenBatteryOptimization;
  final Future<void> Function() onOpenAppFilter;
  final Future<BackgroundReliabilityStatus> Function() onLoadReliabilityStatus;
  final Future<void> Function() onRefreshListenerBinding;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  HomeSection _selectedSection = HomeSection.messages;
  MessageTab _selectedMessageTab = MessageTab.unread;
  SmartFilter _selectedSmartFilter = SmartFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final indexedNotifications = _indexNotifications(widget.notifications);
    final messageGroups = _messageGroups(indexedNotifications);
    final appGroups = _appGroups(indexedNotifications);

    return Scaffold(
      backgroundColor: palette.scaffold,
      appBar: AppBar(
        backgroundColor: palette.scaffold,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        titleSpacing: 20,
        title: Text(
          switch (_selectedSection) {
            HomeSection.messages => 'Messages',
            HomeSection.apps => 'Notifications',
            HomeSection.settings => 'Settings',
          },
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: palette.accent,
          onRefresh: widget.onRefresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 120),
            children: <Widget>[
              if (_selectedSection == HomeSection.messages) ...<Widget>[
                _MessageFilterBar(
                  palette: palette,
                  selectedTab: _selectedMessageTab,
                  onSelected: (tab) => setState(() {
                    _selectedMessageTab = tab;
                  }),
                ),
                const SizedBox(height: 10),
                _SmartFilterBar(
                  palette: palette,
                  selectedFilter: _selectedSmartFilter,
                  onSelected: (filter) => setState(() {
                    _selectedSmartFilter = filter;
                  }),
                ),
                const SizedBox(height: 14),
              ],
              if (_selectedSection != HomeSection.settings) ...<Widget>[
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[palette.panelStart, palette.panelEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: palette.border),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: palette.shadow,
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: palette.textPrimary),
                    decoration: InputDecoration(
                      hintText: _selectedSection == HomeSection.messages
                          ? 'Search people or messages'
                          : 'Search apps or notifications',
                      hintStyle: TextStyle(
                        color: palette.textPrimary.withValues(alpha: 0.45),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: palette.textSecondary,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide(
                          color: palette.accent.withValues(alpha: 0.33),
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 240.ms).slideY(begin: 0.08, end: 0),
                const SizedBox(height: 18),
              ],
              if (_selectedSection == HomeSection.messages)
                if (messageGroups.isEmpty)
                  const _EmptyState(
                    title: 'No messages yet',
                    subtitle: 'Saved messages will appear here.',
                  )
                else
                  ..._buildGroupTiles(palette, messageGroups)
              else if (_selectedSection == HomeSection.apps && appGroups.isEmpty)
                const _EmptyState(
                  title: 'No notifications yet',
                  subtitle: 'Saved notifications will appear here.',
                )
              else if (_selectedSection == HomeSection.apps)
                ..._buildGroupTiles(palette, appGroups, appOnly: true)
              else
                _SettingsTabView(
                  darkModeEnabled: widget.darkModeEnabled,
                  excludedAppsCount: widget.excludedAppsCount,
                  notifications: widget.notifications,
                  unreadFirstEnabled: widget.unreadFirstEnabled,
                  appGroupingEnabled: widget.appGroupingEnabled,
                  searchScope: widget.searchScope,
                  exactMatchSearchEnabled: widget.exactMatchSearchEnabled,
                  notificationAccessEnabled: widget.notificationAccessEnabled,
                  batteryOptimizationIgnored: widget.batteryOptimizationIgnored,
                  onDarkModeChanged: widget.onDarkModeChanged,
                  onUnreadFirstChanged: widget.onUnreadFirstChanged,
                  onAppGroupingChanged: widget.onAppGroupingChanged,
                  onSearchScopeChanged: widget.onSearchScopeChanged,
                  onExactMatchSearchChanged:
                      widget.onExactMatchSearchChanged,
                  onOpenNotificationAccess: widget.onOpenNotificationAccess,
                  onOpenBatteryOptimization: widget.onOpenBatteryOptimization,
                  onOpenAppFilter: widget.onOpenAppFilter,
                  onLoadReliabilityStatus: widget.onLoadReliabilityStatus,
                  onRefreshListenerBinding: widget.onRefreshListenerBinding,
                ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.06, end: 0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 74,
        backgroundColor: palette.panelEnd,
        indicatorColor: palette.accentSoft,
        selectedIndex: _selectedSection.index,
        onDestinationSelected: (index) {
          setState(() {
            _selectedSection = HomeSection.values[index];
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Apps',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _selectedSection == HomeSection.settings
          ? null
          : _AnimatedMarkReadButton(
              palette: palette,
              enabled: widget.notifications.isEmpty == false,
              onPressed: _handleMarkAllAsRead,
            ),
    );
  }

  Future<void> _handleMarkAllAsRead() async {
    await widget.onMarkAllAsRead();
    if (!mounted) return;

    setState(() {
      if (_selectedSection == HomeSection.messages &&
          _selectedMessageTab == MessageTab.unread) {
        _selectedMessageTab = MessageTab.all;
      }
    });
  }

  Future<void> _openHistory({
    required String title,
    required String subtitle,
    required String? appIconPath,
    required String? avatarPath,
    required List<SavedNotification> notifications,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => NotificationHistoryScreen(
          title: title,
          subtitle: subtitle,
          appIconPath: appIconPath,
          avatarPath: avatarPath,
          notifications: notifications,
          onOpenDetail: widget.onOpenDetail,
        ),
      ),
    );
  }

  List<Widget> _buildGroupTiles(
    AppPalette palette,
    List<_Group> groups, {
    bool appOnly = false,
  }) {
    return groups
        .asMap()
        .entries
        .map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ConversationTile(
              palette: palette,
              title: entry.value.title,
              subtitle: entry.value.subtitle,
              preview: entry.value.preview,
              time: entry.value.time,
              badgeText: appOnly
                  ? '${entry.value.notifications.length}'
                  : entry.value.unreadCount > 0
                      ? '${entry.value.unreadCount}'
                      : '.',
              avatarPath: entry.value.avatarPath,
              appIconPath: entry.value.appIconPath,
              appOnly: appOnly,
              isUnread: entry.value.unreadCount > 0,
              isPinned: entry.value.hasFavorite,
              onTap: () => _openHistory(
                title: entry.value.title,
                subtitle: entry.value.subtitle,
                appIconPath: entry.value.appIconPath,
                avatarPath: appOnly ? null : entry.value.avatarPath,
                notifications: entry.value.notifications,
              ),
            ).animate(delay: (entry.key * 35).ms).fadeIn(duration: 220.ms).slideY(begin: 0.10, end: 0),
          ),
        )
        .toList();
  }

  List<_Group> _messageGroups(List<_IndexedNotification> notifications) {
    final query = _searchController.text.trim();
    final groups = <String, List<SavedNotification>>{};
    for (final indexed in notifications) {
      final notification = indexed.notification;
      if (!_matchesSmartFilter(indexed)) continue;
      final matchesTab = switch (_selectedMessageTab) {
        MessageTab.unread => !notification.isRead,
        MessageTab.read => notification.isRead,
        MessageTab.all => true,
      };
      if (!matchesTab) continue;
      if (!_matchesSearch(indexed, query)) continue;
      final key = '${notification.packageName}|${indexed.normalizedTitle}';
      groups.putIfAbsent(key, () => <SavedNotification>[]).add(notification);
    }
    return _mapGroups(groups, query, subtitleBuilder: (latest, items) => latest.appName);
  }

  List<_Group> _appGroups(List<_IndexedNotification> notifications) {
    final query = _searchController.text.trim();
    final groups = <String, List<SavedNotification>>{};
    for (final indexed in notifications) {
      final notification = indexed.notification;
      if (!_matchesSearch(indexed, query)) continue;
      final key = widget.appGroupingEnabled
          ? notification.packageName
          : '${notification.notificationKey}|${notification.timestamp.millisecondsSinceEpoch}';
      groups.putIfAbsent(key, () => <SavedNotification>[]).add(notification);
    }
    return _mapGroups(
      groups,
      query,
      titleBuilder: (latest, items) =>
          widget.appGroupingEnabled ? latest.appName : _title(latest),
      subtitleBuilder: (latest, items) => widget.appGroupingEnabled
          ? '${items.length} notifications'
          : latest.appName,
    );
  }

  List<_Group> _mapGroups(
    Map<String, List<SavedNotification>> groups,
    String query, {
    String Function(SavedNotification latest, List<SavedNotification> items)? titleBuilder,
    required String Function(SavedNotification latest, List<SavedNotification> items)
        subtitleBuilder,
  }) {
    final result = groups.entries.map((entry) {
      final items = entry.value..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final latest = items.first;
      final title = titleBuilder?.call(latest, items) ?? _title(latest);
      return _Group(
        title: title,
        subtitle: subtitleBuilder(latest, items),
        preview: latest.message.isNotEmpty ? latest.message : latest.subText,
        time: latest.timestamp,
        avatarPath: latest.avatarPath,
        appIconPath: latest.appIconPath,
        unreadCount: items.where((item) => !item.isRead).length,
        hasFavorite: items.any((item) => item.isFavorite),
        notifications: items,
      );
    }).whereType<_Group>().toList()
      ..sort((a, b) {
        final favoriteOrder = (b.hasFavorite ? 1 : 0) - (a.hasFavorite ? 1 : 0);
        if (favoriteOrder != 0) return favoriteOrder;
        if (widget.unreadFirstEnabled) {
          final unreadOrder =
              ((b.unreadCount > 0) ? 1 : 0) - ((a.unreadCount > 0) ? 1 : 0);
          if (unreadOrder != 0) return unreadOrder;
        }
        return b.time.compareTo(a.time);
      });
    return result;
  }

  String _title(SavedNotification notification) {
    final title = notification.title.trim();
    return title.isEmpty ? notification.appName : title;
  }

  List<_IndexedNotification> _indexNotifications(
    List<SavedNotification> notifications,
  ) {
    return notifications
        .map((notification) => _IndexedNotification.from(notification))
        .toList(growable: false);
  }

  bool _matchesSmartFilter(_IndexedNotification notification) {
    return switch (_selectedSmartFilter) {
      SmartFilter.all => true,
      SmartFilter.messages => notification.isMessageLike,
      SmartFilter.calls => notification.isCallLike,
      SmartFilter.otp => notification.isOtpLike,
      SmartFilter.social => notification.isSocialLike,
    };
  }

  bool _matchesSearch(_IndexedNotification notification, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return true;
    }

    final haystacks = switch (widget.searchScope) {
      SearchScope.fullContent => <String>[notification.searchableFull],
      SearchScope.titleOnly => <String>[notification.searchableTitle],
      SearchScope.appNames => <String>[notification.searchableApp],
    };

    return haystacks.any((value) {
      if (widget.exactMatchSearchEnabled) return value == normalizedQuery;
      return value.contains(normalizedQuery);
    });
  }
}

class _SettingsTabView extends StatefulWidget {
  const _SettingsTabView({
    required this.darkModeEnabled,
    required this.excludedAppsCount,
    required this.notifications,
    required this.unreadFirstEnabled,
    required this.appGroupingEnabled,
    required this.searchScope,
    required this.exactMatchSearchEnabled,
    required this.notificationAccessEnabled,
    required this.batteryOptimizationIgnored,
    required this.onDarkModeChanged,
    required this.onUnreadFirstChanged,
    required this.onAppGroupingChanged,
    required this.onSearchScopeChanged,
    required this.onExactMatchSearchChanged,
    required this.onOpenNotificationAccess,
    required this.onOpenBatteryOptimization,
    required this.onOpenAppFilter,
    required this.onLoadReliabilityStatus,
    required this.onRefreshListenerBinding,
  });

  final bool darkModeEnabled;
  final int excludedAppsCount;
  final List<SavedNotification> notifications;
  final bool unreadFirstEnabled;
  final bool appGroupingEnabled;
  final SearchScope searchScope;
  final bool exactMatchSearchEnabled;
  final bool notificationAccessEnabled;
  final bool batteryOptimizationIgnored;
  final Future<void> Function(bool value) onDarkModeChanged;
  final Future<void> Function(bool value) onUnreadFirstChanged;
  final Future<void> Function(bool value) onAppGroupingChanged;
  final Future<void> Function(SearchScope value) onSearchScopeChanged;
  final Future<void> Function(bool value) onExactMatchSearchChanged;
  final Future<void> Function() onOpenNotificationAccess;
  final Future<void> Function() onOpenBatteryOptimization;
  final Future<void> Function() onOpenAppFilter;
  final Future<BackgroundReliabilityStatus> Function() onLoadReliabilityStatus;
  final Future<void> Function() onRefreshListenerBinding;

  @override
  State<_SettingsTabView> createState() => _SettingsTabViewState();
}

class _SettingsTabViewState extends State<_SettingsTabView> {
  BackgroundReliabilityStatus? _reliabilityStatus;
  bool _loadingReliability = true;
  late int _excludedAppsCount;
  late bool _unreadFirstEnabled;
  late bool _appGroupingEnabled;
  late SearchScope _searchScope;
  late bool _exactMatchSearchEnabled;

  @override
  void initState() {
    super.initState();
    _excludedAppsCount = widget.excludedAppsCount;
    _unreadFirstEnabled = widget.unreadFirstEnabled;
    _appGroupingEnabled = widget.appGroupingEnabled;
    _searchScope = widget.searchScope;
    _exactMatchSearchEnabled = widget.exactMatchSearchEnabled;
    _loadReliability();
  }

  @override
  void didUpdateWidget(covariant _SettingsTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.excludedAppsCount != widget.excludedAppsCount) {
      _excludedAppsCount = widget.excludedAppsCount;
    }
    if (oldWidget.unreadFirstEnabled != widget.unreadFirstEnabled) {
      _unreadFirstEnabled = widget.unreadFirstEnabled;
    }
    if (oldWidget.appGroupingEnabled != widget.appGroupingEnabled) {
      _appGroupingEnabled = widget.appGroupingEnabled;
    }
    if (oldWidget.searchScope != widget.searchScope) {
      _searchScope = widget.searchScope;
    }
    if (oldWidget.exactMatchSearchEnabled != widget.exactMatchSearchEnabled) {
      _exactMatchSearchEnabled = widget.exactMatchSearchEnabled;
    }
  }

  Future<void> _loadReliability() async {
    if (mounted) {
      setState(() {
        _loadingReliability = true;
      });
    }
    final status = await widget.onLoadReliabilityStatus();
    if (!mounted) return;
    setState(() {
      _reliabilityStatus = status;
      _loadingReliability = false;
    });
  }

  Future<void> _refreshListener() async {
    await widget.onRefreshListenerBinding();
    await _loadReliability();
  }

  Future<void> _openAppFilter() async {
    await widget.onOpenAppFilter();
    if (!mounted) return;
    setState(() {
      _excludedAppsCount = widget.excludedAppsCount;
    });
  }

  Future<void> _toggleUnreadFirst(bool value) async {
    await widget.onUnreadFirstChanged(value);
    if (!mounted) {
      return;
    }
    setState(() {
      _unreadFirstEnabled = value;
    });
  }

  Future<void> _toggleAppGrouping(bool value) async {
    await widget.onAppGroupingChanged(value);
    if (!mounted) {
      return;
    }
    setState(() {
      _appGroupingEnabled = value;
    });
  }

  Future<void> _changeSearchScope(SearchScope value) async {
    await widget.onSearchScopeChanged(value);
    if (!mounted) {
      return;
    }
    setState(() {
      _searchScope = value;
    });
  }

  Future<void> _toggleExactMatchSearch(bool value) async {
    await widget.onExactMatchSearchChanged(value);
    if (!mounted) {
      return;
    }
    setState(() {
      _exactMatchSearchEnabled = value;
    });
  }

  _NotificationInsights get _insights {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final savedToday = widget.notifications
        .where((notification) => notification.timestamp.isAfter(startOfToday))
        .length;
    final unreadCount =
        widget.notifications.where((notification) => !notification.isRead).length;
    final favoriteCount = widget.notifications
        .where((notification) => notification.isFavorite)
        .length;
    final countsByApp = <String, int>{};
    for (final notification in widget.notifications) {
      countsByApp.update(notification.appName, (count) => count + 1,
          ifAbsent: () => 1);
    }
    String? mostActiveApp;
    int mostActiveCount = 0;
    countsByApp.forEach((appName, count) {
      if (count > mostActiveCount) {
        mostActiveApp = appName;
        mostActiveCount = count;
      }
    });
    return _NotificationInsights(
      savedToday: savedToday,
      unreadCount: unreadCount,
      favoriteCount: favoriteCount,
      totalCount: widget.notifications.length,
      mostActiveApp: mostActiveApp,
      mostActiveCount: mostActiveCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final insights = _insights;
    return Column(
      children: <Widget>[
        _BrandSettingsCard(palette: palette),
        const SizedBox(height: 14),
        _SectionCard(
          palette: palette,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _SectionHeader(
                palette: palette,
                icon: Icons.palette_rounded,
                title: 'Appearance',
                subtitle: 'Switch the overall mood of NotiSaver.',
              ),
              const SizedBox(height: 14),
              SegmentedButton<bool>(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) => states.contains(WidgetState.selected)
                        ? palette.accent.withValues(alpha: 0.18)
                        : palette.surfaceAlt.withValues(alpha: 0.75),
                  ),
                  foregroundColor:
                      WidgetStatePropertyAll<Color>(palette.textPrimary),
                  side: WidgetStatePropertyAll<BorderSide?>(
                    BorderSide(color: palette.border),
                  ),
                ),
                segments: const <ButtonSegment<bool>>[
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_rounded),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_rounded),
                  ),
                ],
                selected: <bool>{widget.darkModeEnabled},
                onSelectionChanged: (selection) {
                  widget.onDarkModeChanged(selection.first);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          palette: palette,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _SectionHeader(
                palette: palette,
                icon: Icons.auto_awesome_rounded,
                title: 'Smart organization',
                subtitle: 'Shape how threads and app feeds behave.',
              ),
              const SizedBox(height: 16),
              _SettingOptionTile(
                palette: palette,
                icon: Icons.mark_chat_unread_rounded,
                title: 'Unread first',
                subtitle: 'Keep unread groups above older read threads.',
                trailing: Switch(
                  value: _unreadFirstEnabled,
                  onChanged: _toggleUnreadFirst,
                ),
              ),
              const SizedBox(height: 12),
              _SettingOptionTile(
                palette: palette,
                icon: Icons.view_stream_rounded,
                title: 'Group apps together',
                subtitle:
                    'Show one app card per package instead of individual notifications.',
                trailing: Switch(
                  value: _appGroupingEnabled,
                  onChanged: _toggleAppGrouping,
                ),
              ),
              const SizedBox(height: 12),
              _SettingOptionTile(
                palette: palette,
                icon: Icons.filter_list_rounded,
                title: 'Quick filters',
                subtitle: 'Fast shortcuts for common message categories.',
                trailing: _StatusBadge(
                  palette: palette,
                  label: 'Enabled',
                  accent: true,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const <String>[
                  'Messages',
                  'Calls',
                  'OTP',
                  'Social',
                ]
                    .map(
                      (label) => Chip(
                        avatar: Icon(
                          switch (label) {
                            'Messages' => Icons.chat_bubble_rounded,
                            'Calls' => Icons.call_rounded,
                            'OTP' => Icons.password_rounded,
                            _ => Icons.public_rounded,
                          },
                          size: 16,
                          color: palette.accent,
                        ),
                        backgroundColor: palette.surfaceAlt,
                        side: BorderSide(color: palette.border),
                        label: Text(label),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          palette: palette,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _SectionHeader(
                palette: palette,
                icon: Icons.manage_search_rounded,
                title: 'Search preferences',
                subtitle:
                    'Choose where queries look and whether they must match exactly.',
              ),
              const SizedBox(height: 16),
              SegmentedButton<SearchScope>(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) => states.contains(WidgetState.selected)
                        ? palette.accent.withValues(alpha: 0.18)
                        : palette.surfaceAlt.withValues(alpha: 0.75),
                  ),
                  foregroundColor:
                      WidgetStatePropertyAll<Color>(palette.textPrimary),
                  side: WidgetStatePropertyAll<BorderSide?>(
                    BorderSide(color: palette.border),
                  ),
                ),
                segments: const <ButtonSegment<SearchScope>>[
                  ButtonSegment<SearchScope>(
                    value: SearchScope.fullContent,
                    label: Text('Full'),
                    icon: Icon(Icons.notes_rounded),
                  ),
                  ButtonSegment<SearchScope>(
                    value: SearchScope.titleOnly,
                    label: Text('Title'),
                    icon: Icon(Icons.title_rounded),
                  ),
                  ButtonSegment<SearchScope>(
                    value: SearchScope.appNames,
                    label: Text('Apps'),
                    icon: Icon(Icons.apps_rounded),
                  ),
                ],
                selected: <SearchScope>{_searchScope},
                onSelectionChanged: (selection) {
                  _changeSearchScope(selection.first);
                },
              ),
              const SizedBox(height: 10),
              _SettingOptionTile(
                palette: palette,
                icon: Icons.gps_fixed_rounded,
                title: 'Exact match mode',
                subtitle:
                    'Only return results that exactly match the search text.',
                trailing: Switch(
                  value: _exactMatchSearchEnabled,
                  onChanged: _toggleExactMatchSearch,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          palette: palette,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _SectionHeader(
                palette: palette,
                icon: Icons.insights_rounded,
                title: 'Notification insights',
                subtitle: 'A quick look at today’s activity and trends.',
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  _InsightChip(
                    label: 'Saved today',
                    value: '${insights.savedToday}',
                  ),
                  _InsightChip(
                    label: 'Unread',
                    value: '${insights.unreadCount}',
                  ),
                  _InsightChip(
                    label: 'Favorites',
                    value: '${insights.favoriteCount}',
                  ),
                  _InsightChip(
                    label: 'Total',
                    value: '${insights.totalCount}',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: palette.surfaceAlt,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.insights_rounded, color: palette.accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Most active app',
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            insights.mostActiveApp ?? 'No notifications yet',
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      insights.mostActiveApp == null
                          ? '--'
                          : '${insights.mostActiveCount}',
                      style: TextStyle(
                        color: palette.accent,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          palette: palette,
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              _SettingActionTile(
                palette: palette,
                icon: Icons.notifications_active_rounded,
                title: 'Notification access',
                subtitle: widget.notificationAccessEnabled
                    ? 'Connected and ready'
                    : 'Needs permission',
                statusLabel: widget.notificationAccessEnabled ? 'On' : 'Off',
                accentStatus: widget.notificationAccessEnabled,
                onPressed: widget.onOpenNotificationAccess,
                buttonLabel: 'Open',
              ),
              Divider(height: 1, color: palette.surfaceStrong),
              _SettingActionTile(
                palette: palette,
                icon: Icons.battery_charging_full_rounded,
                title: 'Battery optimization',
                subtitle: widget.batteryOptimizationIgnored
                    ? 'Background capture is protected'
                    : 'May interrupt background saving',
                statusLabel:
                    widget.batteryOptimizationIgnored ? 'Off' : 'On',
                accentStatus: widget.batteryOptimizationIgnored,
                onPressed: widget.onOpenBatteryOptimization,
                buttonLabel: 'Open',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          palette: palette,
          padding: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: _openAppFilter,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[palette.accentSoft, palette.surfaceAlt],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.apps_rounded, color: palette.accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'App filter',
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            _StatusBadge(
                              palette: palette,
                              label: _excludedAppsCount == 0
                                  ? 'All apps'
                                  : '$_excludedAppsCount hidden',
                              accent: _excludedAppsCount > 0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _excludedAppsCount == 0
                              ? 'Everything is currently allowed.'
                              : 'Choose which apps should stay out of NotiSaver.',
                          style: TextStyle(color: palette.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _openAppFilter,
                    child: const Text('Manage'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          palette: palette,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _SectionHeader(
                palette: palette,
                icon: Icons.health_and_safety_rounded,
                title: 'Background reliability',
                subtitle: 'Keep an eye on listener health and sync state.',
                trailing: IconButton(
                  onPressed: _loadingReliability ? null : _loadReliability,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ),
              const SizedBox(height: 10),
              if (_loadingReliability)
                const LinearProgressIndicator()
              else ...<Widget>[
                _SettingOptionTile(
                  palette: palette,
                  icon: Icons.link_rounded,
                  title: 'Listener connected',
                  subtitle: _formatTimestamp(
                    _reliabilityStatus?.lastListenerConnectedAt,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingOptionTile(
                  palette: palette,
                  icon: Icons.download_done_rounded,
                  title: 'Last notification saved',
                  subtitle: _formatTimestamp(
                    _reliabilityStatus?.lastNotificationCapturedAt,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingOptionTile(
                  palette: palette,
                  icon: Icons.sync_rounded,
                  title: 'Pending sync',
                  subtitle: '${_reliabilityStatus?.pendingCount ?? 0} waiting',
                  trailing: _StatusBadge(
                    palette: palette,
                    label: '${_reliabilityStatus?.pendingCount ?? 0}',
                    accent: (_reliabilityStatus?.pendingCount ?? 0) > 0,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _refreshListener,
                  icon: const Icon(Icons.sync_rounded),
                  label: const Text('Refresh listener'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime? value) {
    if (value == null) return 'Not yet';
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'pm' : 'am';
    return '${local.day}/${local.month}/${local.year}  $hour:$minute $suffix';
  }
}

class _Group {
  const _Group({
    required this.title,
    required this.subtitle,
    required this.preview,
    required this.time,
    required this.avatarPath,
    required this.appIconPath,
    required this.unreadCount,
    required this.hasFavorite,
    required this.notifications,
  });

  final String title;
  final String subtitle;
  final String preview;
  final DateTime time;
  final String? avatarPath;
  final String? appIconPath;
  final int unreadCount;
  final bool hasFavorite;
  final List<SavedNotification> notifications;
}

class _IndexedNotification {
  const _IndexedNotification({
    required this.notification,
    required this.normalizedTitle,
    required this.searchableFull,
    required this.searchableTitle,
    required this.searchableApp,
    required this.isMessageLike,
    required this.isCallLike,
    required this.isOtpLike,
    required this.isSocialLike,
  });

  final SavedNotification notification;
  final String normalizedTitle;
  final String searchableFull;
  final String searchableTitle;
  final String searchableApp;
  final bool isMessageLike;
  final bool isCallLike;
  final bool isOtpLike;
  final bool isSocialLike;

  factory _IndexedNotification.from(SavedNotification notification) {
    final packageName = notification.packageName.toLowerCase();
    final category = notification.category?.toLowerCase() ?? '';
    final title = notification.title.trim().toLowerCase();
    final appName = notification.appName.trim().toLowerCase();
    final message = notification.message.trim().toLowerCase();
    final subText = notification.subText.trim().toLowerCase();
    final combinedText = '$title $message $subText';
    const messageKeywords = <String>[
      'whatsapp',
      'messenger',
      'telegram',
      'imo',
      'facebook.orca',
      'sms',
      'message',
      'chat',
      'instagram',
      'missed call',
      'call',
      'signal',
      'discord',
    ];
    const socialPackages = <String>[
      'facebook',
      'instagram',
      'twitter',
      'x.com',
      'snapchat',
      'discord',
      'reddit',
      'linkedin',
      'tiktok',
    ];

    return _IndexedNotification(
      notification: notification,
      normalizedTitle: title.isEmpty ? appName : title,
      searchableFull: '$title $message $subText $appName',
      searchableTitle: title,
      searchableApp: appName,
      isMessageLike: category.contains('msg') ||
          category.contains('social') ||
          messageKeywords.any(packageName.contains) ||
          messageKeywords.any(combinedText.contains),
      isCallLike: category.contains('call') ||
          combinedText.contains('missed call') ||
          combinedText.contains('incoming call') ||
          combinedText.contains('voice call'),
      isOtpLike: combinedText.contains('otp') ||
          combinedText.contains('verification code') ||
          combinedText.contains('one-time password') ||
          RegExp(r'\b\d{4,8}\b').hasMatch(combinedText),
      isSocialLike: socialPackages.any(packageName.contains),
    );
  }
}

class _AnimatedMarkReadButton extends StatelessWidget {
  const _AnimatedMarkReadButton({
    required this.palette,
    required this.enabled,
    required this.onPressed,
  });

  final AppPalette palette;
  final bool enabled;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      child: Icon(
        Icons.check_rounded,
        color: Colors.white.withValues(alpha: enabled ? 1 : 0.7),
        size: 30,
      ),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: enabled
                    ? <Color>[palette.accent, palette.accentWarm]
                    : <Color>[
                        palette.badgeIdleBorder,
                        palette.badgeIdle,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: (enabled ? palette.accent : palette.shadow)
                      .withValues(alpha: 0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: enabled ? onPressed : null,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    child!,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BrandSettingsCard extends StatelessWidget {
  const _BrandSettingsCard({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[palette.heroStart, palette.heroEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: palette.shadow,
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'AppIcons/appstore.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'NotiSaver',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Clean, searchable notification history for your daily apps.',
                    style: TextStyle(
                      color: palette.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.palette,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final AppPalette palette;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: palette.accentSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: palette.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: palette.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

class _SettingOptionTile extends StatelessWidget {
  const _SettingOptionTile({
    required this.palette,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final AppPalette palette;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: palette.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: palette.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _SettingActionTile extends StatelessWidget {
  const _SettingActionTile({
    required this.palette,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.accentStatus,
    required this.onPressed,
    required this.buttonLabel,
  });

  final AppPalette palette;
  final IconData icon;
  final String title;
  final String subtitle;
  final String statusLabel;
  final bool accentStatus;
  final Future<void> Function() onPressed;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: palette.accentSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: palette.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _StatusBadge(
                      palette: palette,
                      label: statusLabel,
                      accent: accentStatus,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: palette.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: onPressed,
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.palette,
    required this.label,
    this.accent = false,
  });

  final AppPalette palette;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent ? palette.accentSoft : palette.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent ? palette.accent.withValues(alpha: 0.4) : palette.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent ? palette.accent : palette.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.palette,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final AppPalette palette;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[palette.panelStart, palette.panelEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: palette.shadow,
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _NotificationInsights {
  const _NotificationInsights({
    required this.savedToday,
    required this.unreadCount,
    required this.favoriteCount,
    required this.totalCount,
    required this.mostActiveApp,
    required this.mostActiveCount,
  });

  final int savedToday;
  final int unreadCount;
  final int favoriteCount;
  final int totalCount;
  final String? mostActiveApp;
  final int mostActiveCount;
}

class _MessageFilterBar extends StatelessWidget {
  const _MessageFilterBar({
    required this.palette,
    required this.selectedTab,
    required this.onSelected,
  });

  final AppPalette palette;
  final MessageTab selectedTab;
  final ValueChanged<MessageTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[palette.panelStart, palette.panelEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: palette.shadow,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
                children: MessageTab.values
            .map(
              (tab) => _FilterChipButton(
                palette: palette,
                label: switch (tab) {
                  MessageTab.unread => 'Unread',
                  MessageTab.read => 'Read',
                  MessageTab.all => 'All',
                },
                selected: selectedTab == tab,
                onTap: () => onSelected(tab),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SmartFilterBar extends StatelessWidget {
  const _SmartFilterBar({
    required this.palette,
    required this.selectedFilter,
    required this.onSelected,
  });

  final AppPalette palette;
  final SmartFilter selectedFilter;
  final ValueChanged<SmartFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SmartFilter.values
          .map(
            (filter) => _FilterChipButton(
              palette: palette,
              label: switch (filter) {
                SmartFilter.all => 'All',
                SmartFilter.messages => 'Messages',
                SmartFilter.calls => 'Calls',
                SmartFilter.otp => 'OTP',
                SmartFilter.social => 'Social',
              },
              selected: selectedFilter == filter,
              onTap: () => onSelected(filter),
            ),
          )
          .toList(),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.palette,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppPalette palette;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: selected
              ? LinearGradient(
                  colors: <Color>[palette.accent, palette.accentWarm],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : palette.scaffold,
          border: Border.all(
            color: selected ? Colors.transparent : palette.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.notifications_off_rounded,
            color: palette.textSecondary,
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: palette.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.palette,
    required this.title,
    required this.subtitle,
    required this.preview,
    required this.time,
    required this.badgeText,
    required this.avatarPath,
    required this.appIconPath,
    required this.onTap,
    this.appOnly = false,
    this.isUnread = false,
    this.isPinned = false,
  });

  final AppPalette palette;
  final String title;
  final String subtitle;
  final String preview;
  final DateTime time;
  final String badgeText;
  final String? avatarPath;
  final String? appIconPath;
  final VoidCallback onTap;
  final bool appOnly;
  final bool isUnread;
  final bool isPinned;

  @override
  Widget build(BuildContext context) {
    final previewColor = isUnread
        ? palette.textPrimary.withValues(alpha: 0.96)
        : palette.textSecondary;
    final tileGradient = appOnly
        ? <Color>[
            palette.tileAltStart,
            palette.tileAltEnd,
          ]
        : <Color>[
            palette.tileStart,
            palette.tileEnd,
          ];

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isUnread
                  ? <Color>[
                      palette.accent.withValues(alpha: 0.16),
                      tileGradient.last,
                    ]
                  : tileGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isUnread
                  ? palette.accent.withValues(alpha: 0.65)
                  : palette.border,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: isUnread
                    ? palette.accent.withValues(alpha: 0.18)
                    : palette.shadow,
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                top: 16,
                bottom: 16,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: isUnread
                        ? palette.accent
                        : appOnly
                            ? palette.appIconFallback.withValues(alpha: 0.7)
                            : palette.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _AvatarStack(
                      palette: palette,
                      title: title,
                      avatarPath: avatarPath,
                      appIconPath: appIconPath,
                      appOnly: appOnly,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: palette.textPrimary,
                                        fontWeight: isUnread
                                            ? FontWeight.w800
                                            : FontWeight.w700,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: palette.surfaceAlt.withValues(
                                    alpha: 0.85,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  _timeLabel(time),
                                  style: TextStyle(
                                    color: isUnread
                                        ? palette.accent
                                        : palette.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: palette.surfaceAlt.withValues(
                                      alpha: appOnly ? 0.88 : 0.76,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    preview.isEmpty
                                        ? 'No message preview'
                                        : preview,
                                    maxLines: appOnly ? 2 : 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: previewColor,
                                      height: 1.35,
                                      fontWeight: isUnread
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  if (isPinned)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: palette.accentSoft,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: palette.accent.withValues(
                                            alpha: 0.4,
                                          ),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.star_rounded,
                                        size: 12,
                                        color: palette.accent,
                                      ),
                                    ),
                                  Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 28,
                                      minHeight: 28,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: badgeText == '.'
                                          ? palette.badgeIdle
                                          : palette.accentSoft,
                                      border: Border.all(
                                        color: badgeText == '.'
                                            ? palette.badgeIdleBorder
                                            : palette.accent,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      badgeText == '.' ? '0' : badgeText,
                                      style: TextStyle(
                                        color: badgeText == '.'
                                            ? palette.textSecondary
                                            : palette.accent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({
    required this.palette,
    required this.title,
    required this.avatarPath,
    required this.appIconPath,
    required this.appOnly,
  });

  final AppPalette palette;
  final String title;
  final String? avatarPath;
  final String? appIconPath;
  final bool appOnly;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: _AvatarImage(
              palette: palette,
              title: title,
              avatarPath: appOnly ? appIconPath : avatarPath,
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: _MiniAppIcon(palette: palette, path: appIconPath),
          ),
        ],
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({
    required this.palette,
    required this.title,
    required this.avatarPath,
  });

  final AppPalette palette;
  final String title;
  final String? avatarPath;

  @override
  Widget build(BuildContext context) {
    final avatarFile = avatarPath == null ? null : File(avatarPath!);
    final hasAvatar = avatarFile?.existsSync() ?? false;

    return CircleAvatar(
      radius: 28,
      backgroundColor: palette.surfaceStrong,
      backgroundImage: hasAvatar ? FileImage(avatarFile!) : null,
      child: hasAvatar
          ? null
          : Text(
              title.trim().isEmpty ? '?' : title.trim().characters.first.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

class _MiniAppIcon extends StatelessWidget {
  const _MiniAppIcon({
    required this.palette,
    required this.path,
  });

  final AppPalette palette;
  final String? path;

  @override
  Widget build(BuildContext context) {
    final iconFile = path == null ? null : File(path!);
    final hasIcon = iconFile?.existsSync() ?? false;

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: palette.scaffold,
        shape: BoxShape.circle,
        border: Border.all(color: palette.scaffold, width: 2),
      ),
      child: ClipOval(
        child: hasIcon
            ? Image.file(iconFile!, fit: BoxFit.cover)
            : ColoredBox(
                color: palette.appIconFallback,
                child: Icon(Icons.notifications, color: Colors.white, size: 12),
              ),
      ),
    );
  }
}

String _timeLabel(DateTime timestamp) {
  final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
  final minute = timestamp.minute.toString().padLeft(2, '0');
  final suffix = timestamp.hour >= 12 ? 'pm' : 'am';
  return '$suffix $hour:$minute';
}
