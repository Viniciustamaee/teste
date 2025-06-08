class Task {
  final String id; // Atenção: você está usando String, mas no banco é INTEGER PRIMARY KEY
  String titulo;
  String descricao;
  DateTime data;
  String prioridade;
  String status;

  Task({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.prioridade,
    required this.status,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id_tarefa'].toString(), // Convertendo o int do banco para String
      titulo: map['titulo'],
      descricao: map['descricao'],
      data: DateTime.parse(map['data_entrega']), // ISO8601
      prioridade: map['prioridade'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_tarefa': int.tryParse(id), // Convertendo de volta para int no banco
      'titulo': titulo,
      'descricao': descricao,
      'data_entrega': data.toIso8601String(),
      'prioridade': prioridade,
      'status': status,
    };
  }
}
