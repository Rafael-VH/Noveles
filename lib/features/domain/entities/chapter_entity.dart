class ChapterEntity {
  final int id;
  final DateTime createdAt;
  final String number;
  final String title;
  final String content;
  final int tookId;

  ChapterEntity({
    required this.id,
    required this.createdAt,
    required this.number,
    required this.title,
    required this.content,
    required this.tookId,
  });

  ChapterEntity copyWith({
    int? id,
    DateTime? createdAt,
    String? number,
    String? title,
    String? content,
    int? tookId,
  }) {
    return ChapterEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      number: number ?? this.number,
      title: title ?? this.title,
      content: content ?? this.content,
      tookId: tookId ?? this.tookId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'number': number,
      'title': title,
      'content': content,
      'took_id': tookId,
    };
  }

  factory ChapterEntity.fromMap(Map<String, dynamic> map) {
    return ChapterEntity(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      number: map['number'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      tookId: map['took_id'] ?? 0,
    );
  }
}
