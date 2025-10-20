class ChapterEntity {
  final int id;
  final DateTime createdAt;
  final String number;
  final String title;
  final String content;

  ChapterEntity({
    required this.id,
    required this.createdAt,
    required this.number,
    required this.title,
    required this.content,
  });

  ChapterEntity copyWith({
    int? id,
    DateTime? createdAt,
    String? number,
    String? title,
    String? content,
  }) {
    return ChapterEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      number: number ?? this.number,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
      'number': number,
      'title': title,
      'content': content,
    };
  }

  factory ChapterEntity.fromMap(Map<String, dynamic> map) {
    return ChapterEntity(
      id: map['id'],
      createdAt: DateTime.parse(map['createdAt']),
      number: map['number'],
      title: map['title'],
      content: map['content'],
    );
  }
}