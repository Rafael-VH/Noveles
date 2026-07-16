import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/get_chapter_content.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_event.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_state.dart';

class ChapterBloc extends Bloc<ChapterEvent, ChapterState> {
  final GetChapterContent getChapterContent;

  ChapterBloc({required this.getChapterContent}) : super(ChapterInitial()) {
    on<LoadChapterContent>(_onLoadContent);
  }

  Future<void> _onLoadContent(
    LoadChapterContent event,
    Emitter<ChapterState> emit,
  ) async {
    emit(ChapterLoading());

    // Cargar todos los contenidos en paralelo
    final contentResults = await Future.wait(
      event.chapters.map((ch) => getChapterContent(ch.content)),
    );

    final resolved = <ChapterEntity>[];
    for (var i = 0; i < event.chapters.length; i++) {
      final ch = event.chapters[i];
      final result = contentResults[i];

      switch (result) {
        case Ok(:final value):
          resolved.add(ChapterEntity(
            id: ch.id,
            createdAt: ch.createdAt,
            number: ch.number,
            title: ch.title,
            content: value,
            tookId: ch.tookId,
          ));
        case Err(:final error):
          emit(ChapterError('Error al cargar capítulos: ${error.message}'));
          return;
      }
    }

    if (emit.isDone) return;
    emit(ChapterLoaded(resolved, initialIndex: event.initialIndex));
  }
}
