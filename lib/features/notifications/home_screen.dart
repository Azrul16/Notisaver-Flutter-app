import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/models/saved_notification.dart';
import 'notification_history_screen.dart';

enum HomeSection { messages, apps }

enum MessageTab { unread, saved }

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.notifications,
    required this.notificationAccessEnabled,
    required this.batteryOptimizationIgnored,
    required this.onRefresh,
    required this.onToggleFavorite,
    required this.onDelete,
    required this.onClearAll,
    required this.onMarkAllAsRead,
    required this.onOpenDetail,
    required this.onOpenSettings,
    required this.onOpenAppFilter,
  });

  final List<SavedNotification> notifications;
  final bool notificationAccessEnabled;
  final bool batteryOptimizationIgnored;
  final Future<void> Function() onRefresh;
  final Future<void> Function(SavedNotification notification) onToggleFavorite;
  final Future<void> Function(SavedNotification notification) onDelete;
  final Future<void> Function() onClearAll;
  final Future<void> Function() onMarkAllAsRead;
  final Future<void> Function(SavedNotification notification) onOpenDetail;
  final Future<void> Function() onOpenSettings;
  final Future<void> Function() onOpenAppFilter;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  HomeSection _selectedSection = HomeSection.messages;
  MessageTab _selectedMessageTab = MessageTab.unread;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messageGroups = _messageGroups();
    final appGroups = _appGroups();

    return Scaffold(
      backgroundColor: const Color(0xFF2E2D37),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E2D37),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Text(
          _selectedSection == HomeSection.messages ? 'Messages' : 'Notifications',
        ),
        actions: <Widget>[
          IconButton(
            onPressed: widget.onOpenSettings,
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFFF4F82),
          onRefresh: widget.onRefresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 120),
            children: <Widget>[
              if (_selectedSection == HomeSection.messages) ...<Widget>[
                Row(
                  children: <Widget>[
                    _TopTab(
                      label: 'Unread',
                      selected: _selectedMessageTab == MessageTab.unread,
                      onTap: () => setState(() {
                        _selectedMessageTab = MessageTab.unread;
                      }),
                    ),
                    const SizedBox(width: 20),
                    _TopTab(
                      label: 'Saved',
                      selected: _selectedMessageTab == MessageTab.saved,
                      onTap: () => setState(() {
                        _selectedMessageTab = MessageTab.saved;
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: _selectedSection == HomeSection.messages
                      ? 'Search people or messages'
                      : 'Search apps or notifications',
                  hintStyle:
                      TextStyle(color: Colors.white.withValues(alpha: 0.45)),
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF3A3943),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (_selectedSection == HomeSection.messages)
                if (messageGroups.isEmpty)
                  const _EmptyState(
                    title: 'No messages yet',
                    subtitle: 'Saved conversations will appear here.',
                  )
                else
                  ...messageGroups.map(
                    (group) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ConversationTile(
                        title: group.title,
                        subtitle: group.subtitle,
                        preview: group.preview,
                        time: group.time,
                        badgeText: group.unreadCount > 0 ? '${group.unreadCount}' : '.',
                        avatarPath: group.avatarPath,
                        appIconPath: group.appIconPath,
                        onTap: () => _openHistory(
                          title: group.title,
                          subtitle: group.subtitle,
                          appIconPath: group.appIconPath,
                          avatarPath: group.avatarPath,
                          notifications: group.notifications,
                        ),
                      ),
                    ),
                  )
              else if (appGroups.isEmpty)
                const _EmptyState(
                  title: 'No grouped notifications yet',
                  subtitle: 'Notifications grouped by app will appear here.',
                )
              else
                ...appGroups.map(
                  (group) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ConversationTile(
                      title: group.title,
                      subtitle: group.subtitle,
                      preview: group.preview,
                      time: group.time,
                      badgeText: '${group.notifications.length}',
                      avatarPath: null,
                      appIconPath: group.appIconPath,
                      appOnly: true,
                      onTap: () => _openHistory(
                        title: group.title,
                        subtitle: group.subtitle,
                        appIconPath: group.appIconPath,
                        avatarPath: null,
                        notifications: group.notifications,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 74,
        backgroundColor: const Color(0xFF2A2932),
        indicatorColor: const Color(0x33FF4F82),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF23222B),
        onPressed: widget.notifications.isEmpty ? null : widget.onMarkAllAsRead,
        child: const Icon(Icons.check_rounded),
      ),
    );
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

  List<_Group> _messageGroups() {
    final query = _searchController.text.trim().toLowerCase();
    final groups = <String, List<SavedNotification>>{};
    for (final notification in widget.notifications) {
      if (!_isMessageLike(notification)) continue;
      final matchesSaved =
          _selectedMessageTab != MessageTab.saved || notification.isFavorite;
      final matchesUnread =
          _selectedMessageTab != MessageTab.unread || !notification.isRead;
      if (!matchesSaved || !matchesUnread) continue;
      final key = '${notification.packageName}|${_title(notification).toLowerCase()}';
      groups.putIfAbsent(key, () => <SavedNotification>[]).add(notification);
    }
    return _mapGroups(groups, query, subtitleBuilder: (latest, items) => latest.appName);
  }

  List<_Group> _appGroups() {
    final query = _searchController.text.trim().toLowerCase();
    final groups = <String, List<SavedNotification>>{};
    for (final notification in widget.notifications) {
      final haystack =
          '${notification.appName} ${notification.title} ${notification.message}'
              .toLowerCase();
      if (query.isNotEmpty && !haystack.contains(query)) continue;
      groups.putIfAbsent(notification.packageName, () => <SavedNotification>[]).add(notification);
    }
    return _mapGroups(
      groups,
      query,
      titleBuilder: (latest, items) => latest.appName,
      subtitleBuilder: (latest, items) => '${items.length} saved notifications',
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
      final haystack = '$title ${latest.appName} ${latest.message} ${latest.subText}'.toLowerCase();
      if (query.isNotEmpty && !haystack.contains(query)) return null;
      return _Group(
        title: title,
        subtitle: subtitleBuilder(latest, items),
        preview: latest.message.isNotEmpty ? latest.message : latest.subText,
        time: latest.timestamp,
        avatarPath: latest.avatarPath,
        appIconPath: latest.appIconPath,
        unreadCount: items.where((item) => !item.isRead).length,
        notifications: items,
      );
    }).whereType<_Group>().toList()
      ..sort((a, b) => b.time.compareTo(a.time));
    return result;
  }

  String _title(SavedNotification notification) {
    final title = notification.title.trim();
    return title.isEmpty ? notification.appName : title;
  }

  bool _isMessageLike(SavedNotification notification) {
    final packageName = notification.packageName.toLowerCase();
    final category = notification.category?.toLowerCase() ?? '';
    final text =
        '${notification.title} ${notification.message} ${notification.subText}'
            .toLowerCase();
    const keywords = <String>[
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
    return category.contains('msg') ||
        category.contains('social') ||
        keywords.any(packageName.contains) ||
        keywords.any(text.contains);
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
    required this.notifications,
  });

  final String title;
  final String subtitle;
  final String preview;
  final DateTime time;
  final String? avatarPath;
  final String? appIconPath;
  final int unreadCount;
  final List<SavedNotification> notifications;
}

class _TopTab extends StatelessWidget {
  const _TopTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 180),
        style: TextStyle(
          color: selected ? Colors.white : Colors.white54,
          fontSize: 18,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        child: Text(label),
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
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3943),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.notifications_off_rounded,
            color: Colors.white70,
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.title,
    required this.subtitle,
    required this.preview,
    required this.time,
    required this.badgeText,
    required this.avatarPath,
    required this.appIconPath,
    required this.onTap,
    this.appOnly = false,
  });

  final String title;
  final String subtitle;
  final String preview;
  final DateTime time;
  final String badgeText;
  final String? avatarPath;
  final String? appIconPath;
  final VoidCallback onTap;
  final bool appOnly;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: appOnly ? const Color(0xFF3A3943) : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _AvatarStack(
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
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview.isEmpty ? 'Open to view saved history' : preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, height: 1.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF9C9BA6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    _timeLabel(time),
                    style: const TextStyle(
                      color: Color(0xFFB9B8C1),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF4F82)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        color: Color(0xFFFF4F82),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
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
    required this.title,
    required this.avatarPath,
    required this.appIconPath,
    required this.appOnly,
  });

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
              title: title,
              avatarPath: appOnly ? appIconPath : avatarPath,
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: _MiniAppIcon(path: appIconPath),
          ),
        ],
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({
    required this.title,
    required this.avatarPath,
  });

  final String title;
  final String? avatarPath;

  @override
  Widget build(BuildContext context) {
    final avatarFile = avatarPath == null ? null : File(avatarPath!);
    final hasAvatar = avatarFile?.existsSync() ?? false;

    return CircleAvatar(
      radius: 28,
      backgroundColor: const Color(0xFF4B4A57),
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
  const _MiniAppIcon({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final iconFile = path == null ? null : File(path!);
    final hasIcon = iconFile?.existsSync() ?? false;

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFF2E2D37),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2E2D37), width: 2),
      ),
      child: ClipOval(
        child: hasIcon
            ? Image.file(iconFile!, fit: BoxFit.cover)
            : const ColoredBox(
                color: Color(0xFF2094F3),
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
