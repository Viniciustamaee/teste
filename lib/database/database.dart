import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'unitasks.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuario (
        id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        senha TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE categoria (
        id_categoria INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        id_usuario INTEGER ,
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
      );
    ''');

    await db.execute('''
      CREATE TABLE tarefa (
        id_tarefa INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT,
        data_entrega TEXT NOT NULL,
        prioridade TEXT CHECK (prioridade IN ('Alta', 'Média', 'Baixa')) NOT NULL,
        status TEXT CHECK (status IN ('Pendente', 'Em Andamento', 'Concluído')) NOT NULL DEFAULT 'Pendente',
        id_usuario INTEGER,
        id_categoria INTEGER,
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
        FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
      );
    ''');

    await db.execute('''
      CREATE TABLE tag (
        id_tag INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE tarefa_tag (
        id_tarefa INTEGER NOT NULL,
        id_tag INTEGER NOT NULL,
        PRIMARY KEY (id_tarefa, id_tag),
        FOREIGN KEY (id_tarefa) REFERENCES tarefa(id_tarefa),
        FOREIGN KEY (id_tag) REFERENCES tag(id_tag)
      );
    ''');
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tarefa');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    final data = task.toMap();

    data['id_usuario'] = '1';

    final result = await db.insert(
      'tarefa',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return result;
  }

  Future<Task?> getTaskById(String id) async {
    final db = await database;
    final intId = int.tryParse(id);
    if (intId == null) return null;
    final maps = await db.query(
      'tarefa',
      where: 'id_tarefa = ?',
      whereArgs: [intId],
    );
    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    final intId = task.id;
    if (intId == null) {
      throw Exception('ID inválido para atualização');
    }
    return await db.update(
      'tarefa',
      task.toMap(includeId: false),
      where: 'id_tarefa = ?',
      whereArgs: [intId],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tarefa', where: 'id_tarefa = ?', whereArgs: [id]);
  }

  Future<bool> login(String email, String senha) async {
    final db = await database;

    final mockEmail = 'teste@email.com';
    final mockSenha = '123';

    if (email != mockEmail || senha != mockSenha) {
      return false;
    }

    final maps = await db.query(
      'usuario',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );

    return maps.isNotEmpty;
  }
}
