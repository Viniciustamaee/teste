// screens/trello_board_screen.dart
import 'package:flutter/material.dart';
import '../models/task.dart';

class TrelloBoardScreen extends StatefulWidget {
  final List<Task> tarefas;
  final Function(Task) onEdit;
  final Function(Task) onDelete;

  const TrelloBoardScreen({
    super.key,
    required this.tarefas,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TrelloBoardScreen> createState() => _TrelloBoardScreenState();
}

class _TrelloBoardScreenState extends State<TrelloBoardScreen> {
  List<Task> getTasksByPriority(String priority) {
    return widget.tarefas
        .where((task) => task.prioridade == priority)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final prioridades = ['Alta', 'Média', 'Baixa'];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: prioridades.map((priority) {
            final tasks = getTasksByPriority(priority);
            return Expanded(
              child: Container(
                height: constraints.maxHeight,
                padding: const EdgeInsets.all(8),
                color: priority == 'Alta'
                    ? Colors.red[100]
                    : priority == 'Média'
                        ? Colors.yellow[100]
                        : Colors.green[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      priority,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: tasks.isEmpty
                          ? const Text('Sem tarefas')
                          : ListView.builder(
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    dense: true,
                                    title: Text(
                                      task.titulo,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'editar') {
                                          widget.onEdit(task);
                                        } else if (value == 'excluir') {
                                          widget.onDelete(task);
                                        }
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                            value: 'editar',
                                            child: Text('Editar')),
                                        PopupMenuItem(
                                            value: 'excluir',
                                            child: Text('Excluir')),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
