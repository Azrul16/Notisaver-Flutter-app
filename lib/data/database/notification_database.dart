import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class NotificationDatabase {
  NotificationDatabase._();

  static final NotificationDatabase instance = NotificationDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final databasePath = await getDatabasesPath();
    _database = await openDatabase(
      p.join(databasePath, 'notisaver.db'),
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notifications(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            app_name TEXT NOT NULL,
            package_name TEXT NOT NULL,
            title TEXT NOT NULL,
            message TEXT NOT NULL,
            sub_text TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            notification_key TEXT NOT NULL,
            category TEXT,
            content_key TEXT NOT NULL,
            avatar_path TEXT,
            app_icon_path TEXT,
            is_favorite INTEGER NOT NULL DEFAULT 0,
            is_read INTEGER NOT NULL DEFAULT 0,
            UNIQUE(notification_key, timestamp) ON CONFLICT IGNORE
          )
        ''');
        await _createIndexes(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE notifications ADD COLUMN avatar_path TEXT',
          );
          await db.execute(
            'ALTER TABLE notifications ADD COLUMN app_icon_path TEXT',
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            "ALTER TABLE notifications ADD COLUMN content_key TEXT NOT NULL DEFAULT ''",
          );
        }
        await _createIndexes(db);
      },
    );

    return _database!;
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notifications_timestamp ON notifications(timestamp DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notifications_package_timestamp ON notifications(package_name, timestamp DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notifications_favorite_timestamp ON notifications(is_favorite, timestamp DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notifications_content_timestamp ON notifications(content_key, timestamp DESC)',
    );
  }
}
