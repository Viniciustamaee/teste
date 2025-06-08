// screens/task_form_screen.dart
import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _titulo;
  late String _descricao;
  late DateTime _data;
  late String _prioridade;
  late String _status;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titulo = task?.titulo ?? '';
    _descricao = task?.descricao ?? '';
    _data = task?.data ?? DateTime.now();
    _prioridade = task?.prioridade ?? 'Baixa';
    _status = task?.status ?? 'Pendente';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _data) {
      setState(() {
        _data = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final id = widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final task = Task(
      id: id,
      titulo: _titulo,
      descricao: _descricao,
      data: _data,
      prioridade: _prioridade,
      status: _status,
    );
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Nova Tarefa' : 'Editar Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _titulo,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o título';
                  }
                  return null;
                },
                onSaved: (value) => _titulo = value ?? '',
              ),
              TextFormField(
                initialValue: _descricao,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
                onSaved: (value) => _descricao = value ?? '',
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Data: ${_data.toLocal().toString().split(' ')[0]}'),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _selectDate,
                    child: const Text('Selecionar data'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _prioridade,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                items: const [
                  DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                  DropdownMenuItem(value: 'Média', child: Text('Média')),
                  DropdownMenuItem(value: 'Baixa', child: Text('Baixa')),
                ],
                onChanged: (value) => setState(() => _prioridade = value ?? 'Baixa'),
                onSaved: (value) => _prioridade = value ?? 'Baixa',
              ),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'Pendente', child: Text('Pendente')),
                  DropdownMenuItem(value: 'Em andamento', child: Text('Em andamento')),
                  DropdownMenuItem(value: 'Concluído', child: Text('Concluído')),
                ],
                onChanged: (value) => setState(() => _status = value ?? 'Pendente'),
                onSaved: (value) => _status = value ?? 'Pendente',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}