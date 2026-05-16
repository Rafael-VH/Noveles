import 'package:equatable/equatable.dart';

class AuthorEntity extends Equatable {
  final int id;
  final DateTime createdAt;
  final String name;
  final String description;

  AuthorEntity({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.description,
  });

  @override
  List<Object> get props => [id, createdAt, name, description];
}
