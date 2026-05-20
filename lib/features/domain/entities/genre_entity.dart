import 'package:equatable/equatable.dart';

class GenreEntity extends Equatable {
  final int id;
  final DateTime createdAt;
  final String name;
  final String description;

  const GenreEntity({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.description,
  });

  @override
  List<Object> get props => [
        id,
        createdAt,
        name,
        description,
      ];
}
