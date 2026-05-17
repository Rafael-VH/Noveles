import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/entities.dart';

abstract class ChapterEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadChapterContent extends ChapterEvent {
  final int initialIndex;
  final List<ChapterEntity> chapters;

  LoadChapterContent({required this.initialIndex, required this.chapters});

  @override
  List<Object> get props => [initialIndex, chapters];
}
