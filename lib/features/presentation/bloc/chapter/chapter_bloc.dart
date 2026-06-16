import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/get_chapter_content.dart';
import 'package:noveles/features/presentation/bloc/chapter/chapter_event.dart';
import 'package:noveles/features/presentation/bloc/chapter/chapter_state.dart';

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
    try {
      final resolved = await Future.wait(
        event.chapters.map((ch) async {
          final content = await getChapterContent(ch.content);
          return ChapterEntity(
            id: ch.id,
            createdAt: ch.createdAt,
            number: ch.number,
            title: ch.title,
            content: content,
            tookId: ch.tookId,
          );
        }),
      );
      if (emit.isDone) return;
      emit(ChapterLoaded(resolved, initialIndex: event.initialIndex));
    } catch (e) {
      emit(ChapterError('Error al cargar capítulos: $e'));
    }
  }
}
