import 'package:equatable/equatable.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

abstract class ScanBookState extends Equatable {
  @override
  List<Object> get props => [];
}

class ScanBookInitial extends ScanBookState {}

class ScanBookLoading extends ScanBookState {}

class ScanBookLoaded extends ScanBookState {
  final List<BookWithRelations> books;
  final String? message;

  ScanBookLoaded(this.books, {this.message});

  @override
  List<Object> get props => [books, message ?? ''];
}

class ScanBookError extends ScanBookState {
  final String message;

  ScanBookError(this.message);

  @override
  List<Object> get props => [message];
}
