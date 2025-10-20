import 'package:noveles/features/data/local/data_sources/data_source.dart';
import 'package:noveles/features/data/local/models/model.dart';
import 'package:noveles/features/data/local/string/string.dart';

class BookLocalDataSourceJP {
  static BookLocalModel oreWaSeikanKokkaNoAkutokuRyoshu = BookLocalModel(
    id: 5,
    createdAt: DateTime(2024, 04, 21),
    cover: OreWaSeikanKokkaNoAkutokuRyoshuJP.cover,
    name: OreWaSeikanKokkaNoAkutokuRyoshuJP.name,
    short: OreWaSeikanKokkaNoAkutokuRyoshuJP.short,
    alternative: OreWaSeikanKokkaNoAkutokuRyoshuJP.alternative,
    description: OreWaSeikanKokkaNoAkutokuRyoshuJP.description,
    author: OreWaSeikanKokkaNoAkutokuRyoshuJP.author,
    country: OreWaSeikanKokkaNoAkutokuRyoshuJP.country,
    state: OreWaSeikanKokkaNoAkutokuRyoshuJP.state,
    type: OreWaSeikanKokkaNoAkutokuRyoshuJP.type,
    release: OreWaSeikanKokkaNoAkutokuRyoshuJP.release,
    took: OreWaSeikanKokkaNoAkutokuRyoshuJP.took,
    chapter: OreWaSeikanKokkaNoAkutokuRyoshuJP.chapter,
    source: OreWaSeikanKokkaNoAkutokuRyoshuJP.source,
    link: OreWaSeikanKokkaNoAkutokuRyoshuJP.link,
    listGenre: GenreLocalDataSourceJP.oreWaSeikanKokkaNoAkutokuRyoshu,
    listTook: TooksOreWaSeikanKokkaNoAkutokuRyoshu.listTooksOSKAR,
  );
}
