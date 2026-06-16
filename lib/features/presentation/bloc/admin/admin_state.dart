import 'package:equatable/equatable.dart';
import 'package:noveles/features/books/domain/book_entity.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminLoaded extends AdminState {
  final List<BookEntity> books;
  final String? message;

  const AdminLoaded(this.books, {this.message});

  @override
  List<Object> get props => [books, message ?? ''];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object> get props => [message];
}
