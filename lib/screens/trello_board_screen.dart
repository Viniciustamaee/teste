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
  late List<Task> _tarefasInternas;

  @override
  void initState() {
    super.initState();
    _tarefasInternas = widget.tarefas;
  }

  @override
  void didUpdateWidget(covariant TrelloBoardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tarefas != widget.tarefas) {
      setState(() {
        _tarefasInternas = widget.tarefas;
      });
    }
  }

  // List<Task> getTasksByStatus(String status) {
  //   final resultado =
  //       _tarefasInternas
  //           .where((task) => task.status.toLowerCase() == status.toLowerCase())
  //           .toList();

  //   debugPrint(resultado.toString());
  //   return resultado;
  // }

  List<Task> getTasksByStatus(String status) {
    final resultado =
        _tarefasInternas.where((task) {
          // Normaliza ambos os lados para comparação (remove espaços e coloca em minúsculo)
          final taskStatus = task.status.trim().toLowerCase().replaceAll(
            ' ',
            '',
          );
          final statusAlvo = status.trim().toLowerCase().replaceAll(' ', '');
          final isMatch = taskStatus == statusAlvo;

          debugPrint('Comparando: "$taskStatus" == "$statusAlvo" → $isMatch');
          return isMatch;
        }).toList();

    return resultado;
  }

  Color? getPriorityColor(String prioridade) {
    switch (prioridade) {
      case 'Alta':
        return Colors.red[200];
      case 'Média':
        return Colors.yellow[200];
      case 'Baixa':
        return Colors.green[200];
      default:
        return Colors.grey[300];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statusList = ['Pendente', 'Em Andamento', 'Concluído'];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children:
              statusList.map((status) {
                final tasks = getTasksByStatus(status);
                return Expanded(
                  child: Container(
                    height: constraints.maxHeight,
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[100],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child:
                              tasks.isEmpty
                                  ? const Text('Sem tarefas')
                                  : ListView.builder(
                                    itemCount: tasks.length,
                                    itemBuilder: (context, index) {
                                      final task = tasks[index];
                                      return Card(
                                        elevation: 2,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                task.titulo,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Data: ${_formatDate(task.data)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: getPriorityColor(
                                                    task.prioridade,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  task.prioridade,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: PopupMenuButton<String>(
                                                  onSelected: (value) {
                                                    if (value == 'excluir') {
                                                      widget.onDelete(task);
                                                    }
                                                  },
                                                  itemBuilder:
                                                      (context) => const [
                                                        PopupMenuItem(
                                                          value: 'excluir',
                                                          child: Text(
                                                            'Excluir',
                                                          ),
                                                        ),
                                                      ],
                                                ),
                                              ),
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
