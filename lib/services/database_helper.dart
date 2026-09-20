import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/note.dart';

/// Accès à la base SQLite locale (`mes_notes.db`) : création des tables
/// `users` et `notes`, puis opérations CRUD sur les notes.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Future<Database>? _database;

  /// La base est ouverte une seule fois, au premier accès.
  Future<Database> get database => _database ??= _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'mes_notes.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE COLLATE NOCASE,
            password TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // ---------- CRUD des notes ----------

  /// Notes d'un utilisateur, la plus récente en premier.
  Future<List<Note>> getNotes(int userId) async {
    final db = await database;
    final rows = await db.query(
      'notes',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
    return rows.map(Note.fromMap).toList();
  }

  Future<int> insertNote(Note note) async {
    final db = await database;
    return db.insert('notes', note.toMap());
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [note.id, note.userId],
    );
  }

  Future<int> deleteNote(int id, int userId) async {
    final db = await database;
    return db.delete(
      'notes',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }
}
