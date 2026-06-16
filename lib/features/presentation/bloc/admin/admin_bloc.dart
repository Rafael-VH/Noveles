import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/presentation/notification_service.dart';
import 'package:noveles/features/books/domain/delete_book.dart';
import 'package:noveles/features/books/domain/get_book.dart';
import 'package:noveles/features/books/domain/toggle_book_visibility.dart'
    as usecases;
import 'package:noveles/features/presentation/bloc/admin/admin_event.dart';
import 'package:noveles/features/presentation/bloc/admin/admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetBooks getBooks;
  final usecases.ToggleBookVisibility toggleBookVisibility;
  final DeleteBook deleteBook;

  AdminBloc({
    required this.getBooks,
    required this.toggleBookVisibility,
    required this.deleteBook,
  }) : super(const AdminInitial()) {
    on<LoadAdminBooks>(_onLoadBooks);
    on<ToggleBookVisibility>(_onToggleVisibility);
    on<DeleteAdminBook>(_onDeleteBook);
  }

  Future<void> _onLoadBooks(
    LoadAdminBooks event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    final result = await getBooks();
    switch (result) {
      case Ok(:final value):
        emit(AdminLoaded(value));
      case Err(:final error):
        emit(AdminError(error.message));
        NotificationService.error('Error al cargar libros: ${error.message}');
    }
  }

  Future<void> _onToggleVisibility(
    ToggleBookVisibility event,
    Emitter<AdminState> emit,
  ) async {
    final toggleResult =
        await toggleBookVisibility(event.bookId, event.isVisible);
    switch (toggleResult) {
      case Ok():
        final booksResult = await getBooks();
        switch (booksResult) {
          case Ok(:final value):
            emit(AdminLoaded(
              value,
              message: event.isVisible ? 'Libro publicado' : 'Libro ocultado',
            ));
          case Err(:final error):
            NotificationService.error(
                'Error al actualizar la lista: ${error.message}');
        }
      case Err(:final error):
        emit(AdminError(error.message));
        NotificationService.error(
            'Error al cambiar visibilidad: ${error.message}');
    }
  }

  Future<void> _onDeleteBook(
    DeleteAdminBook event,
    Emitter<AdminState> emit,
  ) async {
    final deleteResult = await deleteBook(event.bookId);
    switch (deleteResult) {
      case Ok():
        final booksResult = await getBooks();
        switch (booksResult) {
          case Ok(:final value):
            emit(AdminLoaded(
              value,
              message: 'Libro eliminado',
            ));
          case Err(:final error):
            NotificationService.error(
                'Error al actualizar la lista: ${error.message}');
        }
      case Err(:final error):
        emit(AdminError(error.message));
        NotificationService.error('Error al eliminar el libro: ${error.message}');
    }
  }
}
