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
  late String _titulo, _descricao, _prioridade, _status;
  late DateTime _data;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titulo = t?.titulo ?? '';
    _descricao = t?.descricao ?? '';
    _data = t?.data ?? DateTime.now();
    _prioridade = t?.prioridade ?? 'Baixa';
    _status = t?.status ?? 'Pendente';
  }

  Future<void> _selectDate() async {
    var picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _data = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final task = Task(
      id: widget.task?.id,
      titulo: _titulo,
      descricao: _descricao,
      data: _data,
      prioridade: _prioridade,
      status: _status,
    );
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext ctx) {
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
                validator: (v) => v!.isEmpty ? 'Informe o título' : null,
                onSaved: (v) => _titulo = v!,
              ),
              TextFormField(
                initialValue: _descricao,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
                onSaved: (v) => _descricao = v!,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Data: ${_data.toString().split(' ')[0]}'),
                  const SizedBox(width: 16),
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
                onChanged: (v) => setState(() => _prioridade = v!),
                onSaved: (v) => _prioridade = v!,
              ),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'Pendente', child: Text('Pendente')),
                  DropdownMenuItem(
                    value: 'Em Andamento',
                    child: Text('Em Andamento'),
                  ),
                  DropdownMenuItem(
                    value: 'Concluído',
                    child: Text('Concluído'),
                  ),
                ],
                onChanged: (v) => setState(() => _status = v!),
                onSaved: (v) => _status = v!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}