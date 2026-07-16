import 'package:equatable/equatable.dart';

abstract class LabelEvent extends Equatable {
  const LabelEvent();
}

class LoadLabels extends LabelEvent {
  const LoadLabels();
  @override
  List<Object> get props => [];
}

class CreateLabelEvent extends LabelEvent {
  final String name;
  final String color;
  const CreateLabelEvent(this.name, this.color);
  @override
  List<Object> get props => [name, color];
}

class DeleteLabelEvent extends LabelEvent {
  final int id;
  const DeleteLabelEvent(this.id);
  @override
  List<Object> get props => [id];
}

class AssignLabelEvent extends LabelEvent {
  final int bookId;
  final int labelId;
  const AssignLabelEvent(this.bookId, this.labelId);
  @override
  List<Object> get props => [bookId, labelId];
}

class RemoveLabelEvent extends LabelEvent {
  final int bookId;
  final int labelId;
  const RemoveLabelEvent(this.bookId, this.labelId);
  @override
  List<Object> get props => [bookId, labelId];
}
