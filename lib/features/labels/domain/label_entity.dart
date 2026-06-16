import 'package:equatable/equatable.dart';

class LabelEntity extends Equatable {
  final int id;
  final DateTime createdAt;
  final String name;
  final String color;

  const LabelEntity({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.color,
  });

  LabelEntity copyWith({
    int? id,
    DateTime? createdAt,
    String? name,
    String? color,
  }) {
    return LabelEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  @override
  List<Object> get props => [
        id,
        createdAt,
        name,
        color,
      ];
}
