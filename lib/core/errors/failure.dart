sealed class Failure {
  final String message;
  final Object? cause;

  const Failure(this.message, {this.cause});

  @override
  String toString() => 'Failure: $message${cause != null ? ' (cause: $cause)' : ''}';
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.cause});
}

class BookFailure extends Failure {
  const BookFailure(super.message, {super.cause});
}

class ChapterFailure extends Failure {
  const ChapterFailure(super.message, {super.cause});
}

class TookFailure extends Failure {
  const TookFailure(super.message, {super.cause});
}

class GenreFailure extends Failure {
  const GenreFailure(super.message, {super.cause});
}

class LabelFailure extends Failure {
  const LabelFailure(super.message, {super.cause});
}

class ProfileFailure extends Failure {
  const ProfileFailure(super.message, {super.cause});
}

class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.cause});
}

class FavoriteFailure extends Failure {
  const FavoriteFailure(super.message, {super.cause});
}

class AnalyticsFailure extends Failure {
  const AnalyticsFailure(super.message, {super.cause});
}
