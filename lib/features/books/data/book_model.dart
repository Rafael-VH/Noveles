import 'package:noveles/core/utils/parse_utils.dart';
import 'package:noveles/features/genres/data/genre_model.dart';
import 'package:noveles/features/labels/data/label_model.dart';
import 'package:noveles/features/tooks/data/took_model.dart';
import 'package:noveles/features/books/domain/book_with_relations.dart';

/// Book data model from Supabase — always has joined relation data.
class BookModel extends BookWithRelations {
  const BookModel({
    required super.id,
    required super.createdAt,
    required super.cover,
    required super.name,
    required super.short,
    required super.alternative,
    required super.description,
    required super.authorId,
    required super.author,
    required super.country,
    required super.state,
    required super.type,
    required super.release,
    required super.tookCount,
    required super.chapterCount,
    required super.source,
    required super.link,
    required super.isFavorite,
    required super.isVisible,
    super.listGenreIds = const [],
    super.listTookIds = const [],
    super.listLabelIds = const [],
    super.createdBy,
    required super.listGenre,
    required super.listTook,
    required super.listLabel,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final authorData =
        Map<String, dynamic>.from(json['authors'] ?? <String, dynamic>{});

    final listGenre =
        ((json['books_genres'] as List<dynamic>?) ?? []).map((bg) {
      return GenreModel.fromJson(Map<String, dynamic>.from(bg['genres']));
    }).toList();

    final listLabel =
        ((json['books_labels'] as List<dynamic>?) ?? []).map((bl) {
      return LabelModel.fromJson(Map<String, dynamic>.from(bl['labels']));
    }).toList();

    final listTook = ((json['tooks'] as List<dynamic>?) ?? []).map((t) {
      return TookModel.fromJson(Map<String, dynamic>.from(t));
    }).toList();

    return BookModel(
      id: parseInt(json['id']),
      createdAt: DateTime.parse(json['created_at'] as String),
      cover: (json['cover'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      short: (json['short'] as String?) ?? '',
      alternative: (json['alternative'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      authorId: parseInt(json['author_id'], 0),
      author: (authorData['name'] as String?) ?? '',
      country: (json['country'] as String?) ?? '',
      state: (json['state'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      release: (json['release'] as String?) ?? '',
      tookCount: parseInt(json['took_count'], 0),
      chapterCount: parseInt(json['chapter_count'], 0),
      source: (json['source'] as String?) ?? '',
      link: (json['link'] as String?) ?? '',
      isFavorite: (json['is_favorite'] as bool?) ?? false,
      isVisible: (json['is_visible'] as bool?) ?? true,
      createdBy: json['created_by'] as String?,
      listGenreIds: listGenre.map((g) => g.id).toList(),
      listTookIds: listTook.map((t) => t.id).toList(),
      listLabelIds: listLabel.map((l) => l.id).toList(),
      listGenre: listGenre,
      listTook: listTook,
      listLabel: listLabel,
    );
  }

  Map<String, dynamic> toJson() => {
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
        'is_visible': isVisible,
        'created_by': createdBy,
      };

  factory BookModel.fromBookWithRelations(BookWithRelations entity) =>
      BookModel(
        id: entity.id,
        createdAt: entity.createdAt,
        cover: entity.cover,
        name: entity.name,
        short: entity.short,
        alternative: entity.alternative,
        description: entity.description,
        authorId: entity.authorId,
        author: entity.author,
        country: entity.country,
        state: entity.state,
        type: entity.type,
        release: entity.release,
        tookCount: entity.tookCount,
        chapterCount: entity.chapterCount,
        source: entity.source,
        link: entity.link,
        isFavorite: entity.isFavorite,
        isVisible: entity.isVisible,
        listGenreIds: entity.listGenreIds,
        listTookIds: entity.listTookIds,
        listLabelIds: entity.listLabelIds,
        listGenre: entity.listGenre,
        listTook: entity.listTook,
        listLabel: entity.listLabel,
        createdBy: entity.createdBy,
      );
}
