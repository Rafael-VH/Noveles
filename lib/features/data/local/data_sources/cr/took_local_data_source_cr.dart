import 'package:noveles/features/data/local/data_sources/data_source.dart';
import 'package:noveles/features/data/local/models/model.dart';
import 'package:noveles/features/data/local/string/string.dart';

class TooksSoloLevelingCR {
  static List<TookLocalModel> listTooksSL = [
    TookLocalModel(
      id: 0,
      createdAt: DateTime(2024, 04, 21),
      cover: SoloLevelingTook1.tookAssets,
      title: SoloLevelingTook1.tookTitle,
      number: SoloLevelingTook1.tookNumber,
      content: SoloLevelingTook1.tookContent,
      listChapter: ChaptersSoloLevelingCR.chaptersTooks1SL,
    ),
  ];
}

//  Everyone Else Is A Returnee
class TooksEveryoneElseIsAReturneeCR {
  static List<TookLocalModel> listTooksEER = [];
}
