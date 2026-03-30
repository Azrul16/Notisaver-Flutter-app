import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    final timestamp = notification.timestamp;
    final dateLabel =
        '${timestamp.year}-${_twoDigits(timestamp.month)}-${_twoDigits(timestamp.day)} ${_twoDigits(timestamp.hour)}:${_twoDigits(timestamp.minute)}';

    return Scaffold(
      backgroundColor: const Color(0xFF2E2D37),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E2D37),
        foregroundColor: Colors.white,
        title: const Text('Message'),
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF3A3943),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _DetailAvatar(notification: notification),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            notification.title.isNotEmpty
                                ? notification.title
                                : notification.appName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.appName,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _DetailRow(label: 'Message', value: notification.message),
                if (notification.subText.isNotEmpty)
                  _DetailRow(label: 'More', value: notification.subText),
                _DetailRow(label: 'Received', value: dateLabel),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
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
            label: const Text('Copy Text'),
          ),
        ],
      ),
    );
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _DetailAvatar extends StatelessWidget {
  const _DetailAvatar({required this.notification});

  final SavedNotification notification;

  @override
  Widget build(BuildContext context) {
    final avatarFile =
        notification.avatarPath == null ? null : File(notification.avatarPath!);
    final hasAvatar = avatarFile?.existsSync() ?? false;

    return CircleAvatar(
      radius: 28,
      backgroundColor: const Color(0xFF4B4A57),
      backgroundImage: hasAvatar ? FileImage(avatarFile!) : null,
      child: hasAvatar
          ? null
          : Text(
              notification.appName.trim().isEmpty
                  ? '?'
                  : notification.appName.trim().characters.first.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
