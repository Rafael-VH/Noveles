import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/chapter_entity.dart';

class TookEntity extends Equatable {
  final int id;
  final DateTime createdAt;
  final String cover;
  final String number;
  final String title;
  final String content;
  final int bookId;
  final List<ChapterEntity> listChapter;

  const TookEntity({
    required this.id,
    required this.createdAt,
    required this.cover,
    required this.number,
    required this.title,
    required this.content,
    required this.bookId,
    required this.listChapter,
  });

  @override
  List<Object> get props => [
        id,
        createdAt,
        cover,
        number,
        title,
        content,
        bookId,
        listChapter,
      ];
}
