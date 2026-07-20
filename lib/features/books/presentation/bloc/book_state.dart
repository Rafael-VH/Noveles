import 'package:equatable/equatable.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

abstract class BookState extends Equatable {
  @override
  List<Object> get props => [];
}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BookLoaded extends BookState {
  final List<BookWithRelations> books;
  final bool hasMore;

  BookLoaded(this.books, {this.hasMore = true});

  @override
  List<Object> get props => [books, hasMore];
}

class BookError extends BookState {
  final String message;

  BookError(this.message);

  @override
  List<Object> get props => [message];
}

class BookDetailLoaded extends BookState {
  final BookWithRelations book;

  BookDetailLoaded(this.book);

  @override
  List<Object> get props => [book];
}
