import 'package:equatable/equatable.dart';
import 'package:noveles/features/labels/domain/label_entity.dart';

abstract class LabelState extends Equatable {
  const LabelState();
}

class LabelInitial extends LabelState {
  const LabelInitial();
  @override
  List<Object> get props => [];
}

class LabelLoading extends LabelState {
  const LabelLoading();
  @override
  List<Object> get props => [];
}

class LabelLoaded extends LabelState {
  final List<LabelEntity> labels;
  final Map<int, Set<int>> bookLabels;
  final String? message;
  const LabelLoaded(this.labels, this.bookLabels, {this.message});
  @override
  List<Object> get props => [labels, bookLabels, message ?? ''];
}

class LabelError extends LabelState {
  final String message;
  const LabelError(this.message);
  @override
  List<Object> get props => [message];
}
