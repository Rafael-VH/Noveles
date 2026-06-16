import 'package:equatable/equatable.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';

// This file defines the states for the ScanBloc, which manages the state of the book scanning feature in the application.
// Each state represents a specific condition of the UI, such as loading, loaded with data, or error states. The states are
// designed to allow the UI to react accordingly based on the current state of the ScanBloc, ensuring a responsive and dynamic
// user experience as users interact with the book scanning features. The states also include relevant data, such as lists of
// books and genres, to provide the necessary information for the UI to display the latest data from the backend and reflect
// user actions effectively.
abstract class ScanState extends Equatable {
  @override
  List<Object> get props => [];
}

// This state represents the initial state of the ScanBloc, indicating that no data has been loaded or operations have been
// performed yet. It allows the UI to display an initial view or prompt the user to take action, providing a starting point
// for the user experience as they interact with the book scanning features.
class ScanInitial extends ScanState {}

// This state represents the loading state of the ScanBloc, indicating that data is being fetched or an operation is in progress.
// It allows the UI to display a loading indicator or similar feedback to the user while waiting for the operation to complete,
// enhancing the user experience by providing visual cues about the ongoing process.
class ScanLoading extends ScanState {}

// This state represents the loaded state with a list of books, allowing the UI to display the latest data from the backend after
// loading books. It contains a list of books and an optional message, enabling the UI to show the relevant information and feedback
// for the user based on the current data, ensuring a dynamic and responsive user experience as users interact with the book scanning features.
class ScanLoaded extends ScanState {
  final List<BookEntity> books;
  final String? message;

  ScanLoaded(this.books, {this.message});

  @override
  List<Object> get props => [books, message ?? ''];
}

// This state represents the successful upload of a cover image, containing the filename of the uploaded cover. It allows the UI
// to update the displayed cover image with the new one after a successful upload, providing immediate feedback to the user and
// enhancing the user experience by reflecting the changes without delay.
class ScanCoverUploaded extends ScanState {
  final String filename;

  ScanCoverUploaded(this.filename);

  @override
  List<Object> get props => [filename];
}

// This state represents the loaded state with both books and genres, allowing the UI to display the latest data from the backend
// after loading genres. It contains a list of books and a list of genres, enabling the UI to show the relevant information and
// options for the user based on the current data, ensuring a dynamic and responsive user experience as users interact with the
// book scanning features.
class ScanGenresLoaded extends ScanState {
  final List<BookEntity> books;
  final List<GenreEntity> genres;

  ScanGenresLoaded(this.books, this.genres);

  @override
  List<Object> get props => [books, genres];
}

// This state represents an error condition in the ScanBloc, containing a message that describes the error. It allows the UI
// to display appropriate feedback to the user when an error occurs during operations such as loading books, uploading covers,
// or saving data, ensuring a better user experience by providing clear information about what went wrong.
class ScanError extends ScanState {
  final String message;

  ScanError(this.message);

  @override
  List<Object> get props => [message];
}
