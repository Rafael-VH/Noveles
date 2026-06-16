import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/presentation/notification_service.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/create_chapter.dart';
import 'package:noveles/features/chapters/domain/update_chapter.dart';
import 'package:noveles/features/chapters/domain/delete_chapter.dart';

// Events
abstract class ScanChapterEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SaveScanChapter extends ScanChapterEvent {
  final ChapterEntity chapter;
  final bool isUpdate;
  SaveScanChapter(this.chapter, {required this.isUpdate});
  @override
  List<Object> get props => [chapter, isUpdate];
}

class DeleteScanChapter extends ScanChapterEvent {
  final int chapterId;
  DeleteScanChapter(this.chapterId);
  @override
  List<Object> get props => [chapterId];
}

// States
abstract class ScanChapterState extends Equatable {
  @override
  List<Object> get props => [];
}

class ScanChapterInitial extends ScanChapterState {}

class ScanChapterLoading extends ScanChapterState {}

class ScanChapterLoaded extends ScanChapterState {
  final String? message;
  ScanChapterLoaded({this.message});
  @override
  List<Object> get props => [message ?? ''];
}

class ScanChapterError extends ScanChapterState {
  final String message;
  ScanChapterError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class ScanChapterBloc extends Bloc<ScanChapterEvent, ScanChapterState> {
  final CreateChapter createChapter;
  final UpdateChapter updateChapter;
  final DeleteChapter deleteChapter;

  ScanChapterBloc({
    required this.createChapter,
    required this.updateChapter,
    required this.deleteChapter,
  }) : super(ScanChapterInitial()) {
    on<SaveScanChapter>(_onSaveChapter);
    on<DeleteScanChapter>(_onDeleteChapter);
  }

  Future<void> _onSaveChapter(SaveScanChapter event, Emitter<ScanChapterState> emit) async {
    emit(ScanChapterLoading());
    final result = event.isUpdate ? await updateChapter(event.chapter) : await createChapter(event.chapter);
    switch (result) {
      case Ok():
        emit(ScanChapterLoaded(message: event.isUpdate ? 'Capítulo guardado' : 'Capítulo creado'));
      case Err(:final error):
        emit(ScanChapterError(error.message));
        NotificationService.error('Error al guardar el capítulo: ${error.message}');
    }
  }

  Future<void> _onDeleteChapter(DeleteScanChapter event, Emitter<ScanChapterState> emit) async {
    emit(ScanChapterLoading());
    final result = await deleteChapter(event.chapterId);
    switch (result) {
      case Ok():
        emit(ScanChapterLoaded(message: 'Capítulo eliminado'));
      case Err(:final error):
        emit(ScanChapterError(error.message));
        NotificationService.error('Error al eliminar el capítulo: ${error.message}');
    }
  }
}
