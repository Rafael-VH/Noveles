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
}
