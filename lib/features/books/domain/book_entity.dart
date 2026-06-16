import 'package:equatable/equatable.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/labels/domain/label_entity.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';

class BookEntity extends Equatable {
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
  final int tookCount;
  final int chapterCount;
  final String source;
  final String link;
  final bool isFavorite;
  final bool isVisible;
  final List<GenreEntity> listGenre;
  final List<TookEntity> listTook;
  final List<LabelEntity> listLabel;
  final String? createdBy;

  const BookEntity({
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
    required this.isFavorite,
    required this.isVisible,
    required this.listGenre,
    required this.listTook,
    required this.listLabel,
    this.createdBy,
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
    int? tookCount,
    int? chapterCount,
    String? source,
    String? link,
    bool? isFavorite,
    bool? isVisible,
    List<GenreEntity>? listGenre,
    List<TookEntity>? listTook,
    List<LabelEntity>? listLabel,
    String? createdBy,
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
      isVisible: isVisible ?? this.isVisible,
      listGenre: listGenre ?? this.listGenre,
      listTook: listTook ?? this.listTook,
      listLabel: listLabel ?? this.listLabel,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        cover,
        name,
        short,
        alternative,
        description,
        authorId,
        author,
        country,
        state,
        type,
        release,
        tookCount,
        chapterCount,
        source,
        link,
        isFavorite,
        isVisible,
        listGenre,
        listTook,
        listLabel,
        createdBy,
      ];
}
