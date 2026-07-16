import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/labels/domain/label_entity.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';

/// Book entity with fully hydrated relation objects.
/// Used when Supabase returns joined data (genres, labels, tooks).
/// This is the type the UI works with for rendering.
class BookWithRelations extends BookEntity {
  final List<GenreEntity> listGenre;
  final List<TookEntity> listTook;
  final List<LabelEntity> listLabel;

  const BookWithRelations({
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
    this.listGenre = const [],
    this.listTook = const [],
    this.listLabel = const [],
  });

  @override
  BookWithRelations copyWith({
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
    int? tookCount,
    int? chapterCount,
    String? source,
    String? link,
    bool? isFavorite,
    bool? isVisible,
    List<int>? listGenreIds,
    List<int>? listTookIds,
    List<int>? listLabelIds,
    String? createdBy,
    List<GenreEntity>? listGenre,
    List<TookEntity>? listTook,
    List<LabelEntity>? listLabel,
  }) {
    return BookWithRelations(
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
      isVisible: isVisible ?? this.isVisible,
      listGenreIds: listGenreIds ?? this.listGenreIds,
      listTookIds: listTookIds ?? this.listTookIds,
      listLabelIds: listLabelIds ?? this.listLabelIds,
      createdBy: createdBy ?? this.createdBy,
      listGenre: listGenre ?? this.listGenre,
      listTook: listTook ?? this.listTook,
      listLabel: listLabel ?? this.listLabel,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        listGenre,
        listTook,
        listLabel,
      ];
}
