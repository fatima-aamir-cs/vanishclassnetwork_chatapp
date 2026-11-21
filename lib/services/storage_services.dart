
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/message.dart';

class StorageService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final pathName = join(databasePath, 'vanish_chat.db');

    return openDatabase(
      pathName,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            sender TEXT NOT NULL,
            text TEXT NOT NULL,
            created_at TEXT NOT NULL,
            expires_at TEXT NOT NULL,
            status TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> saveMessage(ChatMessage message) async {
    final db = await database;
    await db.insert(
      'messages',
      message.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Load all saved messages.
  // Expiry will be checked by MessageService.
  Future<List<ChatMessage>> getAllMessages() async {
    final db = await database;
    final result = await db.query(
      'messages',
      orderBy: 'created_at ASC',
    );

    return result.map((item) => ChatMessage.fromJson(item)).toList();
  }

  Future<List<ChatMessage>> getActiveMessages() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final result = await db.query(
      'messages',
      where: 'expires_at > ?',
      whereArgs: [now],
      orderBy: 'created_at ASC',
    );

    return result.map((item) => ChatMessage.fromJson(item)).toList();
  }

  Future<void> deleteMessage(String id) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteExpiredMessages() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.delete(
      'messages',
      where: 'expires_at <= ?',
      whereArgs: [now],
    );
  }

  Future<void> deleteAllMessages() async {
    final db = await database;
    await db.delete('messages');
  }
}
