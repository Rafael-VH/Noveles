import 'package:equatable/equatable.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';

class TookEntity extends Equatable {
  final int id;
  final DateTime createdAt;
  final String cover;
  final String number;
  final String title;
  final int chapterCount;
  final int bookId;
  final List<int> listChapterIds;
  final List<ChapterEntity> chapters;
  final String? createdBy;

  const TookEntity({
    required this.id,
    required this.createdAt,
    required this.cover,
    required this.number,
    required this.title,
    required this.chapterCount,
    required this.bookId,
    this.listChapterIds = const [],
    this.chapters = const [],
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
        listChapterIds,
        chapters,
        createdBy,
      ];
}
