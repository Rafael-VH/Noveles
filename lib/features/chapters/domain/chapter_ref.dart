import 'package:equatable/equatable.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';

/// Lightweight reference for chapter events.
///
/// Carries only the fields needed to initiate content loading,
/// avoiding the cost of passing full [ChapterEntity] objects through the event bus.
class ChapterRef extends Equatable {
  final int id;
  final String content;
  final String number;
  final String title;
  final int tookId;

  const ChapterRef({
    required this.id,
    required this.content,
    required this.number,
    required this.title,
    required this.tookId,
  });

  /// Create a [ChapterRef] from a [ChapterEntity].
  factory ChapterRef.fromEntity(ChapterEntity entity) => ChapterRef(
        id: entity.id,
        content: entity.content,
        number: entity.number,
        title: entity.title,
        tookId: entity.tookId,
      );

  @override
  List<Object> get props => [id, content, number, title, tookId];
}
