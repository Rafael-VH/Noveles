class ChapterLocalModel {
  final int id;
  final DateTime createdAt;
  final String number;
  final String title;
  final String content;
  final int tookId;

  ChapterLocalModel({
    required this.id,
    required this.createdAt,
    required this.number,
    required this.title,
    required this.content,
    required this.tookId,
  });

  ChapterLocalModel copyWith({
    int? id,
    DateTime? createdAt,
    String? number,
    String? title,
    String? content,
    int? tookId,
  }) {
    return ChapterLocalModel(
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
      'createdAt': createdAt,
      'number': number,
      'title': title,
      'content': content,
      'tookId': tookId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'number': number,
      'title': title,
      'content': content,
      'tookId': tookId,
    };
  }

  factory ChapterLocalModel.fromJson(Map<String, dynamic> json) {
    return ChapterLocalModel(
      id: json['id'],
      createdAt: json['createdAt'],
      number: json['number'],
      title: json['title'],
      content: json['content'],
      tookId: json['tookId'] ?? 0,
    );
  }
}
