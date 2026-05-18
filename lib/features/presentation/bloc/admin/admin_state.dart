import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/entities.dart';

// Estados para el AdminBloc, que maneja la gestión de libros en el panel de administración
abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object> get props => [];
}

// Estado inicial del AdminBloc, antes de cargar cualquier dato
class AdminInitial extends AdminState {
  const AdminInitial();
}

// Estado para indicar que se están cargando los libros en el panel de administración
class AdminLoading extends AdminState {
  const AdminLoading();
}

// Estado para manejar la lista de libros cargados en el panel de administración, con un mensaje opcional para indicar el resultado de una acción (como publicar u ocultar un libro)
class AdminLoaded extends AdminState {
  final List<BookEntity> books;
  final String? message;

  const AdminLoaded(this.books, {this.message});

  @override
  List<Object> get props => [books, message ?? ''];
}

// Estado para manejar errores en el AdminBloc, con un mensaje de error específico
class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object> get props => [message];
}
