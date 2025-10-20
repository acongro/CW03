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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaskApp());
}

class TaskApp extends StatefulWidget {
  const TaskApp({Key? key}) : super(key: key);
  @override
  State<TaskApp> createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool dark) {
    setState(() {
      _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  ThemeData _lightBW() {
    final base = ThemeData(brightness: Brightness.light);
    return base.copyWith(
      useMaterial3: false,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      dividerColor: Colors.black,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: const MaterialStatePropertyAll(Colors.black),
        checkColor: const MaterialStatePropertyAll(Colors.white),
        side: const BorderSide(color: Colors.black),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const MaterialStatePropertyAll(Colors.black),
        trackColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected)
              ? Colors.black
              : Colors.black26,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.black,
        textColor: Colors.black,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.black,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.black,
      ),
    );
  }

  ThemeData _darkBW() {
    final base = ThemeData(brightness: Brightness.dark);
    return base.copyWith(
      useMaterial3: false,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      dividerColor: Colors.white,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: const MaterialStatePropertyAll(Colors.white),
        checkColor: const MaterialStatePropertyAll(Colors.black),
        side: const BorderSide(color: Colors.white),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const MaterialStatePropertyAll(Colors.white),
        trackColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected)
              ? Colors.white
              : Colors.white24,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.white,
        textColor: Colors.white,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.white,
        contentTextStyle: TextStyle(color: Colors.black),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager (sqflite)',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _lightBW(),
      darkTheme: _darkBW(),
      home: TaskListScreen(themeMode: _themeMode, onThemeChanged: _toggleTheme),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final void Function(bool isDark) onThemeChanged;
  const TaskListScreen({
    Key? key,
    required this.themeMode,
    required this.onThemeChanged,
  }) : super(key: key);
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _loading = true;
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await TaskDb.instance.getAll();
    setState(() {
      _tasks = items;
      _loading = false;
    });
  }

 