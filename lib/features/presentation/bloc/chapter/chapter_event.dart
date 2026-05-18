import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/entities.dart';

// ChapterEvent es una clase abstracta que representa los diferentes eventos relacionados con la gestión de capítulos en la aplicación. Esta clase se extiende para crear eventos específicos como LoadChapterContent, que representa la solicitud de carga del contenido de un capítulo específico. Este evento contiene el índice inicial del capítulo a mostrar y la lista de capítulos disponibles para que el Bloc pueda cargar el contenido correspondiente y emitir el estado adecuado.
abstract class ChapterEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Evento que representa la solicitud de carga del contenido de un capítulo específico. Este evento se emite cuando se desea obtener el contenido de un capítulo en particular, y contiene el índice inicial del capítulo a mostrar y la lista de capítulos disponibles para que el Bloc pueda cargar el contenido correspondiente y emitir el estado adecuado.
class LoadChapterContent extends ChapterEvent {
  final int initialIndex;
  final List<ChapterEntity> chapters;

  LoadChapterContent({required this.initialIndex, required this.chapters});

  @override
  List<Object> get props => [initialIndex, chapters];
}
