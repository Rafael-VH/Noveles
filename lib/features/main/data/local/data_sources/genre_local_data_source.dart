import 'package:noveles/features/main/data/local/models/model.dart';
import 'package:noveles/features/main/data/local/string/genre_string.dart';

class GenreLocalDataSource {
  //  Los generos
  static List<GenreLocalModel> allGenre = [
    action,
    adventure,
    comedy,
    drama,
    evolution,
    fantasy,
    harem,
    martialArts,
    mecha,
    mystery,
    r18,
    reincarnation,
    romance,
    schoolLife,
    sciFi,
    shounen,
    supernatural,
    system,
    tragedy,
    xuanhuan,
  ];

  //  Acción
  static GenreLocalModel action = GenreLocalModel(
    id: 0,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.actionGENRE,
    description: GenreString.actionDescriptionGENRE,
  );

  //  Aventura
  static GenreLocalModel adventure = GenreLocalModel(
    id: 1,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.adventureGENRE,
    description: GenreString.adventureDescriptionGENRE,
  );

  //  Comedia
  static GenreLocalModel comedy = GenreLocalModel(
    id: 2,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.comedyGENRE,
    description: GenreString.comedyDescriptionGENRE,
  );

  //  Drama
  static GenreLocalModel drama = GenreLocalModel(
    id: 3,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.dramaGENRE,
    description: GenreString.dramaDescriptionGENRE,
  );

  //  Evolución
  static GenreLocalModel evolution = GenreLocalModel(
    id: 4,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.evolutionGENRE,
    description: GenreString.evolutionDescriptionGENRE,
  );

  //  Fantasia
  static GenreLocalModel fantasy = GenreLocalModel(
    id: 5,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.fantasyGENRE,
    description: GenreString.fantasyDescriptionGENRE,
  );

  //  Harem
  static GenreLocalModel harem = GenreLocalModel(
    id: 6,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.haremGENRE,
    description: GenreString.haremDescriptionGENRE,
  );

  //  Artes marciales
  static GenreLocalModel martialArts = GenreLocalModel(
    id: 7,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.martialArtsGENRE,
    description: GenreString.martialArtsDescriptionGENRE,
  );

  //  Meca
  static GenreLocalModel mecha = GenreLocalModel(
    id: 8,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.mechaGENRE,
    description: GenreString.mechaDescriptionGENRE,
  );

  //  Misterio
  static GenreLocalModel mystery = GenreLocalModel(
    id: 9,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.mysteryGENRE,
    description: GenreString.mysteryDescriptionGENRE,
  );

  //  R18
  static GenreLocalModel r18 = GenreLocalModel(
    id: 10,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.r18GENRE,
    description: GenreString.r18DescriptionGENRE,
  );

  //  Reencarnación
  static GenreLocalModel reincarnation = GenreLocalModel(
    id: 11,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.reincarnationGENRE,
    description: GenreString.reincarnationDescriptionGENRE,
  );

  //  Romance
  static GenreLocalModel romance = GenreLocalModel(
    id: 12,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.romanceGENRE,
    description: GenreString.romanceDescriptionGENRE,
  );

  //  Vida escolar
  static GenreLocalModel schoolLife = GenreLocalModel(
    id: 13,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.schoolLifeGENRE,
    description: GenreString.schoolLifeDescriptionGENRE,
  );

  //  Ciencia ficción
  static GenreLocalModel sciFi = GenreLocalModel(
    id: 14,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.sciFiGENRE,
    description: GenreString.sciFiDescriptionGENRE,
  );

  //  Shounen
  static GenreLocalModel shounen = GenreLocalModel(
    id: 15,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.shounenGENRE,
    description: GenreString.shounenDescriptionGENRE,
  );

  //  Sobrenatural
  static GenreLocalModel supernatural = GenreLocalModel(
    id: 16,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.supernaturalGENRE,
    description: GenreString.supernaturalDescriptionGENRE,
  );

  //  Sistema
  static GenreLocalModel system = GenreLocalModel(
    id: 17,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.systemGENRE,
    description: GenreString.systemDescriptionGENRE,
  );

  //  Tragedia
  static GenreLocalModel tragedy = GenreLocalModel(
    id: 18,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.tragedyGENRE,
    description: GenreString.tragedyDescriptionGENRE,
  );

  //  Xuanhuan
  static GenreLocalModel xuanhuan = GenreLocalModel(
    id: 19,
    createdAt: DateTime(2024, 04, 21),
    name: GenreString.xuanhuanGENRE,
    description: GenreString.xuanhuanDescriptionGENRE,
  );
}
