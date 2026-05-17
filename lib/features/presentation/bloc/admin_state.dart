import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/entities.dart';

abstract class AdminState extends Equatable {
  @override
  List<Object> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final List<BookEntity> books;
  final String? message;

  AdminLoaded(this.books, {this.message});

  @override
  List<Object> get props => [books, message ?? ''];
}

class AdminCoverUploaded extends AdminState {
  final String filename;

  AdminCoverUploaded(this.filename);

  @override
  List<Object> get props => [filename];
}

class AdminGenresLoaded extends AdminState {
  final List<BookEntity> books;
  final List<GenreEntity> genres;

  AdminGenresLoaded(this.books, this.genres);

  @override
  List<Object> get props => [books, genres];
}

class AdminError extends AdminState {
  final String message;

  AdminError(this.message);

  @override
  List<Object> get props => [message];
}
