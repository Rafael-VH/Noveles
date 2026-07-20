import 'package:equatable/equatable.dart';

abstract class BookEvent extends Equatable {
  const BookEvent();

  @override
  List<Object> get props => [];
}

class LoadBooks extends BookEvent {
  const LoadBooks();
}

class LoadMoreBooks extends BookEvent {
  final int page;

  const LoadMoreBooks(this.page);

  @override
  List<Object> get props => [page];
}

class LoadBookById extends BookEvent {
  final int id;

  const LoadBookById(this.id);

  @override
  List<Object> get props => [id];
}
