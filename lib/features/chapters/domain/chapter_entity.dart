import 'package:equatable/equatable.dart';

class ChapterEntity extends Equatable {
  final int id;
  final DateTime createdAt;
  final String number;
  final String title;
  final String content;
  final int tookId;
  final String? createdBy;

  const ChapterEntity({
    required this.id,
    required this.createdAt,
    required this.number,
    required this.title,
    required this.content,
    required this.tookId,
    this.createdBy,
  });

  @override
  List<Object?> get props => [
        id,
        createdAt,
        number,
        title,
        content,
        tookId,
        createdBy,
      ];
}
