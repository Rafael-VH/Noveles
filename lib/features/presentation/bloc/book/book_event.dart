import 'package:equatable/equatable.dart';

abstract class BookEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadBooks extends BookEvent {}

class LoadBookById extends BookEvent {
  final int id;

  LoadBookById(this.id);

  @override
  List<Object> get props => [id];
}
