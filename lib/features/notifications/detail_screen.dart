import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/saved_notification.dart';

class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({
    super.key,
    required this.notification,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  final SavedNotification notification;
  final Future<void> Function() onDelete;
  final Future<void> Function() onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final timeLabel = _timeLabel(notification.timestamp);
    final messageText = notification.message.isNotEmpty
        ? notification.message
        : notification.subText.isNotEmpty
        ? notification.subText
        : notification.title;

    return Scaffold(
      backgroundColor: palette.scaffold,
      appBar: AppBar(
        backgroundColor: palette.scaffold,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        titleSpacing: 8,
        title: Row(
          children: <Widget>[
            _DetailAvatar(notification: notification),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    notification.title.isNotEmpty
                        ? notification.title
                        : notification.appName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    notification.appName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: onToggleFavorite,
            icon: Icon(
              notification.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  _DetailAvatar(notification: notification, radius: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            palette.accent,
                            palette.accentWarm,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(22),
                          topRight: Radius.circular(22),
                          bottomRight: Radius.circular(22),
                          bottomLeft: Radius.circular(8),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: palette.accent.withValues(alpha: 0.22),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            messageText.isEmpty ? 'No message content' : messageText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (notification.subText.isNotEmpty &&
                              notification.subText != notification.message) ...<Widget>[
                            const SizedBox(height: 10),
                            Text(
                              notification.subText,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.84),
                                height: 1.35,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                timeLabel,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.82),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _MetaChip(
                      icon: Icons.notifications_active_rounded,
                      label: notification.appName,
                    ),
                    if (notification.isFavorite)
                      const _MetaChip(
                        icon: Icons.star_rounded,
                        label: 'Saved',
                      ),
                    _MetaChip(
                      icon: notification.isRead
                          ? Icons.done_all_rounded
                          : Icons.mark_chat_unread_rounded,
                      label: notification.isRead ? 'Read' : 'Unread',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final payload = [
                      notification.title,
                      notification.message,
                      notification.subText,
                    ].where((text) => text.isNotEmpty).join('\n\n');
                    await Clipboard.setData(ClipboardData(text: payload));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification copied')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy text'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeLabel(DateTime timestamp) {
    final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final suffix = timestamp.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minute $suffix';
  }
}

class _DetailAvatar extends StatelessWidget {
  const _DetailAvatar({
    required this.notification,
    this.radius = 24,
  });

  final SavedNotification notification;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final avatarFile =
        notification.avatarPath == null ? null : File(notification.avatarPath!);
    final hasAvatar = avatarFile?.existsSync() ?? false;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        CircleAvatar(
          radius: radius,
          backgroundColor: palette.surfaceStrong,
          backgroundImage: hasAvatar ? FileImage(avatarFile!) : null,
          child: hasAvatar
              ? null
              : Text(
                  notification.appName.trim().isEmpty
                      ? '?'
                      : notification.appName.trim().characters.first.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: radius * 0.8,
                  ),
                ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: _AppIconBadge(path: notification.appIconPath),
        ),
      ],
    );
  }
}

class _AppIconBadge extends StatelessWidget {
  const _AppIconBadge({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final iconFile = path == null ? null : File(path!);
    final hasIcon = iconFile?.existsSync() ?? false;

    return Container(
      width: 20,
      height: 20,
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
                child: const Icon(
                  Icons.notifications_rounded,
                  color: Colors.white,
                  size: 11,
                ),
              ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: palette.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
