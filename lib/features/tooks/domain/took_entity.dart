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

  TookEntity copyWith({
    int? id,
    DateTime? createdAt,
    String? cover,
    String? number,
    String? title,
    int? chapterCount,
    int? bookId,
    List<ChapterEntity>? listChapter,
    String? createdBy,
  }) {
    return TookEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      cover: cover ?? this.cover,
      number: number ?? this.number,
      title: title ?? this.title,
      chapterCount: chapterCount ?? this.chapterCount,
      bookId: bookId ?? this.bookId,
      listChapter: listChapter ?? this.listChapter,
      createdBy: createdBy ?? this.createdBy,
    );
  }

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
