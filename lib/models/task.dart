class Task {
  final int? id;
  String titulo;
  String descricao;
  DateTime data;
  String prioridade;
  String status;

  Task({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.prioridade,
    required this.status,
  });

  int? get idInt => id == null ? null : id;

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id_tarefa'],
      titulo: map['titulo'],
      descricao: map['descricao'],
      data: DateTime.parse(map['data_entrega']),
      prioridade: map['prioridade'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = {
      'titulo': titulo,
      'descricao': descricao,
      'data_entrega': data.toIso8601String(),
      'prioridade': prioridade,
      'status': status,
    };

    if (includeId && id != null) {
      map['id_tarefa'] = id!.toString();
    }

    return map;
  }
}
