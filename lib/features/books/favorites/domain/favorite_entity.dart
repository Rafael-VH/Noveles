import 'package:equatable/equatable.dart';

class FavoriteEntity extends Equatable {
  final String userId;
  final int bookId;
  final DateTime createdAt;

  const FavoriteEntity({
    required this.userId,
    required this.bookId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [userId, bookId, createdAt];
}
