import 'package:noveles/features/data/local/data_sources/data_source.dart';
import 'package:noveles/features/data/local/models/model.dart';

class GenreLocalDataSourceCH {
  //  Douluo Dalu
  static List<GenreLocalModel> douluoDalu1 = [
    GenreLocalDataSource.action,
    GenreLocalDataSource.martialArts,
    GenreLocalDataSource.adventure,
    GenreLocalDataSource.fantasy,
    GenreLocalDataSource.romance,
    GenreLocalDataSource.shounen,
    GenreLocalDataSource.tragedy,
    GenreLocalDataSource.xuanhuan,
  ];

  //  Douluo Dalu 2
  static List<GenreLocalModel> douluoDalu2 = [
    GenreLocalDataSource.action,
    GenreLocalDataSource.adventure,
    GenreLocalDataSource.fantasy,
    GenreLocalDataSource.martialArts,
    GenreLocalDataSource.mystery,
    GenreLocalDataSource.schoolLife,
    GenreLocalDataSource.shounen,
    GenreLocalDataSource.xuanhuan,
  ];

  //  Swallowed Star
  static List<GenreLocalModel> swallowedStar = [
    GenreLocalDataSource.action,
    GenreLocalDataSource.adventure,
    GenreLocalDataSource.fantasy,
    GenreLocalDataSource.martialArts,
    GenreLocalDataSource.sciFi,
    GenreLocalDataSource.shounen,
    GenreLocalDataSource.xuanhuan,
  ];
}
