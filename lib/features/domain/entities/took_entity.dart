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
}
