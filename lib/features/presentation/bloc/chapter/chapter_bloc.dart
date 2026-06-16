import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/presentation/notification_service.dart';
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
    final resolved = <ChapterEntity>[];
    for (final ch in event.chapters) {
      final result = await getChapterContent(ch.content);
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
          NotificationService.error(
              'Error al cargar capítulos: ${error.message}');
          return;
      }
    }
    if (emit.isDone) return;
    emit(ChapterLoaded(resolved, initialIndex: event.initialIndex));
  }
}
