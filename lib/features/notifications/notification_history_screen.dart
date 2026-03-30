import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/models/saved_notification.dart';

class NotificationHistoryScreen extends StatelessWidget {
  const NotificationHistoryScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.appIconPath,
    required this.avatarPath,
    required this.notifications,
    required this.onOpenDetail,
  });

  final String title;
  final String subtitle;
  final String? appIconPath;
  final String? avatarPath;
  final List<SavedNotification> notifications;
  final Future<void> Function(SavedNotification notification) onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final items = List<SavedNotification>.from(notifications)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final historyItems = _buildHistoryItems(items);

    return Scaffold(
      backgroundColor: const Color(0xFF2E2D37),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E2D37),
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
            child: Row(
              children: <Widget>[
                _HeaderAvatar(
                  title: title,
                  avatarPath: avatarPath,
                  appIconPath: appIconPath,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
              itemCount: historyItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = historyItems[index];
                return item.when(
                  header: (label) => Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 2),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  notification: (notification) => Material(
                    color: const Color(0xFF3A3943),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => onOpenDetail(notification),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    notification.title.isNotEmpty
                                        ? notification.title
                                        : notification.appName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  _historyTimeLabel(notification.timestamp),
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notification.message.isNotEmpty
                                  ? notification.message
                                  : notification.subText,
                              style: const TextStyle(
                                color: Colors.white70,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<_HistoryItem> _buildHistoryItems(List<SavedNotification> items) {
    final result = <_HistoryItem>[];
    String? lastLabel;
    for (final notification in items) {
      final label = _groupLabel(notification.timestamp);
      if (label != lastLabel) {
        result.add(_HistoryItem.header(label));
        lastLabel = label;
      }
      result.add(_HistoryItem.notification(notification));
    }
    return result;
  }

  String _groupLabel(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final difference = today.difference(target).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}

class _HistoryItem {
  const _HistoryItem._({
    this.headerLabel,
    this.notification,
  });

  const _HistoryItem.header(String label) : this._(headerLabel: label);

  const _HistoryItem.notification(SavedNotification notification)
      : this._(notification: notification);

  final String? headerLabel;
  final SavedNotification? notification;

  T when<T>({
    required T Function(String label) header,
    required T Function(SavedNotification notification) notification,
  }) {
    if (headerLabel != null) {
      return header(headerLabel!);
    }
    return notification(this.notification!);
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({
    required this.title,
    required this.avatarPath,
    required this.appIconPath,
  });

  final String title;
  final String? avatarPath;
  final String? appIconPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(child: _MainAvatar(title: title, path: avatarPath)),
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

class _MainAvatar extends StatelessWidget {
  const _MainAvatar({
    required this.title,
    required this.path,
  });

  final String title;
  final String? path;

  @override
  Widget build(BuildContext context) {
    final file = path == null ? null : File(path!);
    final hasImage = file?.existsSync() ?? false;
    return CircleAvatar(
      radius: 28,
      backgroundColor: const Color(0xFF4B4A57),
      backgroundImage: hasImage ? FileImage(file!) : null,
      child: hasImage
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
    final file = path == null ? null : File(path!);
    final hasImage = file?.existsSync() ?? false;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFF2E2D37),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2E2D37), width: 2),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.file(file!, fit: BoxFit.cover)
            : const ColoredBox(
                color: Color(0xFF2094F3),
                child: Icon(Icons.notifications, color: Colors.white, size: 12),
              ),
      ),
    );
  }
}

String _historyTimeLabel(DateTime timestamp) {
  final month = timestamp.month.toString().padLeft(2, '0');
  final day = timestamp.day.toString().padLeft(2, '0');
  final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
  final minute = timestamp.minute.toString().padLeft(2, '0');
  final suffix = timestamp.hour >= 12 ? 'pm' : 'am';
  return '$day/$month  $hour:$minute $suffix';
}
