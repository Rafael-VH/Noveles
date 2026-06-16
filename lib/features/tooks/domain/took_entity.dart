import 'package:equatable/equatable.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';

class TookEntity extends Equatable {
  final int id;
  final DateTime createdAt;
  final String cover;
  final String number;
  final String title;
  final String chapterCount;
  final int bookId;
  final List<ChapterEntity> listChapter;
  final String? createdBy;

  const TookEntity({
    required this.id,
    required this.createdAt,
    required this.cover,
    required this.number,
    required this.title,
    required this.chapterCount,
    required this.bookId,
    required this.listChapter,
    this.createdBy,
  });

  @override
  List<Object?> get props => [
        id,
        createdAt,
        cover,
        number,
        title,
        chapterCount,
        bookId,
        listChapter,
        createdBy,
      ];
}
