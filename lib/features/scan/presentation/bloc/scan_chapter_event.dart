import 'package:equatable/equatable.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';

abstract class ScanChapterEvent extends Equatable {
  const ScanChapterEvent();
  @override
  List<Object> get props => [];
}

class SaveScanChapter extends ScanChapterEvent {
  final ChapterEntity chapter;
  final bool isUpdate;
  const SaveScanChapter(this.chapter, {required this.isUpdate});
  @override
  List<Object> get props => [chapter, isUpdate];
}

class DeleteScanChapter extends ScanChapterEvent {
  final int chapterId;
  const DeleteScanChapter(this.chapterId);
  @override
  List<Object> get props => [chapterId];
}

class UploadChapterFile extends ScanChapterEvent {
  final String filePath;
  const UploadChapterFile(this.filePath);
  @override
  List<Object> get props => [filePath];
}
