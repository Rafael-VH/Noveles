import 'package:noveles/features/data/local/models/genre_local_model.dart';
import 'package:noveles/features/data/local/models/took_local_model.dart';

class BookLocalModel {
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
  final List<GenreLocalModel> listGenre;
  final List<TookLocalModel> listTook;

  BookLocalModel({
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

  BookLocalModel copyWith({
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
    List<GenreLocalModel>? listGenre,
    List<TookLocalModel>? listTook,
  }) {
    return BookLocalModel(
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
      'createdAt': createdAt,
      'cover': cover,
      'name': name,
      'short': short,
      'alternative': alternative,
      'description': description,
      'authorId': authorId,
      'author': author,
      'country': country,
      'state': state,
      'type': type,
      'release': release,
      'tookCount': tookCount,
      'chapterCount': chapterCount,
      'source': source,
      'link': link,
      'isFavorite': isFavorite,
      'listGenre': listGenre.toList(),
      'listTook': listTook.toList(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'cover': cover,
      'name': name,
      'short': short,
      'alternative': alternative,
      'description': description,
      'authorId': authorId,
      'author': author,
      'country': country,
      'state': state,
      'type': type,
      'release': release,
      'tookCount': tookCount,
      'chapterCount': chapterCount,
      'source': source,
      'link': link,
      'isFavorite': isFavorite,
      'listGenre': listGenre.toList(),
      'listTook': listTook.toList(),
    };
  }

  factory BookLocalModel.fromJson(Map<String, dynamic> json) {
    return BookLocalModel(
      id: json['id'],
      createdAt: json['createdAt'],
      cover: json['cover'],
      name: json['name'],
      short: json['short'],
      alternative: json['alternative'],
      description: json['description'],
      authorId: json['authorId'] ?? 0,
      author: json['author'],
      country: json['country'],
      state: json['state'],
      type: json['type'],
      release: json['release'],
      tookCount: json['tookCount'],
      chapterCount: json['chapterCount'],
      source: json['source'],
      link: json['link'],
      isFavorite: json['isFavorite'] ?? false,
      listGenre: (json['listGenre'] as List<dynamic>?)
              ?.map((e) => GenreLocalModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      listTook: (json['listTook'] as List<dynamic>?)
              ?.map((e) => TookLocalModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }
}
