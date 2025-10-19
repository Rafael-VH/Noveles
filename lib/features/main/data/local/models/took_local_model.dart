import 'package:noveles/features/main/data/local/models/model.dart';

class TookLocalModel {
  final int id;
  final DateTime createdAt;
  final String cover;
  final String number;
  final String title;
  final String content;
  final List<ChapterLocalModel> listChapter;

  TookLocalModel({
    required this.id,
    required this.createdAt,
    required this.cover,
    required this.number,
    required this.title,
    required this.content,
    required this.listChapter,
  });

  //  Se utiliza para actualizar los datos del 'Tomo' sin modificar la instancia original.
  TookLocalModel copyWith({
    int? id,
    DateTime? createdAt,
    String? cover,
    String? number,
    String? title,
    String? content,
    List<ChapterLocalModel>? listChapter,
  }) {
    return TookLocalModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      cover: cover ?? this.cover,
      number: number ?? this.number,
      title: title ?? this.title,
      content: content ?? this.content,
      listChapter: listChapter ?? this.listChapter,
    );
  }

  //  Devuelve un mapa de las propiedades del 'Tomo'.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
      'cover': cover,
      'number': number,
      'title': title,
      'content': content,
      'listChapter': listChapter.toList(),
    };
  }

  //  Devuelve un mapa de las propiedades del 'Tomo' en formato JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'cover': cover,
      'number': number,
      'title': title,
      'content': content,
      'listChapter': listChapter.toList(),
    };
  }

  //  Convierte un mapa JSON en una instancia de TookModel.
  factory TookLocalModel.fromJson(Map<String, dynamic> json) {
    return TookLocalModel(
      id: json['id'],
      createdAt: json['createdAt'],
      cover: json['cover'],
      number: json['number'],
      title: json['title'],
      content: json['content'],
      listChapter: json['listChapter'],
    );
  }
}
