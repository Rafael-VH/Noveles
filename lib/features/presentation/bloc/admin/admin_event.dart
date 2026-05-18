import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object> get props => [];
}

class LoadAdminBooks extends AdminEvent {
  const LoadAdminBooks();
}

class ToggleBookVisibility extends AdminEvent {
  final int bookId;
  final bool isVisible;

  const ToggleBookVisibility(this.bookId, this.isVisible);

  @override
  List<Object> get props => [bookId, isVisible];
}
