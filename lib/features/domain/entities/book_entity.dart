import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/genre_entity.dart';
import 'package:noveles/features/domain/entities/took_entity.dart';

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
  final String tookCount;
  final String chapterCount;
  final String source;
  final String link;
  final bool isFavorite;
  final List<GenreEntity> listGenre;
  final List<TookEntity> listTook;

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
    required this.listGenre,
    required this.listTook,
  });

  @override
  List<Object> get props => [
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
        listGenre,
        listTook,
      ];
}
