import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

class Task {
  final int? id;
  final String name;
  final bool isDone;
  final int createdAt;

  Task({
    this.id,
    required this.name,
    required this.isDone,
    required this.createdAt,
  });

  Task copyWith({int? id, String? name, bool? isDone, int? createdAt}) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'is_done': isDone ? 1 : 0,
    'created_at': createdAt,
  };

  factory Task.fromMap(Map<String, Object?> map) => Task(
    id: map['id'] as int?,
    name: map['name'] as String,
    isDone: (map['is_done'] as int) == 1,
    createdAt: map['created_at'] as int,
  );
}

class TaskDb {
  TaskDb._();
  static final TaskDb instance = TaskDb._();
  static const _dbName = 'tasks_v1.db';
  static const _dbVersion = 1;
  static const _table = 'tasks';
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dir = await getDatabasesPath();
    final path = join(dir, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            is_done INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Task>> getAll() async {
    final db = await database;
    final rows = await db.query(_table, orderBy: 'created_at ASC');
    return rows.map((e) => Task.fromMap(e)).toList();
  }

  Future<Task> insert(Task task) async {
    final db = await database;
    final id = await db.insert(_table, task.toMap());
    return task.copyWith(id: id);
  }

  Future<int> update(Task task) async {
    final db = await database;
    return db.update(
      _table,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
