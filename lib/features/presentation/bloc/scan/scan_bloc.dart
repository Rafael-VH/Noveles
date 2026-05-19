import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
import 'package:noveles/features/presentation/bloc/scan/scan_event.dart';
import 'package:noveles/features/presentation/bloc/scan/scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
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

  ScanBloc({
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
  }) : super(ScanInitial()) {
    on<LoadScanBooks>(_onLoadBooks);
    on<LoadScanGenres>(_onLoadGenres);
    on<UploadScanCover>(_onUploadCover);
    on<SaveScanBook>(_onSaveBook);
    on<DeleteScanBook>(_onDeleteBook);
    on<SaveScanTook>(_onSaveTook);
    on<DeleteScanTook>(_onDeleteTook);
    on<SaveScanChapter>(_onSaveChapter);
    on<DeleteScanChapter>(_onDeleteChapter);
  }

  Future<void> _onUploadCover(
    UploadScanCover event,
    Emitter<ScanState> emit,
  ) async {
    try {
      final filename = await uploadCover(event.filePath);
      emit(ScanCoverUploaded(filename));
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }

  Future<void> _onLoadGenres(
    LoadScanGenres event,
    Emitter<ScanState> emit,
  ) async {
    try {
      final genres = await getGenres();
      final currentState = state;
      final books = switch (currentState) {
        ScanLoaded(:final books) => books,
        ScanGenresLoaded(:final books) => books,
        _ => <BookEntity>[],
      };
      emit(ScanGenresLoaded(books, genres));
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }

  Future<void> _onLoadBooks(
    LoadScanBooks event,
    Emitter<ScanState> emit,
  ) async {
    emit(ScanLoading());
    try {
      final books = await getBooks();
      emit(ScanLoaded(books));
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }

  Future<void> _onSaveBook(
    SaveScanBook event,
    Emitter<ScanState> emit,
  ) async {
    emit(ScanLoading());
    try {
      if (event.isUpdate) {
        await updateBook(event.book);
      } else {
        await createBook(event.book);
      }
      final books = await getBooks();
      emit(ScanLoaded(books,
          message: event.isUpdate ? 'Libro guardado' : 'Libro creado'));
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }

  Future<void> _onDeleteBook(
    DeleteScanBook event,
    Emitter<ScanState> emit,
  ) async {
    emit(ScanLoading());
    try {
      await deleteBook(event.bookId);
      final books = await getBooks();
      emit(ScanLoaded(books, message: 'Libro eliminado'));
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }

  Future<void> _onSaveTook(
    SaveScanTook event,
    Emitter<ScanState> emit,
  ) async {
    emit(ScanLoading());
    try {
      if (event.isUpdate) {
        await updateTook(event.took);
      } else {
        await createTook(event.took);
      }
      emit(ScanLoaded(await getBooks(),
          message: event.isUpdate ? 'Tomo guardado' : 'Tomo creado'));
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }

  Future<void> _onDeleteTook(
    DeleteScanTook event,
    Emitter<ScanState> emit,
  ) async {
    emit(ScanLoading());
    try {
      await deleteTook(event.tookId);
      emit(ScanLoaded(await getBooks(), message: 'Tomo eliminado'));
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }

  Future<void> _onSaveChapter(
    SaveScanChapter event,
    Emitter<ScanState> emit,
  ) async {
    emit(ScanLoading());
    try {
      if (event.isUpdate) {
        await updateChapter(event.chapter);
      } else {
        await createChapter(event.chapter);
      }
      emit(ScanLoaded(await getBooks(),
          message: event.isUpdate ? 'Capítulo guardado' : 'Capítulo creado'));
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }

  Future<void> _onDeleteChapter(
    DeleteScanChapter event,
    Emitter<ScanState> emit,
  ) async {
    emit(ScanLoading());
    try {
      await deleteChapter(event.chapterId);
      emit(ScanLoaded(await getBooks(), message: 'Capítulo eliminado'));
    } catch (e) {
      emit(ScanError(e.toString()));
    }
  }
}
