import 'package:equatable/equatable.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';

abstract class ChapterState extends Equatable {
  const ChapterState();

  @override
  List<Object> get props => [];
}

/// Legacy state: initial state before any loading starts.
class ChapterInitial extends ChapterState {}

/// Legacy state: emitted while the full batch is being loaded.
class ChapterLoading extends ChapterState {}

/// Legacy state: emitted when all chapters have been loaded.
class ChapterLoaded extends ChapterState {
  final List<ChapterEntity> chapters;
  final int initialIndex;

  ChapterLoaded(this.chapters, {this.initialIndex = 0});

  @override
  List<Object> get props => [chapters, initialIndex];
}

/// Legacy state: emitted when loading fails.
class ChapterError extends ChapterState {
  final String message;

  ChapterError(this.message);

  @override
  List<Object> get props => [message];
}

/// Emitted when a single chapter has been loaded and added to the cache.
class ChapterSingleLoaded extends ChapterState {
  final Map<int, ChapterEntity> cache;
  final int currentIndex;
  final int totalCount;
  final List<int> chapterOrder;

  const ChapterSingleLoaded({
    required this.cache,
    required this.currentIndex,
    required this.totalCount,
    required this.chapterOrder,
  });

  @override
  List<Object> get props => [cache, currentIndex, totalCount, chapterOrder];
}

/// Emitted when loading a specific chapter fails.
class ChapterLoadError extends ChapterState {
  final int index;
  final String message;

  const ChapterLoadError({required this.index, required this.message});

  @override
  List<Object> get props => [index, message];
}

/// Emitted while adjacent chapters are being preloaded in the background.
class ChapterPreloading extends ChapterState {
  final Set<int> indices;

  const ChapterPreloading({required this.indices});

  @override
  List<Object> get props => [indices];
}
