class ChapterLocalModel {
  final int id;
  final DateTime createdAt;
  final String number;
  final String title;
  final String content;

  ChapterLocalModel({
    required this.id,
    required this.createdAt,
    required this.number,
    required this.title,
    required this.content,
  });

  //  Se utiliza para actualizar los datos del 'Capitulo' sin modificar la instancia original.
  ChapterLocalModel copyWith({
    int? id,
    DateTime? createdAt,
    String? number,
    String? title,
    String? content,
  }) {
    return ChapterLocalModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      number: number ?? this.number,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  //  Devuelve un mapa de las propiedades del 'Capitulo'.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
      'number': number,
      'title': title,
      'content': content,
    };
  }

  //  Devuelve un mapa de las propiedades del 'Capitulo' en formato JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'number': number,
      'title': title,
      'content': content,
    };
  }

  //  Convierte un mapa JSON en una instancia de ChapterModel.
  factory ChapterLocalModel.fromJson(Map<String, dynamic> json) {
    return ChapterLocalModel(
      id: json['id'],
      createdAt: json['createdAt'],
      number: json['number'],
      title: json['title'],
      content: json['content'],
    );
  }
}
