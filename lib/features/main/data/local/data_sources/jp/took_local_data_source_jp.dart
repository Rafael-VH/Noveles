import 'package:noveles/features/main/data/local/data_sources/data_source.dart';
import 'package:noveles/features/main/data/local/models/model.dart';
import 'package:noveles/features/main/data/local/string/string.dart';

//  Ore Wa Seikan Kokka No Akutoku Ryoshu
class TooksOreWaSeikanKokkaNoAkutokuRyoshu {
  static List<TookLocalModel> listTooksOSKAR = [
    TookLocalModel(
      id: 0,
      createdAt: DateTime(2024, 04, 21),
      cover: OreWaSeikanKokkaNoAkutokuRyoshuTook1.tookAssets,
      title: OreWaSeikanKokkaNoAkutokuRyoshuTook1.tookTitle,
      number: OreWaSeikanKokkaNoAkutokuRyoshuTook1.tookNumber,
      content: OreWaSeikanKokkaNoAkutokuRyoshuTook1.tookContent,
      listChapter: ChaptersOreWaSeikanKokkaNoAkutokuRyoshu.chaptersTooks1OSKAR,
    ),
  ];
}
