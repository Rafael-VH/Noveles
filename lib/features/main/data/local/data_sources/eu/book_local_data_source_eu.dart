import 'package:noveles/features/main/data/local/data_sources/data_source.dart';
import 'package:noveles/features/main/data/local/models/model.dart';
import 'package:noveles/features/main/data/local/string/string.dart';

class BookLocalDataSourceEU {
  static BookLocalModel reincarnatedWithTheStrongestSystem = BookLocalModel(
    id: 3,
    createdAt: DateTime(2024, 04, 21),
    cover: ReincarnatedWithTheStrongestSystemEU.cover,
    name: ReincarnatedWithTheStrongestSystemEU.name,
    short: ReincarnatedWithTheStrongestSystemEU.short,
    alternative: ReincarnatedWithTheStrongestSystemEU.alternative,
    description: ReincarnatedWithTheStrongestSystemEU.description,
    author: ReincarnatedWithTheStrongestSystemEU.author,
    country: ReincarnatedWithTheStrongestSystemEU.country,
    state: ReincarnatedWithTheStrongestSystemEU.state,
    type: ReincarnatedWithTheStrongestSystemEU.type,
    release: ReincarnatedWithTheStrongestSystemEU.release,
    took: ReincarnatedWithTheStrongestSystemEU.took,
    chapter: ReincarnatedWithTheStrongestSystemEU.chapter,
    source: ReincarnatedWithTheStrongestSystemEU.source,
    link: ReincarnatedWithTheStrongestSystemEU.link,
    listGenre: GenreLocalDataSourceEU.reincarnatedWithTheStrongestSystem,
    listTook: TooksReincarnatedWithTheStrongestSystem.listTooksRWTSS,
  );

}
