import 'package:noveles/features/main/data/local/models/model.dart';

class BookLocalModel {
  final int id;
  final DateTime createdAt;
  final String cover;
  final String name;
  final String short;
  final String alternative;
  final String description;
  final String author;
  final String country;
  final String state;
  final String type;
  final String release;
  final String took;
  final String chapter;
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
    required this.author,
    required this.country,
    required this.state,
    required this.type,
    required this.release,
    required this.took,
    required this.chapter,
    required this.source,
    required this.link,
    this.isFavorite = false,
    required this.listGenre,
    required this.listTook,
  });

  //  Se utiliza para actualizar los datos de la 'Novela' sin modificar la instancia original.
  BookLocalModel copyWith({
    int? id,
    DateTime? createdAt,
    String? cover,
    String? name,
    String? short,
    String? alternative,
    String? description,
    String? author,
    String? country,
    String? state,
    String? type,
    String? release,
    String? took,
    String? chapter,
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
      author: author ?? this.author,
      country: country ?? this.country,
      state: state ?? this.state,
      type: type ?? this.type,
      release: release ?? this.release,
      took: took ?? this.took,
      chapter: chapter ?? this.chapter,
      source: source ?? this.source,
      link: link ?? this.link,
      isFavorite: isFavorite ?? this.isFavorite,
      listGenre: listGenre ?? this.listGenre,
      listTook: listTook ?? this.listTook,
    );
  }

  //  Devuelve un mapa de las propiedades de la 'Novela'.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
      'cover': cover,
      'name': name,
      'short': short,
      'alternative': alternative,
      'description': description,
      'author': author,
      'country': country,
      'state': state,
      'type': type,
      'release': release,
      'took': took,
      'chapter': chapter,
      'source': source,
      'link': link,
      'isFavorite': isFavorite,
      'listGenre': listGenre.toList(),
      'listTook': listTook.toList(),
    };
  }

  //  Devuelve un mapa de las propiedades de la 'Novela' en formato JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'cover': cover,
      'name': name,
      'short': short,
      'alternative': alternative,
      'description': description,
      'author': author,
      'country': country,
      'state': state,
      'type': type,
      'release': release,
      'took': took,
      'chapter': chapter,
      'source': source,
      'link': link,
      'isFavorite': isFavorite,
      'listGenre': listGenre.toList(),
      'listTook': listTook.toList(),
    };
  }

  //  Convierte un mapa JSON en una instancia de NovelModel.
  factory BookLocalModel.fromJson(Map<String, dynamic> json) {
    return BookLocalModel(
      id: json['id'],
      createdAt: json['createdAt'],
      cover: json['cover'],
      name: json['name'],
      short: json['short'],
      alternative: json['alternative'],
      description: json['description'],
      author: json['author'],
      country: json['country'],
      state: json['state'],
      type: json['type'],
      release: json['release'],
      took: json['took'],
      chapter: json['chapter'],
      source: json['source'],
      link: json['link'],
      isFavorite: json['isFavorite'],
      listGenre: json['listGenre'],
      listTook: json['listTook'],
    );
  }
}
