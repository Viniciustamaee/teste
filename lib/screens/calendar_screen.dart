import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';

class CalendarScreen extends StatefulWidget {
  final List<Task> tarefas;

  const CalendarScreen({super.key, required this.tarefas});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<String, List<Task>> _groupedTasks = {};

  @override
  void initState() {
    super.initState();
    _groupTasks();
  }

  void _groupTasks() {
    _groupedTasks.clear();
    for (var task in widget.tarefas) {
      final day = task.data.toLocal().toString().split(' ')[0];
      _groupedTasks.putIfAbsent(day, () => []).add(task);
    }
  }

  List<Task> _getTasksForDay(DateTime day) {
    final key = day.toLocal().toString().split(' ')[0];
    return _groupedTasks[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarFormat: CalendarFormat.month,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
        Expanded(
          child:
              _selectedDay == null
                  ? const Center(child: Text('Selecione um dia no calendário'))
                  : _buildTaskList(_selectedDay!),
        ),
      ],
    );
  }

  Widget _buildTaskList(DateTime day) {
    final tasks = _getTasksForDay(day);

    if (tasks.isEmpty) {
      return const Center(child: Text('Nenhuma tarefa para esse dia'));
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        Color? badgeColor;
        switch (task.prioridade) {
          case 'Alta':
            badgeColor = Colors.red[200];
            break;
          case 'Média':
            badgeColor = Colors.yellow[200];
            break;
          case 'Baixa':
            badgeColor = Colors.green[200];
            break;
          default:
            badgeColor = Colors.grey[300];
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 238, 234, 234),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(31, 20, 24, 211),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Infos da tarefa
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.titulo,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.descricao,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Badge de prioridade
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    task.prioridade,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
