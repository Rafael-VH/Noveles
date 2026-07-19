import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/domain/create_chapter.dart';
import 'package:noveles/features/chapters/domain/update_chapter.dart';
import 'package:noveles/features/chapters/domain/delete_chapter.dart';
import 'package:noveles/features/chapters/domain/upload_chapter_content.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_chapter_event.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_chapter_state.dart';

export 'package:noveles/features/scan/presentation/bloc/scan_chapter_event.dart';
export 'package:noveles/features/scan/presentation/bloc/scan_chapter_state.dart';

class ScanChapterBloc extends Bloc<ScanChapterEvent, ScanChapterState> {
  final CreateChapter createChapter;
  final UpdateChapter updateChapter;
  final DeleteChapter deleteChapter;
  final UploadChapterContent uploadContent;

  ScanChapterBloc({
    required this.createChapter,
    required this.updateChapter,
    required this.deleteChapter,
    required this.uploadContent,
  }) : super(ScanChapterInitial()) {
    on<SaveScanChapter>(_onSaveChapter);
    on<DeleteScanChapter>(_onDeleteChapter);
    on<UploadChapterFile>(_onUploadContent);
  }

  Future<void> _onSaveChapter(SaveScanChapter event, Emitter<ScanChapterState> emit) async {
    emit(ScanChapterLoading());
    final result = event.isUpdate ? await updateChapter(event.chapter) : await createChapter(event.chapter);
    switch (result) {
      case Ok():
        emit(ScanChapterLoaded(message: event.isUpdate ? 'Capítulo guardado' : 'Capítulo creado'));
      case Err(:final error):
        emit(ScanChapterError(error.message));
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
    }
  }

  Future<void> _onUploadContent(UploadChapterFile event, Emitter<ScanChapterState> emit) async {
    final result = await uploadContent(event.filePath);
    switch (result) {
      case Ok(:final value):
        emit(ScanChapterContentUploaded(value));
      case Err(:final error):
        emit(ScanChapterError(error.message));
    }
  }
}
