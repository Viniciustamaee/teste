// screens/calendar_screen.dart
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
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
        Expanded(
          child: _selectedDay == null
              ? Center(child: Text('Selecione um dia no calendário'))
              : _buildTaskList(_selectedDay!),
        )
      ],
    );
  }

  Widget _buildTaskList(DateTime day) {
    final tasks = _getTasksForDay(day);

    if (tasks.isEmpty) {
      return Center(child: Text('Nenhuma tarefa para esse dia'));
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          title: Text(task.titulo),
          subtitle: Text(task.descricao),
          trailing: Text(task.prioridade),
        );
      },
    );
  }
}
