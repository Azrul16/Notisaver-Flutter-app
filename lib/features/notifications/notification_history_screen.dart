import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/models/saved_notification.dart';

class NotificationHistoryScreen extends StatefulWidget {
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
  State<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  final TextEditingController _keywordController = TextEditingController();

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF292B36);
    const surface = Color(0xFF323440);
    const divider = Color(0xFF414451);
    const textPrimary = Color(0xFFF5F7FB);
    const textSecondary = Color(0xFFADB3C2);
    const accent = Color(0xFF61A8FF);

    final filteredNotifications = _filteredNotifications();
    final historyItems = _buildHistoryItems(filteredNotifications);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        leading: const BackButton(),
        titleSpacing: 8,
        title: Row(
          children: <Widget>[
            _HeaderAvatar(
              title: widget.title,
              avatarPath: widget.avatarPath,
              appIconPath: widget.appIconPath,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.search_rounded, color: textPrimary),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: historyItems.isEmpty
                ? const Center(
                    child: Text(
                      'No messages match this keyword',
                      style: TextStyle(color: textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
                    itemCount: historyItems.length,
                    itemBuilder: (context, index) {
                      final item = historyItems[index];
                      return item.when(
                        header: (label) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            children: <Widget>[
                              const Expanded(
                                child: Divider(color: divider, thickness: 0.8),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    color: textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: divider, thickness: 0.8),
                              ),
                            ],
                          ),
                        ),
                        notification: (notification) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _ThreadMessageTile(
                            notification: notification,
                            appIconPath: widget.appIconPath,
                            onTap: () => widget.onOpenDetail(notification),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            color: background,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            child: SafeArea(
              top: false,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: TextField(
                        controller: _keywordController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Please enter keywords',
                          hintStyle: TextStyle(color: textSecondary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<SavedNotification> _filteredNotifications() {
    final query = _keywordController.text.trim().toLowerCase();
    final notifications = List<SavedNotification>.from(widget.notifications)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (query.isEmpty) {
      return notifications;
    }
    return notifications.where((notification) {
      final haystack =
          '${notification.title} ${notification.message} ${notification.subText} ${notification.appName}'
              .toLowerCase();
      return haystack.contains(query);
    }).toList();
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
    final date = timestamp.toLocal();
    final month = _monthLabel(date.month);
    return '$month ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  String _monthLabel(int month) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class _ThreadMessageTile extends StatelessWidget {
  const _ThreadMessageTile({
    required this.notification,
    required this.appIconPath,
    required this.onTap,
  });

  final SavedNotification notification;
  final String? appIconPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const bubble = Color(0xFF3A3D49);
    const textPrimary = Color(0xFFF5F7FB);
    const textSecondary = Color(0xFFADB3C2);
    const accent = Color(0xFF7EB8FF);

    final message = notification.message.isNotEmpty
        ? notification.message
        : notification.subText.isNotEmpty
        ? notification.subText
        : notification.title;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _BubbleAvatar(
              title: notification.title.isNotEmpty
                  ? notification.title
                  : notification.appName,
              avatarPath: notification.avatarPath,
              appIconPath: appIconPath ?? notification.appIconPath,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 5),
                    child: Text(
                      _senderLabel(notification),
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: bubble,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            message.isEmpty ? 'No message text' : message,
                            style: const TextStyle(
                              color: textPrimary,
                              height: 1.35,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          _timeLabel(notification.timestamp),
                          style: TextStyle(
                            color: notification.isRead ? textSecondary : accent,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _senderLabel(SavedNotification notification) {
    final title = notification.title.trim();
    final appName = notification.appName.trim();
    if (title.isEmpty || title.toLowerCase() == appName.toLowerCase()) {
      return appName;
    }
    return title;
  }

  String _timeLabel(DateTime timestamp) {
    final local = timestamp.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'pm' : 'am';
    return '$suffix $hour:$minute';
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
      width: 36,
      height: 36,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: _MainAvatar(
              title: title,
              path: avatarPath,
              radius: 18,
            ),
          ),
          Positioned(
            right: -1,
            bottom: -1,
            child: _MiniAppIcon(path: appIconPath),
          ),
        ],
      ),
    );
  }
}

class _BubbleAvatar extends StatelessWidget {
  const _BubbleAvatar({
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
      width: 34,
      height: 34,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: _MainAvatar(
              title: title,
              path: avatarPath,
              radius: 17,
            ),
          ),
          Positioned(
            right: -1,
            bottom: -1,
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
    required this.radius,
  });

  final String title;
  final String? path;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final file = path == null ? null : File(path!);
    final hasImage = file?.existsSync() ?? false;
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF495469),
      backgroundImage: hasImage ? FileImage(file!) : null,
      child: hasImage
          ? null
          : Text(
              title.trim().isEmpty ? '?' : title.trim().characters.first,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.8,
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
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: const Color(0xFF292B36),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF292B36), width: 1.5),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.file(file!, fit: BoxFit.cover)
            : const ColoredBox(
                color: Color(0xFF61A8FF),
                child: Icon(
                  Icons.notifications_rounded,
                  color: Colors.white,
                  size: 9,
                ),
              ),
      ),
    );
  }
}
