import 'package:flutter/material.dart';
import 'package:myapp/database/database.dart';
import 'package:myapp/service/notification_service.dart';

import 'models/task.dart';
import 'screens/trello_board_screen.dart';
import 'screens/task_form_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();
  await DatabaseHelper.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Task> _tarefas = [];
  bool _isAuthenticated = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTasksFromDb();
  }

  Future<void> _loadTasksFromDb() async {
    final tasksFromDb = await DatabaseHelper.instance.getAllTasks();
    setState(() {
      _tarefas.clear();
      _tarefas.addAll(tasksFromDb);
    });
  }

  // void _addOrUpdateTask(Task task) async {
  //   final db = DatabaseHelper.instance;
  //   final index = _tarefas.indexWhere((t) => t.id == task.id);

  //   if (index == -1) {
  //     final id = await db.insertTask(task);
  //     setState(() {
  //       _tarefas.add(
  //         Task(
  //           id: id,
  //           titulo: task.titulo,
  //           descricao: task.descricao,
  //           data: task.data,
  //           prioridade: task.prioridade,
  //           status: task.status,
  //         ),
  //       );
  //     });
  //   } else {
  //     await db.updateTask(task);
  //     setState(() {
  //       _tarefas[index] = task;
  //     });
  //   }
  // }

  void _addOrUpdateTask(Task task) async {
    final db = DatabaseHelper.instance;
    final index = _tarefas.indexWhere((t) => t.id == task.id);

    if (index == -1) {
      final id = await db.insertTask(task);
      setState(() {
        _tarefas.add(
          Task(
            id: id,
            titulo: task.titulo,
            descricao: task.descricao,
            data: task.data,
            prioridade: task.prioridade,
            status: task.status,
          ),
        );
      });
    } else {
      await db.updateTask(task);
      setState(() {
        _tarefas[index] = task;
      });
    }
  }

  void _deleteTask(Task task) async {
    final int? id = task.id;
    if (id == null) {
      debugPrint('Erro: não foi possível concluir a ação -> ${task.id}');
      return;
    }

    await DatabaseHelper.instance.deleteTask(id);

    setState(() {
      _tarefas.removeWhere((t) => t.id == task.id);
    });
  }

  void _handleLogin(String email, String senha, bool isLogin) {
    setState(() {
      _isAuthenticated = true;
    });
  }

  List<Widget> get _screens => [
    TrelloBoardScreen(
      tarefas: _tarefas,
      onEdit: (task) async {
        final editedTask = await Navigator.push<Task>(
          context,
          MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
        );
        if (editedTask != null) {
          _addOrUpdateTask(editedTask);
        }
      },
      onDelete: _deleteTask,
    ),
    CalendarScreen(tarefas: _tarefas),
  ];

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return MaterialApp(home: LoginScreen(onSubmit: _handleLogin));
    }

    return MaterialApp(
      title: 'App de Tarefas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Gerenciador de Tarefas'),
          actions: [
            if (_selectedIndex == 0)
              Builder(
                builder:
                    (context) => IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final newTask = await Navigator.push<Task>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TaskFormScreen(),
                          ),
                        );
                        if (newTask != null) {
                          _addOrUpdateTask(newTask);
                        }
                      },
                    ),
              ),
          ],
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.view_kanban),
              label: 'Trello',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Calendário',
            ),
          ],
        ),
      ),
    );
  }
}
