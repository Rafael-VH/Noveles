import 'package:equatable/equatable.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';

abstract class ChapterState extends Equatable {
  @override
  List<Object> get props => [];
}

class ChapterInitial extends ChapterState {}

class ChapterLoading extends ChapterState {}

class ChapterLoaded extends ChapterState {
  final List<ChapterEntity> chapters;
  final int initialIndex;

  ChapterLoaded(this.chapters, {this.initialIndex = 0});

  @override
  List<Object> get props => [chapters, initialIndex];
}

class ChapterError extends ChapterState {
  final String message;

  ChapterError(this.message);

  @override
  List<Object> get props => [message];
}
