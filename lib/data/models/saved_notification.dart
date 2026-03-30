class SavedNotification {
  SavedNotification({
    this.id,
    required this.appName,
    required this.packageName,
    required this.title,
    required this.message,
    required this.subText,
    required this.timestamp,
    required this.notificationKey,
    this.category,
    this.avatarPath,
    this.appIconPath,
    this.isFavorite = false,
    this.isRead = false,
  });

  final int? id;
  final String appName;
  final String packageName;
  final String title;
  final String message;
  final String subText;
  final DateTime timestamp;
  final String notificationKey;
  final String? category;
  final String? avatarPath;
  final String? appIconPath;
  final bool isFavorite;
  final bool isRead;

  static const int _maxAppNameLength = 80;
  static const int _maxTitleLength = 500;
  static const int _maxMessageLength = 12000;
  static const int _maxSubTextLength = 4000;

  SavedNotification normalized() {
    return SavedNotification(
      id: id,
      appName: _trimToLength(appName, _maxAppNameLength, fallback: 'Unknown app'),
      packageName: packageName.trim(),
      title: _trimToLength(title, _maxTitleLength),
      message: _trimToLength(message, _maxMessageLength),
      subText: _trimToLength(subText, _maxSubTextLength),
      timestamp: timestamp,
      notificationKey: notificationKey.trim(),
      category: category?.trim(),
      avatarPath: avatarPath?.trim(),
      appIconPath: appIconPath?.trim(),
      isFavorite: isFavorite,
      isRead: isRead,
    );
  }

  String get contentKey {
    return <String>[
      packageName.trim().toLowerCase(),
      title.trim().toLowerCase(),
      message.trim().toLowerCase(),
      subText.trim().toLowerCase(),
      (category ?? '').trim().toLowerCase(),
    ].join('|');
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'app_name': appName,
      'package_name': packageName,
      'title': title,
      'message': message,
      'sub_text': subText,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'notification_key': notificationKey,
      'category': category,
      'content_key': contentKey,
      'avatar_path': avatarPath,
      'app_icon_path': appIconPath,
      'is_favorite': isFavorite ? 1 : 0,
      'is_read': isRead ? 1 : 0,
    };
  }

  factory SavedNotification.fromMap(Map<String, Object?> map) {
    return SavedNotification(
      id: map['id'] as int?,
      appName: (map['app_name'] as String?) ?? 'Unknown app',
      packageName: (map['package_name'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      message: (map['message'] as String?) ?? '',
      subText: (map['sub_text'] as String?) ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      ),
      notificationKey: (map['notification_key'] as String?) ?? '',
      category: map['category'] as String?,
      avatarPath: map['avatar_path'] as String?,
      appIconPath: map['app_icon_path'] as String?,
      isFavorite: ((map['is_favorite'] as int?) ?? 0) == 1,
      isRead: ((map['is_read'] as int?) ?? 0) == 1,
    );
  }

  factory SavedNotification.fromChannelMap(Map<Object?, Object?> map) {
    return SavedNotification(
      appName: (map['appName'] as String?) ?? 'Unknown app',
      packageName: (map['packageName'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      message: (map['message'] as String?) ?? '',
      subText: (map['subText'] as String?) ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      ),
      notificationKey: (map['notificationKey'] as String?) ?? '',
      category: map['category'] as String?,
      avatarPath: map['avatarPath'] as String?,
      appIconPath: map['appIconPath'] as String?,
    ).normalized();
  }

  static String _trimToLength(
    String value,
    int maxLength, {
    String fallback = '',
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return fallback;
    }
    if (trimmed.length <= maxLength) {
      return trimmed;
    }
    return trimmed.substring(0, maxLength);
  }
}
