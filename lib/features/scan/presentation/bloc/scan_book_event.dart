import 'package:equatable/equatable.dart';
import 'package:noveles/features/books/domain/book_entity.dart';

abstract class ScanBookEvent extends Equatable {
  const ScanBookEvent();

  @override
  List<Object> get props => [];
}

class LoadScanBooks extends ScanBookEvent {
  const LoadScanBooks();
}

class SaveScanBook extends ScanBookEvent {
  final BookEntity book;
  final bool isUpdate;

  const SaveScanBook(this.book, {required this.isUpdate});

  @override
  List<Object> get props => [book, isUpdate];
}

class DeleteScanBook extends ScanBookEvent {
  final int bookId;

  const DeleteScanBook(this.bookId);

  @override
  List<Object> get props => [bookId];
}

class ToggleScanBookVisibility extends ScanBookEvent {
  final int bookId;
  final bool isVisible;

  const ToggleScanBookVisibility(this.bookId, this.isVisible);

  @override
  List<Object> get props => [bookId, isVisible];
}
