import 'package:noveles/features/domain/repositories/repositories.dart';

class GetBookLabels {
  final BookRepository repository;

  GetBookLabels(this.repository);

  Future<Map<int, Set<int>>> call() => repository.getBookLabels();
}
