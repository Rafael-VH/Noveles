import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:noveles/features/chapters/presentation/bloc/chapter_event.dart';
export 'package:noveles/features/chapters/presentation/bloc/chapter_state.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_ref.dart';
import 'package:noveles/features/chapters/domain/get_chapter_content.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_event.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_state.dart';

class ChapterBloc extends Bloc<ChapterEvent, ChapterState> {
  final GetChapterContent getChapterContent;

  /// Lazy cache: chapterId → loaded ChapterEntity with resolved content.
  final Map<int, ChapterEntity> _cache = {};

  /// Ordered list of chapter IDs derived from refs.
  List<int> _chapterOrder = [];

  ChapterBloc({required this.getChapterContent}) : super(ChapterInitial()) {
    on<LoadChapterByIndex>(_onLoadByIndex);
    on<PreloadAdjacent>(_onPreloadAdjacent);
  }

  /// Load a single chapter by its index and emit [ChapterSingleLoaded].
  Future<void> _onLoadByIndex(
    LoadChapterByIndex event,
    Emitter<ChapterState> emit,
  ) async {
    _setChapterOrder(event.refs);

    final ref = event.refs[event.index];
    final result = await getChapterContent(ref.content, contentType: ref.contentType);

    switch (result) {
      case Ok(:final value):
        _cache[ref.id] = ChapterEntity(
          id: ref.id,
          createdAt: DateTime(0),
          number: ref.number,
          title: ref.title,
          content: value,
          tookId: ref.tookId,
          contentType: ref.contentType,
        );
        emit(ChapterSingleLoaded(
          cache: Map.unmodifiable(_cache),
          currentIndex: event.index,
          totalCount: event.refs.length,
          chapterOrder: List.unmodifiable(_chapterOrder),
        ));
      case Err(:final error):
        emit(ChapterLoadError(index: event.index, message: error.message));
    }
  }

  /// Preload the next 3 chapters after [currentIndex] in parallel.
  /// Skips chapters already in the cache. Emits [ChapterPreloading] while
  /// loading, then [ChapterSingleLoaded] with the updated cache.
  Future<void> _onPreloadAdjacent(
    PreloadAdjacent event,
    Emitter<ChapterState> emit,
  ) async {
    _setChapterOrder(event.refs);

    final indicesToLoad = <int>[];
    for (var offset = 1; offset <= 3; offset++) {
      final targetIndex = event.currentIndex + offset;
      if (targetIndex >= event.refs.length) break;
      final ref = event.refs[targetIndex];
      if (_cache.containsKey(ref.id)) continue;
      indicesToLoad.add(targetIndex);
    }

    if (indicesToLoad.isEmpty) return;

    emit(ChapterPreloading(indices: indicesToLoad.toSet()));

    final results = await Future.wait(
      indicesToLoad.map((i) async {
        final ref = event.refs[i];
        final result = await getChapterContent(ref.content, contentType: ref.contentType);
        return (index: i, ref: ref, result: result);
      }),
    );

    for (final entry in results) {
      switch (entry.result) {
        case Ok(:final value):
          final ref = entry.ref;
          _cache[ref.id] = ChapterEntity(
            id: ref.id,
            createdAt: DateTime(0),
            number: ref.number,
            title: ref.title,
            content: value,
            tookId: ref.tookId,
            contentType: ref.contentType,
          );
        case Err():
          // Preload errors are non-fatal — skip and continue.
          break;
      }
    }

    if (emit.isDone) return;
    emit(ChapterSingleLoaded(
      cache: Map.unmodifiable(_cache),
      currentIndex: event.currentIndex,
      totalCount: event.refs.length,
      chapterOrder: List.unmodifiable(_chapterOrder),
    ));
  }

  /// Derive chapter order from refs, preserving previous order if refs haven't changed.
  void _setChapterOrder(List<ChapterRef> refs) {
    final newOrder = refs.map((r) => r.id).toList();
    if (_chapterOrder.isEmpty || !_listEquals(_chapterOrder, newOrder)) {
      _chapterOrder = newOrder;
    }
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
