import 'package:equatable/equatable.dart';
import 'package:noveles/features/main/domain/entities/entities.dart';

abstract class BookState extends Equatable {
  @override
  List<Object> get props => [];
}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BookLoaded extends BookState {
  final List<BookEntity> books;

  BookLoaded(this.books);

  @override
  List<Object> get props => [books];
}

class BookError extends BookState {
  final String message;

  BookError(this.message);

  @override
  List<Object> get props => [message];
}

class BookDetailLoaded extends BookState {
  final BookEntity book;

  BookDetailLoaded(this.book);

  @override
  List<Object> get props => [book];
}
