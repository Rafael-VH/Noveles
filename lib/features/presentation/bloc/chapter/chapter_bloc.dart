import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
import 'package:noveles/features/presentation/bloc/chapter/chapter_event.dart';
import 'package:noveles/features/presentation/bloc/chapter/chapter_state.dart';

// ChapterBloc es una clase que extiende Bloc y se encarga de manejar los eventos relacionados con los capítulos y emitir los estados correspondientes.
class ChapterBloc extends Bloc<ChapterEvent, ChapterState> {
  final GetChapterContent getChapterContent;

  ChapterBloc({required this.getChapterContent}) : super(ChapterInitial()) {
    on<LoadChapterContent>(_onLoadContent);
  }

  // Método que maneja el evento LoadChapterContent, que se encarga de cargar el contenido de un capítulo específico. Este método emite un estado de carga mientras se realiza la operación, y luego emite un estado de éxito con la lista de capítulos cargados o un estado de error si ocurre algún problema durante la carga.
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
