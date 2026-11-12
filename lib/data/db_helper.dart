import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:bookbank/data/database.dart';

/// SQLite database helper for CRUD operations
class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  /// Open database and cache instance for reuse
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // ────────── Database Initialization ──────────

  /// Create database file and initialize tables
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'Mydatabase.db');

    return await openDatabase(
      path,
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ────────── Database Creation ──────────

  /// Create tables in database
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        moneyList TEXT NOT NULL,
        moneyType TEXT NOT NULL,
        moneyGroup TEXT NOT NULL,
        date TEXT,
        title TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE group_settings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId TEXT NOT NULL UNIQUE,
        groupName TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        colorValue INTEGER NOT NULL,
        savingsGoalEnabled INTEGER NOT NULL DEFAULT 0,
        savingsGoalAmount REAL NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        colorValue INTEGER NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'General',
        isPinned INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE quick_notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        note TEXT NOT NULL,
        sortOrder INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // ────────── Database Upgrade ──────────

  /// Upgrade database when version changes
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN date TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE transactions ADD COLUMN title TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS group_settings(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          groupId TEXT NOT NULL UNIQUE,
          groupName TEXT NOT NULL,
          iconCodePoint INTEGER NOT NULL,
          colorValue INTEGER NOT NULL,
          savingsGoalEnabled INTEGER NOT NULL DEFAULT 0,
          savingsGoalAmount REAL NOT NULL DEFAULT 0
        )
      ''');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          colorValue INTEGER NOT NULL,
          date TEXT NOT NULL,
          category TEXT NOT NULL DEFAULT 'General',
          isPinned INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
    if (oldVersion < 6) {
      // Remove untouched default groups so users start with 0 categories.
      // Groups the user has renamed (groupName != groupId) are kept.
      await db.delete('group_settings', where: 'groupName = groupId');
    }
    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS quick_notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          note TEXT NOT NULL,
          sortOrder INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
  }

  // ────────── Transaction Operations ──────────

  /// Insert new transaction record
  Future<int> insertData(MyData item) async {
    final db = await database;
    return await db.insert(
      'transactions',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Read all transactions
  Future<List<MyData>> getAllData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'id DESC',
    );
    return maps.map((map) => MyData.fromMap(map)).toList();
  }

  /// Update transaction by id
  Future<int> updateData(MyData item) async {
    final db = await database;
    if (item.id == null) return 0;
    return await db.update(
      'transactions',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// Delete transaction by id
  Future<int> deleteData(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ────────── Group Settings Operations ──────────

  /// Read all group settings
  Future<List<GroupSettings>> getAllGroupSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('group_settings');
    return maps.map((map) => GroupSettings.fromMap(map)).toList();
  }

  /// Read group settings by groupId
  Future<GroupSettings?> getGroupSettings(String groupId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'group_settings',
      where: 'groupId = ?',
      whereArgs: [groupId],
    );
    if (maps.isEmpty) return null;
    return GroupSettings.fromMap(maps.first);
  }

  /// Insert new group settings
  Future<int> insertGroupSettings(GroupSettings settings) async {
    final db = await database;
    return await db.insert(
      'group_settings',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Update or insert group settings
  Future<int> upsertGroupSettings(GroupSettings settings) async {
    final db = await database;
    return await db.insert(
      'group_settings',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update group settings by id
  Future<int> updateGroupSettings(GroupSettings settings) async {
    final db = await database;
    if (settings.id == null) return 0;
    return await db.update(
      'group_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [settings.id],
    );
  }

  // ────────── Note Operations ──────────

  /// Insert new note
  Future<int> insertNote(NoteModel note) async {
    final db = await database;
    return await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Read all notes sorted by pinned status and latest id
  Future<List<NoteModel>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: 'isPinned DESC, id DESC',
    );
    return maps.map((map) => NoteModel.fromMap(map)).toList();
  }

  /// Update note
  Future<int> updateNote(NoteModel note) async {
    final db = await database;
    if (note.id == null) return 0;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// Delete note by id
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // ────────── Quick Note Operations ──────────

  /// Read all quick notes in saved order
  Future<List<QuickNote>> getQuickNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quick_notes',
      orderBy: 'sortOrder ASC, id ASC',
    );
    return maps.map((map) => QuickNote.fromMap(map)).toList();
  }

  /// Insert new quick note at the end of the list
  Future<int> insertQuickNote(String note) async {
    final db = await database;
    final existing = await getQuickNotes();
    final maxOrder = existing.fold<int>(
      0,
      (max, e) => e.sortOrder > max ? e.sortOrder : max,
    );
    return await db.insert('quick_notes', {
      'note': note,
      'sortOrder': maxOrder + 1,
    });
  }

  /// Delete quick note by id
  Future<int> deleteQuickNote(int id) async {
    final db = await database;
    return await db.delete('quick_notes', where: 'id = ?', whereArgs: [id]);
  }

  /// Persist a new ordering for all quick notes
  Future<void> updateQuickNotesOrder(List<QuickNote> notes) async {
    final db = await database;
    final batch = db.batch();
    for (var i = 0; i < notes.length; i++) {
      batch.update(
        'quick_notes',
        {'sortOrder': i},
        where: 'id = ?',
        whereArgs: [notes[i].id],
      );
    }
    await batch.commit(noResult: true);
  }

  /// สลับสถานะปักหมุดบันทึก
  Future<int> toggleNotePin(int id, bool isPinned) async {
    final db = await database;
    return await db.update(
      'notes',
      {'isPinned': isPinned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

