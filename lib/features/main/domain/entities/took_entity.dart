import 'package:noveles/features/main/domain/entities/entities.dart';

class TookEntity {
  final int id;
  final DateTime createdAt;
  final String cover;
  final String number;
  final String title;
  final String content;
  final List<ChapterEntity> listChapter;

  TookEntity({
    required this.id,
    required this.createdAt,
    required this.cover,
    required this.number,
    required this.title,
    required this.content,
    required this.listChapter,
  });

  TookEntity copyWith({
    int? id,
    DateTime? createdAt,
    String? cover,
    String? number,
    String? title,
    String? content,
    List<ChapterEntity>? listChapter,
  }) {
    return TookEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      cover: cover ?? this.cover,
      number: number ?? this.number,
      title: title ?? this.title,
      content: content ?? this.content,
      listChapter: listChapter ?? this.listChapter,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'cover': cover,
      'number': number,
      'title': title,
      'content': content,
      'listChapter': listChapter.map((chapter) => chapter.toMap()).toList(),
    };
  }

  factory TookEntity.fromMap(Map<String, dynamic> map) {
    return TookEntity(
      id: map['id'],
      createdAt: DateTime.parse(map['createdAt']),
      cover: map['cover'],
      number: map['number'],
      title: map['title'],
      content: map['content'],
      listChapter: List<ChapterEntity>.from(
        map['listChapter'].map((item) => ChapterEntity.fromMap(item)),
      ),
    );
  }
}