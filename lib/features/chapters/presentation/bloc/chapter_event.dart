import 'package:equatable/equatable.dart';
import 'package:noveles/features/chapters/domain/chapter_ref.dart';

abstract class ChapterEvent extends Equatable {
  const ChapterEvent();

  @override
  List<Object> get props => [];
}

class LoadChapterContent extends ChapterEvent {
  final int initialIndex;
  final List<ChapterRef> chapters;

  const LoadChapterContent({required this.initialIndex, required this.chapters});

  @override
  List<Object> get props => [initialIndex, chapters];
}
