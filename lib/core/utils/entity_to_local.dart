import 'package:noveles/features/data/local/models/model.dart';
import 'package:noveles/features/domain/entities/entities.dart';

extension BookEntityToLocal on BookEntity {
  BookLocalModel toLocalModel() => BookLocalModel(
        id: id,
        createdAt: createdAt,
        cover: cover,
        name: name,
        short: short,
        alternative: alternative,
        description: description,
        author: author,
        country: country,
        state: state,
        type: type,
        release: release,
        took: took,
        chapter: chapter,
        source: source,
        link: link,
        isFavorite: isFavorite,
        listGenre: listGenre.map((g) => g.toLocalModel()).toList(),
        listTook: listTook.map((t) => t.toLocalModel()).toList(),
      );
}

extension GenreEntityToLocal on GenreEntity {
  GenreLocalModel toLocalModel() => GenreLocalModel(
        id: id,
        createdAt: createdAt,
        name: name,
        description: description,
      );
}

extension TookEntityToLocal on TookEntity {
  TookLocalModel toLocalModel() => TookLocalModel(
        id: id,
        createdAt: createdAt,
        cover: cover,
        number: number,
        title: title,
        content: content,
        listChapter: listChapter.map((c) => c.toLocalModel()).toList(),
      );
}

extension ChapterEntityToLocal on ChapterEntity {
  ChapterLocalModel toLocalModel() => ChapterLocalModel(
        id: id,
        createdAt: createdAt,
        number: number,
        title: title,
        content: content,
      );
}
