import 'package:equatable/equatable.dart';

// Eventos para el AdminBloc, que maneja la gestión de libros en el panel de administración
abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object> get props => [];
}

// Evento para cargar la lista de libros en el panel de administración
class LoadAdminBooks extends AdminEvent {
  const LoadAdminBooks();
}

// Evento para alternar la visibilidad de un libro en el panel de administración
class ToggleBookVisibility extends AdminEvent {
  final int bookId;
  final bool isVisible;

  const ToggleBookVisibility(this.bookId, this.isVisible);

  @override
  List<Object> get props => [bookId, isVisible];
}
