import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart'; // Certifique-se de importar o modelo Task aqui!

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
        id_usuario INTEGER NOT NULL,
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
        id_usuario INTEGER NOT NULL,
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

  // 🔥 Aqui você adiciona o método getAllTasks:
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tarefa');
    return maps.map((map) => Task.fromMap(map)).toList();
  }
}
