import 'package:noveles/features/data/local/models/model.dart';

class TookLocalModel {
  final int id;
  final DateTime createdAt;
  final String cover;
  final String number;
  final String title;
  final String content;
  final int bookId;
  final List<ChapterLocalModel> listChapter;

  TookLocalModel({
    required this.id,
    required this.createdAt,
    required this.cover,
    required this.number,
    required this.title,
    required this.content,
    required this.bookId,
    required this.listChapter,
  });

  TookLocalModel copyWith({
    int? id,
    DateTime? createdAt,
    String? cover,
    String? number,
    String? title,
    String? content,
    int? bookId,
    List<ChapterLocalModel>? listChapter,
  }) {
    return TookLocalModel(
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
      'createdAt': createdAt,
      'cover': cover,
      'number': number,
      'title': title,
      'content': content,
      'bookId': bookId,
      'listChapter': listChapter.toList(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'cover': cover,
      'number': number,
      'title': title,
      'content': content,
      'bookId': bookId,
      'listChapter': listChapter.toList(),
    };
  }

  factory TookLocalModel.fromJson(Map<String, dynamic> json) {
    return TookLocalModel(
      id: json['id'],
      createdAt: json['createdAt'],
      cover: json['cover'],
      number: json['number'],
      title: json['title'],
      content: json['content'],
      bookId: json['bookId'] ?? 0,
      listChapter: json['listChapter'],
    );
  }
}
