import 'package:noveles/features/domain/entities/entities.dart';

class BookEntity {
  final int id;
  final DateTime createdAt;
  final String cover;
  final String name;
  final String short;
  final String alternative;
  final String description;
  final int authorId;
  final String author;
  final String country;
  final String state;
  final String type;
  final String release;
  final String tookCount;
  final String chapterCount;
  final String source;
  final String link;
  late bool isFavorite;
  final List<GenreEntity> listGenre;
  final List<TookEntity> listTook;

  BookEntity({
    required this.id,
    required this.createdAt,
    required this.cover,
    required this.name,
    required this.short,
    required this.alternative,
    required this.description,
    required this.authorId,
    required this.author,
    required this.country,
    required this.state,
    required this.type,
    required this.release,
    required this.tookCount,
    required this.chapterCount,
    required this.source,
    required this.link,
    this.isFavorite = false,
    required this.listGenre,
    required this.listTook,
  });

  BookEntity copyWith({
    int? id,
    DateTime? createdAt,
    String? cover,
    String? name,
    String? short,
    String? alternative,
    String? description,
    int? authorId,
    String? author,
    String? country,
    String? state,
    String? type,
    String? release,
    String? tookCount,
    String? chapterCount,
    String? source,
    String? link,
    bool? isFavorite,
    List<GenreEntity>? listGenre,
    List<TookEntity>? listTook,
  }) {
    return BookEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      cover: cover ?? this.cover,
      name: name ?? this.name,
      short: short ?? this.short,
      alternative: alternative ?? this.alternative,
      description: description ?? this.description,
      authorId: authorId ?? this.authorId,
      author: author ?? this.author,
      country: country ?? this.country,
      state: state ?? this.state,
      type: type ?? this.type,
      release: release ?? this.release,
      tookCount: tookCount ?? this.tookCount,
      chapterCount: chapterCount ?? this.chapterCount,
      source: source ?? this.source,
      link: link ?? this.link,
      isFavorite: isFavorite ?? this.isFavorite,
      listGenre: listGenre ?? this.listGenre,
      listTook: listTook ?? this.listTook,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'cover': cover,
      'name': name,
      'short': short,
      'alternative': alternative,
      'description': description,
      'author_id': authorId,
      'country': country,
      'state': state,
      'type': type,
      'release': release,
      'took_count': tookCount,
      'chapter_count': chapterCount,
      'source': source,
      'link': link,
      'is_favorite': isFavorite,
      'listGenre': listGenre.map((genre) => genre.toMap()).toList(),
      'listTook': listTook.map((took) => took.toMap()).toList(),
    };
  }

  factory BookEntity.fromMap(Map<String, dynamic> map) {
    return BookEntity(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      cover: map['cover'] ?? '',
      name: map['name'] ?? '',
      short: map['short'] ?? '',
      alternative: map['alternative'] ?? '',
      description: map['description'] ?? '',
      authorId: map['author_id'] ?? 0,
      author: map['author'] ?? '',
      country: map['country'] ?? '',
      state: map['state'] ?? '',
      type: map['type'] ?? '',
      release: map['release'] ?? '',
      tookCount: map['took_count'] ?? '',
      chapterCount: map['chapter_count'] ?? '',
      source: map['source'] ?? '',
      link: map['link'] ?? '',
      isFavorite: map['is_favorite'] ?? false,
      listGenre: List<GenreEntity>.from(
        map['listGenre'].map((item) => GenreEntity.fromMap(item)),
      ),
      listTook: List<TookEntity>.from(
        map['listTook'].map((item) => TookEntity.fromMap(item)),
      ),
    );
  }
}
