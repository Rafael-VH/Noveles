import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/use_cases/get_book.dart';
import 'package:noveles/features/domain/use_cases/toggle_book_visibility.dart' as usecases;
import 'package:noveles/features/presentation/bloc/admin/admin_event.dart';
import 'package:noveles/features/presentation/bloc/admin/admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetBooks getBooks;
  final usecases.ToggleBookVisibility toggleBookVisibility;

  AdminBloc({
    required this.getBooks,
    required this.toggleBookVisibility,
  }) : super(const AdminInitial()) {
    on<LoadAdminBooks>(_onLoadBooks);
    on<ToggleBookVisibility>(_onToggleVisibility);
  }

  Future<void> _onLoadBooks(
    LoadAdminBooks event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final books = await getBooks();
      emit(AdminLoaded(books));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onToggleVisibility(
    ToggleBookVisibility event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await toggleBookVisibility(event.bookId, event.isVisible);
      final books = await getBooks();
      emit(AdminLoaded(
        books,
        message: event.isVisible ? 'Libro publicado' : 'Libro ocultado',
      ));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}
