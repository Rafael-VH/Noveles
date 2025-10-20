import 'package:noveles/features/data/local/data_sources/data_source.dart';
import 'package:noveles/features/data/local/models/model.dart';
import 'package:noveles/features/data/local/string/string.dart';

class BookLocalDataSourceCH {
  static BookLocalModel swallowedStar = BookLocalModel(
    id: 0,
    createdAt: DateTime(2024, 04, 21),
    cover: SwallowedStarCH.cover,
    name: SwallowedStarCH.name,
    short: SwallowedStarCH.short,
    alternative: SwallowedStarCH.alternative,
    description: SwallowedStarCH.description,
    author: SwallowedStarCH.author,
    country: SwallowedStarCH.country,
    state: SwallowedStarCH.state,
    type: SwallowedStarCH.type,
    release: SwallowedStarCH.release,
    took: SwallowedStarCH.took,
    chapter: SwallowedStarCH.chapter,
    source: SwallowedStarCH.source,
    link: SwallowedStarCH.link,
    listGenre: GenreLocalDataSourceCH.swallowedStar,
    listTook: TooksSwallowedStar.listTooksSS,
  );

  static BookLocalModel douluoDalu1 = BookLocalModel(
    id: 8,
    createdAt: DateTime(2024, 04, 21),
    cover: DouluoDalu1CH.cover,
    name: DouluoDalu1CH.name,
    short: DouluoDalu1CH.short,
    alternative: DouluoDalu1CH.alternative,
    description: DouluoDalu1CH.description,
    author: DouluoDalu1CH.author,
    country: DouluoDalu1CH.country,
    state: DouluoDalu1CH.state,
    type: DouluoDalu1CH.type,
    release: DouluoDalu1CH.release,
    took: DouluoDalu1CH.took,
    chapter: DouluoDalu1CH.chapter,
    source: DouluoDalu1CH.source,
    link: DouluoDalu1CH.link,
    listGenre: GenreLocalDataSourceCH.douluoDalu1,
    listTook: TooksDouluoDalu1.listTooksDD1,
  );

  static BookLocalModel douluoDalu2 = BookLocalModel(
    id: 11,
    createdAt: DateTime(2024, 04, 21),
    cover: DouluoDalu2CH.cover,
    name: DouluoDalu2CH.name,
    short: DouluoDalu2CH.short,
    alternative: DouluoDalu2CH.alternative,
    description: DouluoDalu2CH.description,
    author: DouluoDalu2CH.author,
    country: DouluoDalu2CH.country,
    state: DouluoDalu2CH.state,
    type: DouluoDalu2CH.type,
    release: DouluoDalu2CH.release,
    took: DouluoDalu2CH.took,
    chapter: DouluoDalu2CH.chapter,
    source: DouluoDalu2CH.source,
    link: DouluoDalu2CH.link,
    listGenre: GenreLocalDataSourceCH.douluoDalu2,
    listTook: TooksDouluoDalu2.listTooksDD2,
  );
}
