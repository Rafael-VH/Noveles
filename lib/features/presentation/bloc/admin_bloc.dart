import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
import 'package:noveles/features/presentation/bloc/admin_event.dart';
import 'package:noveles/features/presentation/bloc/admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetBooks getBooks;
  final CreateBook createBook;
  final UpdateBook updateBook;
  final DeleteBook deleteBook;
  final CreateTook createTook;
  final UpdateTook updateTook;
  final DeleteTook deleteTook;
  final CreateChapter createChapter;
  final UpdateChapter updateChapter;
  final DeleteChapter deleteChapter;
  final GetGenre getGenres;
  final UploadCover uploadCover;

  AdminBloc({
    required this.getBooks,
    required this.createBook,
    required this.updateBook,
    required this.deleteBook,
    required this.createTook,
    required this.updateTook,
    required this.deleteTook,
    required this.createChapter,
    required this.updateChapter,
    required this.deleteChapter,
    required this.getGenres,
    required this.uploadCover,
  }) : super(AdminInitial()) {
    on<LoadAdminBooks>(_onLoadBooks);
    on<LoadAdminGenres>(_onLoadGenres);
    on<UploadAdminCover>(_onUploadCover);
    on<SaveAdminBook>(_onSaveBook);
    on<DeleteAdminBook>(_onDeleteBook);
    on<SaveAdminTook>(_onSaveTook);
    on<DeleteAdminTook>(_onDeleteTook);
    on<SaveAdminChapter>(_onSaveChapter);
    on<DeleteAdminChapter>(_onDeleteChapter);
  }

  Future<void> _onUploadCover(
    UploadAdminCover event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final filename = await uploadCover(event.filePath);
      emit(AdminCoverUploaded(filename));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onLoadGenres(
    LoadAdminGenres event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final genres = await getGenres();
      final currentState = state;
      final books =
          currentState is AdminLoaded ? currentState.books : <BookEntity>[];
      emit(AdminGenresLoaded(books, genres));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onLoadBooks(
    LoadAdminBooks event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final books = await getBooks();
      emit(AdminLoaded(books));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onSaveBook(
    SaveAdminBook event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      if (event.isUpdate) {
        await updateBook(event.book);
      } else {
        await createBook(event.book);
      }
      final books = await getBooks();
      emit(AdminLoaded(books,
          message: event.isUpdate ? 'Libro guardado' : 'Libro creado'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onDeleteBook(
    DeleteAdminBook event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      await deleteBook(event.bookId);
      final books = await getBooks();
      emit(AdminLoaded(books, message: 'Libro eliminado'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onSaveTook(
    SaveAdminTook event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      if (event.isUpdate) {
        await updateTook(event.took);
      } else {
        await createTook(event.took);
      }
      emit(AdminLoaded(await getBooks(),
          message: event.isUpdate ? 'Tomo guardado' : 'Tomo creado'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onDeleteTook(
    DeleteAdminTook event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      await deleteTook(event.tookId);
      emit(AdminLoaded(await getBooks(), message: 'Tomo eliminado'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onSaveChapter(
    SaveAdminChapter event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      if (event.isUpdate) {
        await updateChapter(event.chapter);
      } else {
        await createChapter(event.chapter);
      }
      emit(AdminLoaded(await getBooks(),
          message: event.isUpdate ? 'Capítulo guardado' : 'Capítulo creado'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onDeleteChapter(
    DeleteAdminChapter event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      await deleteChapter(event.chapterId);
      emit(AdminLoaded(await getBooks(), message: 'Capítulo eliminado'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}
