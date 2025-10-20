import 'package:noveles/features/data/local/data_sources/data_source.dart';
import 'package:noveles/features/data/local/models/model.dart';

//  Douluo Dalu 1
class TooksDouluoDalu1 {
  static List<TookLocalModel> listTooksDD1 = [
    TookLocalModel(
      id: 0,
      createdAt: DateTime(2024, 04, 21),
      cover: "assets/cover/ch/douluoDalu1.png",
      title: "title",
      number: "Tomo 1",
      content: "8",
      listChapter: ChaptersDouluoDalu1.chapterTook1DD1,
    ),
  ];
}

//  Douluo Dalu 2
class TooksDouluoDalu2 {
  static List<TookLocalModel> listTooksDD2 = [
    TookLocalModel(
      id: 0,
      createdAt: DateTime(2024, 04, 21),
      cover: "assets/cover/ch/douluoDalu2.png",
      title: "title",
      number: "Tomo 1",
      content: "12",
      listChapter: ChaptersDouluoDalu2.chapterTook1DD2,
    ),
  ];
}

//  Swallowed Star
class TooksSwallowedStar {
  static List<TookLocalModel> listTooksSS = [
    TookLocalModel(
      id: 0,
      createdAt: DateTime(2024, 04, 21),
      cover: "assets/cover/cr/soloLeveling.png",
      title: "title",
      number: "Tomo 1",
      content: "12",
      listChapter: ChaptersSwallowedStar.chaptersTooks1SS,
    ),
  ];
}
