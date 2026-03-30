import 'package:sqflite/sqflite.dart';

import '../database/notification_database.dart';
import '../models/saved_notification.dart';

class NotificationRepository {
  final NotificationDatabase _database = NotificationDatabase.instance;
  static const int _defaultFetchLimit = 600;
  static const int _maxStoredNotifications = 2000;
  static const int _duplicateWindowMs = 2 * 60 * 1000;

  Future<void> saveNotification(SavedNotification notification) async {
    final db = await _database.database;
    final normalized = notification.normalized();

    await db.transaction((txn) async {
      final duplicate = await txn.query(
        'notifications',
        columns: <String>['id', 'is_favorite', 'is_read'],
        where: 'content_key = ? AND timestamp >= ?',
        whereArgs: <Object?>[
          normalized.contentKey,
          normalized.timestamp.millisecondsSinceEpoch - _duplicateWindowMs,
        ],
        orderBy: 'timestamp DESC',
        limit: 1,
      );

      if (duplicate.isNotEmpty) {
        final row = duplicate.first;
        await txn.update(
          'notifications',
          <String, Object?>{
            ...normalized.toMap(),
            'id': row['id'],
            'is_favorite': row['is_favorite'],
            'is_read': row['is_read'],
          },
          where: 'id = ?',
          whereArgs: <Object?>[row['id']],
        );
      } else {
        await txn.insert(
          'notifications',
          normalized.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      await _trimOverflow(txn);
    });
  }

  Future<List<SavedNotification>> fetchNotifications({
    int limit = _defaultFetchLimit,
  }) async {
    final db = await _database.database;
    final rows = await db.query(
      'notifications',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return rows.map(SavedNotification.fromMap).toList();
  }

  Future<void> updateFavorite(int id, bool isFavorite) async {
    final db = await _database.database;
    await db.update(
      'notifications',
      <String, Object?>{'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<void> updateRead(int id, bool isRead) async {
    final db = await _database.database;
    await db.update(
      'notifications',
      <String, Object?>{'is_read': isRead ? 1 : 0},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<void> markAllAsRead() async {
    final db = await _database.database;
    await db.update(
      'notifications',
      <String, Object?>{'is_read': 1},
      where: 'is_read = ?',
      whereArgs: const <Object?>[0],
    );
  }

  Future<void> deleteNotification(int id) async {
    final db = await _database.database;
    await db.delete('notifications', where: 'id = ?', whereArgs: <Object?>[id]);
  }

  Future<void> clearAll() async {
    final db = await _database.database;
    await db.delete('notifications');
  }

  Future<void> purgeOlderThan(int days) async {
    final db = await _database.database;
    final cutoff = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;
    await db.delete(
      'notifications',
      where: 'timestamp < ?',
      whereArgs: <Object?>[cutoff],
    );
  }

  Future<void> _trimOverflow(DatabaseExecutor db) async {
    final overflowRows = await db.rawQuery(
      '''
      SELECT id FROM notifications
      ORDER BY timestamp DESC
      LIMIT -1 OFFSET ?
      ''',
      <Object?>[_maxStoredNotifications],
    );

    if (overflowRows.isEmpty) {
      return;
    }

    final ids = overflowRows
        .map((row) => row['id'])
        .whereType<int>()
        .toList(growable: false);
    if (ids.isEmpty) {
      return;
    }

    final placeholders = List<String>.filled(ids.length, '?').join(', ');
    await db.delete(
      'notifications',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }
}
