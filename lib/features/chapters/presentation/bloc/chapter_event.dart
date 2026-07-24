import 'package:equatable/equatable.dart';
import 'package:noveles/features/chapters/domain/chapter_ref.dart';

abstract class ChapterEvent extends Equatable {
  const ChapterEvent();

  @override
  List<Object> get props => [];
}

/// Legacy event: loads all chapters at once via Future.wait.
/// Kept for backwards compatibility — will be removed in the bloc rewrite (T5).
class LoadChapterContent extends ChapterEvent {
  final int initialIndex;
  final List<ChapterRef> chapters;

  const LoadChapterContent({required this.initialIndex, required this.chapters});

  @override
  List<Object> get props => [initialIndex, chapters];
}

/// Load a single chapter by its index in the full chapters list.
class LoadChapterByIndex extends ChapterEvent {
  final int index;
  final List<ChapterRef> refs;

  const LoadChapterByIndex({required this.index, required this.refs});

  @override
  List<Object> get props => [index, refs];
}

/// Preload adjacent chapters around the current position.
class PreloadAdjacent extends ChapterEvent {
  final int currentIndex;
  final List<ChapterRef> refs;

  const PreloadAdjacent({required this.currentIndex, required this.refs});

  @override
  List<Object> get props => [currentIndex, refs];
}
