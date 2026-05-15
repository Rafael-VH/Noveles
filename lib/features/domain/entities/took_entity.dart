import 'package:noveles/features/domain/entities/entities.dart';

class TookEntity {
  final int id;
  final DateTime createdAt;
  final String cover;
  final String number;
  final String title;
  final String content;
  final int bookId;
  final List<ChapterEntity> listChapter;

  TookEntity({
    required this.id,
    required this.createdAt,
    required this.cover,
    required this.number,
    required this.title,
    required this.content,
    required this.bookId,
    required this.listChapter,
  });

  TookEntity copyWith({
    int? id,
    DateTime? createdAt,
    String? cover,
    String? number,
    String? title,
    String? content,
    int? bookId,
    List<ChapterEntity>? listChapter,
  }) {
    return TookEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      cover: cover ?? this.cover,
      number: number ?? this.number,
      title: title ?? this.title,
      content: content ?? this.content,
      bookId: bookId ?? this.bookId,
      listChapter: listChapter ?? this.listChapter,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'cover': cover,
      'number': number,
      'title': title,
      'content': content,
      'book_id': bookId,
      'listChapter': listChapter.map((chapter) => chapter.toMap()).toList(),
    };
  }

  factory TookEntity.fromMap(Map<String, dynamic> map) {
    return TookEntity(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      cover: map['cover'] ?? '',
      number: map['number'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      bookId: map['book_id'] ?? 0,
      listChapter: List<ChapterEntity>.from(
        map['listChapter'].map((item) => ChapterEntity.fromMap(item)),
      ),
    );
  }
}
