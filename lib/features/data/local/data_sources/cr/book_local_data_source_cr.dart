import 'package:noveles/features/data/local/data_sources/data_source.dart';
import 'package:noveles/features/data/local/models/model.dart';
import 'package:noveles/features/data/local/string/string.dart';

class BookLocalDataSourceCR {
  static BookLocalModel everyoneElseIsAReturnee = BookLocalModel(
    id: 4,
    createdAt: DateTime(2024, 04, 21),
    cover: EveryoneElseIsAReturneeCR.cover,
    name: EveryoneElseIsAReturneeCR.name,
    short: EveryoneElseIsAReturneeCR.short,
    alternative: EveryoneElseIsAReturneeCR.alternative,
    description: EveryoneElseIsAReturneeCR.description,
    author: EveryoneElseIsAReturneeCR.author,
    country: EveryoneElseIsAReturneeCR.country,
    state: EveryoneElseIsAReturneeCR.state,
    type: EveryoneElseIsAReturneeCR.type,
    release: EveryoneElseIsAReturneeCR.release,
    took: EveryoneElseIsAReturneeCR.took,
    chapter: EveryoneElseIsAReturneeCR.chapter,
    source: EveryoneElseIsAReturneeCR.source,
    link: EveryoneElseIsAReturneeCR.link,
    listGenre: GenreLocalDataSourceCR.everyoneElseIsAReturneeCR,
    listTook: TooksEveryoneElseIsAReturneeCR.listTooksEER,
  );

  static BookLocalModel soloLeveling = BookLocalModel(
    id: 1,
    createdAt: DateTime(2024, 04, 21),
    cover: SoloLevelingCR.cover,
    name: SoloLevelingCR.name,
    short: SoloLevelingCR.short,
    alternative: SoloLevelingCR.alternative,
    description: SoloLevelingCR.description,
    author: SoloLevelingCR.author,
    country: SoloLevelingCR.country,
    state: SoloLevelingCR.state,
    type: SoloLevelingCR.type,
    release: SoloLevelingCR.release,
    took: SoloLevelingCR.took,
    chapter: SoloLevelingCR.chapter,
    source: SoloLevelingCR.source,
    link: SoloLevelingCR.link,
    listGenre: GenreLocalDataSourceCR.soloLeveling,
    listTook: TooksSoloLevelingCR.listTooksSL,
  );
}
