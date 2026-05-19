class RepositoryException implements Exception {
  final String message;
  final Object? originalException;
  final String? repositoryName;

  const RepositoryException({
    required this.message,
    this.originalException,
    this.repositoryName,
  });

  @override
  String toString() {
    final prefix = repositoryName != null ? '[$repositoryName] ' : '';
    final original = originalException != null ? ' (cause: $originalException)' : '';
    return '${prefix}Error: $message$original';
  }
}
