class Cidade {
  final String nome;
  final String pais;
  final int temperatura;
  final String clima;
  final String descClima;
  final String atividade;
  final String roupa;
  final String icone;
  final String imageUrl;

  Cidade({
    required this.nome,
    required this.pais,
    required this.temperatura,
    required this.clima,
    required this.descClima,
    required this.atividade,
    required this.roupa,
    required this.icone,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'pais': pais,
      'temperatura': temperatura,
      'clima': clima,
      'descClima': descClima,
      'atividade': atividade,
      'roupa': roupa,
      'icone': icone,
      'imageUrl': imageUrl,
    };
  }

  factory Cidade.fromMap(Map<String, dynamic> map) {
    return Cidade(
      nome: map['nome'] ?? '',
      pais: map['pais'] ?? '',
      temperatura: map['temperatura'] ?? 0,
      clima: map['clima'] ?? '',
      descClima: map['descClima'] ?? '',
      atividade: map['atividade'] ?? '',
      roupa: map['roupa'] ?? '',
      icone: map['icone'] ?? '☀️',
      imageUrl: map['imageUrl'] ?? 'https://images.unsplash.com/photo-1504608524841-42fe6f032b4b',
    );
  }
}

class Experiencia {
  final String id;
  final String cidade;
  final String data;
  final String clima;
  final int temperatura;

  Experiencia({
    required this.id,
    required this.cidade,
    required this.data,
    required this.clima,
    required this.temperatura,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cidade': cidade,
      'data': data,
      'clima': clima,
      'temperatura': temperatura,
    };
  }

  factory Experiencia.fromMap(Map<String, dynamic> map) {
    return Experiencia(
      id: map['id'] ?? '',
      cidade: map['cidade'] ?? '',
      data: map['data'] ?? '',
      clima: map['clima'] ?? '',
      temperatura: map['temperatura'] ?? 0,
    );
  }
}