import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/entities.dart';

abstract class ScanState extends Equatable {
  @override
  List<Object> get props => [];
}

class ScanInitial extends ScanState {}

class ScanLoading extends ScanState {}

class ScanLoaded extends ScanState {
  final List<BookEntity> books;
  final String? message;

  ScanLoaded(this.books, {this.message});

  @override
  List<Object> get props => [books, message ?? ''];
}

class ScanCoverUploaded extends ScanState {
  final String filename;

  ScanCoverUploaded(this.filename);

  @override
  List<Object> get props => [filename];
}

class ScanGenresLoaded extends ScanState {
  final List<BookEntity> books;
  final List<GenreEntity> genres;

  ScanGenresLoaded(this.books, this.genres);

  @override
  List<Object> get props => [books, genres];
}

class ScanError extends ScanState {
  final String message;

  ScanError(this.message);

  @override
  List<Object> get props => [message];
}
