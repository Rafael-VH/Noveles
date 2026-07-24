import 'package:equatable/equatable.dart';
import 'package:noveles/features/chapters/domain/chapter_content_type.dart';

class ChapterEntity extends Equatable {
  final int id;
  final DateTime createdAt;
  final String number;
  final String title;
  final String content;
  final int tookId;
  final String? createdBy;
  final ChapterContentType contentType;

  const ChapterEntity({
    required this.id,
    required this.createdAt,
    required this.number,
    required this.title,
    required this.content,
    required this.tookId,
    this.createdBy,
    this.contentType = ChapterContentType.storagePath,
  });

  ChapterEntity copyWith({
    int? id,
    DateTime? createdAt,
    String? number,
    String? title,
    String? content,
    int? tookId,
    String? createdBy,
    ChapterContentType? contentType,
  }) {
    return ChapterEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      number: number ?? this.number,
      title: title ?? this.title,
      content: content ?? this.content,
      tookId: tookId ?? this.tookId,
      createdBy: createdBy ?? this.createdBy,
      contentType: contentType ?? this.contentType,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        number,
        title,
        content,
        tookId,
        createdBy,
        contentType,
      ];
}
