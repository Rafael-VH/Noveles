import 'package:noveles/features/data/local/data_sources/data_source.dart';
import 'package:noveles/features/data/local/models/model.dart';

class GenreLocalDataSourceCR {
  //  Solo Leveling
  static List<GenreLocalModel> soloLeveling = [
    GenreLocalDataSource.action,
    GenreLocalDataSource.adventure,
    GenreLocalDataSource.drama,
    GenreLocalDataSource.fantasy,
    GenreLocalDataSource.mystery,
    GenreLocalDataSource.shounen,
    GenreLocalDataSource.supernatural,
  ];

  //  Everyone Else Is A Returnee
  static List<GenreLocalModel> everyoneElseIsAReturneeCR = [
    GenreLocalDataSource.action,
    GenreLocalDataSource.martialArts,
    GenreLocalDataSource.adventure,
    GenreLocalDataSource.comedy,
    GenreLocalDataSource.fantasy,
    GenreLocalDataSource.harem,
    GenreLocalDataSource.romance,
  ];
}
