-- ============================================================
-- NovelEs — Seed Data
-- ============================================================

-- AUTHORS
INSERT INTO authors (id, created_at, name, description) VALUES
(1, '2024-04-21', 'Chugong', '')
ON CONFLICT (id) DO NOTHING;
INSERT INTO authors (id, created_at, name, description) VALUES
(2, '2024-04-21', 'Elyon', '')
ON CONFLICT (id) DO NOTHING;
INSERT INTO authors (id, created_at, name, description) VALUES
(3, '2024-04-21', 'I Eat Tomatoes', '')
ON CONFLICT (id) DO NOTHING;
INSERT INTO authors (id, created_at, name, description) VALUES
(4, '2024-04-21', 'Mishima Yomu', '')
ON CONFLICT (id) DO NOTHING;
INSERT INTO authors (id, created_at, name, description) VALUES
(5, '2024-04-21', 'Tang Jia San Shao', '')
ON CONFLICT (id) DO NOTHING;
INSERT INTO authors (id, created_at, name, description) VALUES
(6, '2024-04-21', 'Toy car', '')
ON CONFLICT (id) DO NOTHING;

-- GENRES
INSERT INTO genres (id, created_at, name, description) VALUES
(0,  '2024-04-21', 'Acción', 'Descripción temporal'),
(1,  '2024-04-21', 'Aventura', 'Descripción temporal'),
(2,  '2024-04-21', 'Comedia', 'Descripción temporal'),
(3,  '2024-04-21', 'Drama', 'Descripción temporal'),
(4,  '2024-04-21', 'Evolución', 'Descripción temporal'),
(5,  '2024-04-21', 'Fantasia', 'Descripción temporal'),
(6,  '2024-04-21', 'Harem', 'Descripción temporal'),
(7,  '2024-04-21', 'Artes marciales', 'Descripción temporal'),
(8,  '2024-04-21', 'Meca', 'Descripción temporal'),
(9,  '2024-04-21', 'Misterio', 'Descripción temporal'),
(10, '2024-04-21', 'R18', 'Descripción temporal'),
(11, '2024-04-21', 'Reencarnación', 'Descripción temporal'),
(12, '2024-04-21', 'Romance', 'Descripción temporal'),
(13, '2024-04-21', 'Vida escolar', 'Descripción temporal'),
(14, '2024-04-21', 'Ciencia Ficción', 'Descripción temporal'),
(15, '2024-04-21', 'Shounen', 'Descripción general'),
(16, '2024-04-21', 'Sobrenatural', 'Descripción temporal'),
(17, '2024-04-21', 'Sistema', 'Descripción temporal'),
(18, '2024-04-21', 'Tragedia', 'Descripción temporal'),
(19, '2024-04-21', 'Xuanhuan', 'Descripción temporal')
ON CONFLICT (id) DO NOTHING;

-- BOOKS
INSERT INTO books (id, created_at, cover, name, short, alternative, description, author_id, country, state, type, release, took_count, chapter_count, source, link, is_favorite) VALUES
(0,  '2024-04-21', 'assets/cover/ch/swallowedStar.png', 'Estrella Tragada', 'SS', E'Swallowed Star\nThe legend of spacewalker\nTun Shi Xing Kong', E'Año 2056, en una ciudad del área de Yuan Jiang Su Jin. Encima de un apartamento residencial de seis pisos en ruinas y destrozado se encuentra un adolescente que viste un chaleco de combate, pantalones militares y botas de combate de aleación.\n\nEn su espalda hay un escudo hexagonal y está equipado un cuchillo de batalla de sombra-sangre. Se sienta allí en silencio en el borde del techo.\n\nEn este momento, el cielo resplandeciente brillaba y había un aliento refrescante en el aire que soplaba hacia él. Sin embargo, solo había silencio dentro de la ciudad desierta y en ruinas, con un aullido ocasional que hace que tu corazón se acelere.', 3, 'China', 'Finalizado', 'Web', '2010', '32', '1477', 'Qidian', 'https://book.qidian.com/info/1639199/', false),
(1,  '2024-04-21', 'assets/cover/cr/soloLeveling.png', 'Solo Leveling', 'SL', E'I Level Up Alone\nOnly I Level Up\n나 혼자만 레벨업', E'Hace 10 años, después de que se abriera "la Puerta" que conectaba el mundo real con el mundo de los monstruos, algunas personas comunes y corrientes recibieron el poder de cazar monstruos dentro de la Puerta.Se les conoce como "Cazadores".\n\nSin embargo, no todos los cazadores son poderosos.Mi nombre es Sung Jin-Woo, un cazador de rango E.Soy alguien que tiene que arriesgar su vida en la más baja de las catacumbas, la "más débil del mundo".\n\nAl no tener ninguna habilidad para mostrar, apenas gané el dinero requerido luchando en catacumbas de bajo nivel... ¡al menos hasta que encontré una catacumba oculta con la dificultad más difícil dentro de las catacumbas de rango D!\n\nAl final, mientras aceptaba la muerte, de repente recibí un poder extraño, un registro de misiones que solo yo podía ver, ¡un secreto para subir de nivel que solo yo conocía!Si entrenaba de acuerdo con mis misiones y cazaba monstruos, mi nivel aumentaría.\n\n¡Cambiar del cazador más débil al cazador de rango S más fuerte!', 1, 'Corea', 'Finalizado', 'Web', '2016', '5', '270', '-', '-', false),
(3,  '2024-04-21', 'assets/cover/eu/reincarnatedWithTheStrongestSystem.jpg', 'Reencarnado con el sistema más fuerte', 'RWTSS', 'Reincarnated With The Strongest System', 'Descripción pendiente', 2, 'Otros', 'Finalizado', 'Web', '2021', '9', '1.474', 'WebNovel', 'https://www.webnovel.com/book/reincarnated-with-the-strongest-system_19720038005035905', false),
(4,  '2024-04-21', 'assets/cover/cr/everyoneElseIsAReturnee.png', 'Todos los Demás están de Regreso', 'EER', E'Everyone Else is a Returnee\n나 빼고 다 귀환자', 'Descripción pendiente', 6, 'Corea', 'Finalizado', 'Web', '2016', '15', '348', '-', '-', false),
(5,  '2024-04-21', 'assets/cover/jp/oreWaSeikanKokkaNoAkutokuRyoshuVol1.png', 'Soy un Lord Malvado de un Imperio Intergalactico!', 'OSKAR', 'Ore wa Seikan Kokka no Akutoku Ryōshu!', 'Descripción pendiente', 4, 'Japon', 'Emisión', 'Ligera', '2018', '8', '47', '-', '-', false),
(8,  '2024-04-21', 'assets/cover/ch/douluoDalu1.png', 'Douluo Dalu', 'DD', E'Combat Continent\nSoul Land\nLands of Battle', 'Descripción pendiente', 5, 'China', 'Finalizado', 'Web', '2008', '47', '336', 'Qidian', 'https://book.qidian.com/info/1115277/', false),
(11, '2024-04-21', 'assets/cover/ch/douluoDalu2.png', 'Secta Tang sin Igual', 'DD2', E'Combat Continent 2\nSoul Land II\nDouluo Dalu 2\nInigualable Tang Sect', 'Descripción pendiente', 5, 'China', 'Finalizado', 'Web', '2012', '72', '622', 'Qidian', 'https://book.qidian.com/info/2517792/', false)
ON CONFLICT (id) DO NOTHING;

-- BOOKS_GENRES
-- Swallowed Star (0): Acción, Aventura, Fantasia, Artes marciales, Ciencia Ficción, Shounen, Xuanhuan
INSERT INTO books_genres (book_id, genre_id) VALUES
(0, 0), (0, 1), (0, 5), (0, 7), (0, 14), (0, 15), (0, 19);
-- Solo Leveling (1): Acción, Aventura, Drama, Fantasia, Misterio, Shounen, Sobrenatural
INSERT INTO books_genres (book_id, genre_id) VALUES
(1, 0), (1, 1), (1, 3), (1, 5), (1, 9), (1, 15), (1, 16);
-- RWTSS (3): Acción, Aventura, Comedia, Evolución, Harem, R18, Reencarnación, Romance, Sistema
INSERT INTO books_genres (book_id, genre_id) VALUES
(3, 0), (3, 1), (3, 2), (3, 4), (3, 6), (3, 10), (3, 11), (3, 12), (3, 17);
-- EER (4): Acción, Artes marciales, Aventura, Comedia, Fantasia, Harem, Romance
INSERT INTO books_genres (book_id, genre_id) VALUES
(4, 0), (4, 7), (4, 1), (4, 2), (4, 5), (4, 6), (4, 12);
-- Oskar (5): Acción, Aventura, Comedia, Fantasia, Ciencia Ficción, Meca
INSERT INTO books_genres (book_id, genre_id) VALUES
(5, 0), (5, 1), (5, 2), (5, 5), (5, 14), (5, 8);
-- DD1 (8): Acción, Artes marciales, Aventura, Fantasia, Romance, Shounen, Tragedia, Xuanhuan
INSERT INTO books_genres (book_id, genre_id) VALUES
(8, 0), (8, 7), (8, 1), (8, 5), (8, 12), (8, 15), (8, 18), (8, 19);
-- DD2 (11): Acción, Aventura, Fantasia, Artes marciales, Misterio, Vida escolar, Shounen, Xuanhuan
INSERT INTO books_genres (book_id, genre_id) VALUES
(11, 0), (11, 1), (11, 5), (11, 7), (11, 9), (11, 13), (11, 15), (11, 19);

-- Tooks (Volumes)
-- Solo Leveling - Took 1 (id=0, book_id=1)
INSERT INTO tooks (id, created_at, book_id, cover, number, title, content) VALUES
(1, '2024-04-21', 1, 'assets/cover/cr/soloLeveling.png', 'Tomo 1', '-', '12')
ON CONFLICT (id) DO NOTHING;

-- RWTSS - Took 1 (id=3, book_id=3)
INSERT INTO tooks (id, created_at, book_id, cover, number, title, content) VALUES
(2, '2024-04-21', 3, 'assets/cover/eu/reincarnatedWithTheStrongestSystem.jpg', 'Tomo 1', 'El pastor de Lont', '118')
ON CONFLICT (id) DO NOTHING;

-- Oskar - Took 1 (id=5, book_id=5)
INSERT INTO tooks (id, created_at, book_id, cover, number, title, content) VALUES
(3, '2024-04-21', 5, 'assets/cover/jp/oreWaSeikanKokkaNoAkutokuRyoshuVol1.png', 'Tomo 1', '-', '17')
ON CONFLICT (id) DO NOTHING;

-- Swallowed Star - Took 1 (id=0, book_id=0)
INSERT INTO tooks (id, created_at, book_id, cover, number, title, content) VALUES
(4, '2024-04-21', 0, 'assets/cover/cr/soloLeveling.png', 'Tomo 1', 'title', '12')
ON CONFLICT (id) DO NOTHING;

-- DD1 - Took 1 (id=8, book_id=8)
INSERT INTO tooks (id, created_at, book_id, cover, number, title, content) VALUES
(5, '2024-04-21', 8, 'assets/cover/ch/douluoDalu1.png', 'Tomo 1', 'title', '8')
ON CONFLICT (id) DO NOTHING;

-- DD2 - Took 1 (id=11, book_id=11)
INSERT INTO tooks (id, created_at, book_id, cover, number, title, content) VALUES
(6, '2024-04-21', 11, 'assets/cover/ch/douluoDalu2.png', 'Tomo 1', 'title', '12')
ON CONFLICT (id) DO NOTHING;

-- CHAPTERS
-- Solo Leveling - Took 1 (took_id=1)
INSERT INTO chapters (id, created_at, took_id, number, title, content) VALUES
(1,  '2024-04-21', 1, 'Capítulo 0',  'Prologo',                                       'assets/book/cr/sl/slTook1Ch0.txt'),
(2,  '2024-04-21', 1, 'Capítulo 1',  'Cazador de rango E',                            'assets/book/cr/sl/slTook1Ch1.txt'),
(3,  '2024-04-21', 1, 'Capítulo 2',  'Doble mazmorra',                                'assets/book/cr/sl/slTook1Ch2.txt'),
(4,  '2024-04-21', 1, 'Capítulo 3',  'El comienzo de la batalla',                     'assets/book/cr/sl/slTook1Ch3.txt'),
(5,  '2024-04-21', 1, 'Capítulo 4',  'Los tres mandamientos',                          'assets/book/cr/sl/slTook1Ch4.txt'),
(6,  '2024-04-21', 1, 'Capítulo 5',  'El juicio final',                                'assets/book/cr/sl/slTook1Ch5.txt'),
(7,  '2024-04-21', 1, 'Capítulo 6',  'Castigo',                                        'assets/book/cr/sl/slTook1Ch6.txt'),
(8,  '2024-04-21', 1, 'Capítulo 7',  'Misión diaria',                                  'assets/book/cr/sl/slTook1Ch7.txt'),
(9,  '2024-04-21', 1, 'Capítulo 8',  '¡Subida de nivel!',                              'assets/book/cr/sl/slTook1Ch8.txt'),
(10, '2024-04-21', 1, 'Capítulo 9',  'Lagartos',                                       'assets/book/cr/sl/slTook1Ch9.txt'),
(11, '2024-04-21', 1, 'Capítulo 10', 'Dar y recibir',                                  'assets/book/cr/sl/slTook1Ch10.txt'),
(12, '2024-04-21', 1, 'Capítulo 11', 'Acuerdo',                                        'assets/book/cr/sl/slTook1Ch11.txt');

-- RWTSS - Took 1 (took_id=2)
INSERT INTO chapters (id, created_at, took_id, number, title, content) VALUES
(13,  '2024-04-21', 2, 'Capítulo 1',   'Voy a ir primero... No me extrañes demasiado',              'assets/book/eu/rwtss/rwtssTook1Ch1.txt'),
(14,  '2024-04-21', 2, 'Capítulo 2',   'El Templo de los Diez Mil Dioses',                         'assets/book/eu/rwtss/rwtssTook1Ch2.txt'),
(15,  '2024-04-21', 2, 'Capítulo 3',   'Encontrar un Dios Protector',                               'assets/book/eu/rwtss/rwtssTook1Ch3.txt'),
(16,  '2024-04-21', 2, 'Capítulo 4',   'La elección de William',                                     'assets/book/eu/rwtss/rwtssTook1Ch4.txt'),
(17,  '2024-04-21', 2, 'Capítulo 5',   'Firma del contrato',                                        'assets/book/eu/rwtss/rwtssTook1Ch5.txt'),
(18,  '2024-04-21', 2, 'Capítulo 6',   '¡Voy a desmantelarte, joder!',                              'assets/book/eu/rwtss/rwtssTook1Ch6.txt'),
(19,  '2024-04-21', 2, 'Capítulo 7',   'William Von Ainsworth',                                      'assets/book/eu/rwtss/rwtssTook1Ch7.txt'),
(20,  '2024-04-21', 2, 'Capítulo 8',   'Feudo de Lont',                                              'assets/book/eu/rwtss/rwtssTook1Ch8.txt'),
(21,  '2024-04-21', 2, 'Capítulo 9',   '¡Escapar! ¡Debo escapar!',                                  'assets/book/eu/rwtss/rwtssTook1Ch9.txt'),
(22,  '2024-04-21', 2, 'Capítulo 10',  '¡Es hora de contraatacar!',                                 'assets/book/eu/rwtss/rwtssTook1Ch10.txt'),
(23,  '2024-04-21', 2, 'Capítulo 11',  'Elegir un camino [Parte 1]',                                'assets/book/eu/rwtss/rwtssTook1Ch11.txt'),
(24,  '2024-04-21', 2, 'Capítulo 12',  'Elegir un camino [Parte 2]',                                'assets/book/eu/rwtss/rwtssTook1Ch12.txt'),
(25,  '2024-04-21', 2, 'Capítulo 13',  'Arroz cocido',                                              'assets/book/eu/rwtss/rwtssTook1Ch13.txt'),
(26,  '2024-04-21', 2, 'Capítulo 14',  'Códigos de trucos',                                        'assets/book/eu/rwtss/rwtssTook1Ch14.txt'),
(27,  '2024-04-21', 2, 'Capítulo 15',  'Encontrar un objetivo adecuado',                            'assets/book/eu/rwtss/rwtssTook1Ch15.txt'),
(28,  '2024-04-21', 2, 'Capítulo 16',  'Se avecina una tormenta',                                   'assets/book/eu/rwtss/rwtssTook1Ch16.txt'),
(29,  '2024-04-21', 2, 'Capítulo 17',  'Invitados de lejos [Parte 1]',                              'assets/book/eu/rwtss/rwtssTook1Ch17.txt'),
(30,  '2024-04-21', 2, 'Capítulo 18',  'Invitados de lejos [Parte 2]',                              'assets/book/eu/rwtss/rwtssTook1Ch18.txt'),
(31,  '2024-04-21', 2, 'Capítulo 19',  'El compromiso de William [Parte 1]',                        'assets/book/eu/rwtss/rwtssTook1Ch19.txt'),
(32,  '2024-04-21', 2, 'Capítulo 20',  'El compromiso de William [Parte 2]',                        'assets/book/eu/rwtss/rwtssTook1Ch20.txt'),
(33,  '2024-04-21', 2, 'Capítulo 21',  'El invocador de tormentas',                                 'assets/book/eu/rwtss/rwtssTook1Ch21.txt'),
(34,  '2024-04-21', 2, 'Capítulo 22',  'El poder de los elementos',                                 'assets/book/eu/rwtss/rwtssTook1Ch22.txt'),
(35,  '2024-04-21', 2, 'Capítulo 23',  'El guerrero troll con esteroides',                          'assets/book/eu/rwtss/rwtssTook1Ch23.txt'),
(36,  '2024-04-21', 2, 'Capítulo 24',  'Primera pelea contra el jefe',                              'assets/book/eu/rwtss/rwtssTook1Ch24.txt'),
(37,  '2024-04-21', 2, 'Capítulo 25',  'Marea de lobos [Parte 1]',                                  'assets/book/eu/rwtss/rwtssTook1Ch25.txt'),
(38,  '2024-04-21', 2, 'Capítulo 26',  'Marea de lobos [Parte 2]',                                  'assets/book/eu/rwtss/rwtssTook1Ch26.txt'),
(39,  '2024-04-21', 2, 'Capítulo 27',  'Marea de lobos [Parte 3]',                                  'assets/book/eu/rwtss/rwtssTook1Ch27.txt'),
(40,  '2024-04-21', 2, 'Capítulo 28',  'El secreto de William',                                      'assets/book/eu/rwtss/rwtssTook1Ch28.txt'),
(41,  '2024-04-21', 2, 'Capítulo 29',  'La llegada del monstruo jefe',                               'assets/book/eu/rwtss/rwtssTook1Ch29.txt'),
(42,  '2024-04-21', 2, 'Capítulo 30',  '¡Toda tu experiencia me pertenece!',                         'assets/book/eu/rwtss/rwtssTook1Ch30.txt'),
(43,  '2024-04-21', 2, 'Capítulo 31',  'O muere, o morimos nosotros',                                'assets/book/eu/rwtss/rwtssTook1Ch31.txt'),
(44,  '2024-04-21', 2, 'Capítulo 32',  'Mensaje del autor',                                          'assets/book/eu/rwtss/rwtssTook1Ch32.txt'),
(45,  '2024-04-21', 2, 'Capítulo 33',  'Aniquilación por tormenta [Parte 1]',                        'assets/book/eu/rwtss/rwtssTook1Ch33.txt'),
(46,  '2024-04-21', 2, 'Capítulo 34',  'Aniquilación por tormenta [Parte 2]',                        'assets/book/eu/rwtss/rwtssTook1Ch34.txt'),
(47,  '2024-04-21', 2, 'Capítulo 35',  'En busca de una segunda opinión',                            'assets/book/eu/rwtss/rwtssTook1Ch35.txt'),
(48,  '2024-04-21', 2, 'Capítulo 36',  'El sentido del nombre de William',                           'assets/book/eu/rwtss/rwtssTook1Ch36.txt'),
(49,  '2024-04-21', 2, 'Capítulo 37',  'La incursión a la mazmorra [Parte 1]',                       'assets/book/eu/rwtss/rwtssTook1Ch37.txt'),
(50,  '2024-04-21', 2, 'Capítulo 38',  'La incursión a la mazmorra [Parte 2]',                       'assets/book/eu/rwtss/rwtssTook1Ch38.txt'),
(51,  '2024-04-21', 2, 'Capítulo 39',  'La expansión de Lont',                                       'assets/book/eu/rwtss/rwtssTook1Ch39.txt'),
(52,  '2024-04-21', 2, 'Capítulo 40',  'Un tonto testarudo',                                         'assets/book/eu/rwtss/rwtssTook1Ch40.txt'),
(53,  '2024-04-21', 2, 'Capítulo 41',  'Cruzaremos ese puente cuando lleguemos allí',                'assets/book/eu/rwtss/rwtssTook1Ch41.txt'),
(54,  '2024-04-21', 2, 'Capítulo 42',  'El amor de un padre',                                        'assets/book/eu/rwtss/rwtssTook1Ch42.txt'),
(55,  '2024-04-21', 2, 'Capítulo 43',  'Regreso a la Cripta de los Goblins',                         'assets/book/eu/rwtss/rwtssTook1Ch43.txt'),
(56,  '2024-04-21', 2, 'Capítulo 44',  'La caída de William',                                        'assets/book/eu/rwtss/rwtssTook1Ch44.txt'),
(57,  '2024-04-21', 2, 'Capítulo 45',  'El viejo jengibre sigue siendo picante',                     'assets/book/eu/rwtss/rwtssTook1Ch45.txt'),
(58,  '2024-04-21', 2, 'Capítulo 46',  'Combatir el fuego con fuego',                                'assets/book/eu/rwtss/rwtssTook1Ch46.txt'),
(59,  '2024-04-21', 2, 'Capítulo 47',  'Tus quince minutos comienzan ahora',                         'assets/book/eu/rwtss/rwtssTook1Ch47.txt'),
(60,  '2024-04-21', 2, 'Capítulo 48',  'No te arrepientas de tu decisión, pequeña Will',             'assets/book/eu/rwtss/rwtssTook1Ch48.txt'),
(61,  '2024-04-21', 2, 'Capítulo 49',  'Últimas noticias del reino',                                 'assets/book/eu/rwtss/rwtssTook1Ch49.txt'),
(62,  '2024-04-21', 2, 'Capítulo 50',  'Peligro oculto en las profundidades',                        'assets/book/eu/rwtss/rwtssTook1Ch50.txt'),
(63,  '2024-04-21', 2, 'Capítulo 51',  'El avance laboral en medio de la batalla',                   'assets/book/eu/rwtss/rwtssTook1Ch51.txt'),
(64,  '2024-04-21', 2, 'Capítulo 52',  'Una oportunidad para cambiar las tornas [Parte 1]',          'assets/book/eu/rwtss/rwtssTook1Ch52.txt'),
(65,  '2024-04-21', 2, 'Capítulo 53',  'Una oportunidad para cambiar las tornas [Parte 2]',          'assets/book/eu/rwtss/rwtssTook1Ch53.txt'),
(66,  '2024-04-21', 2, 'Capítulo 54',  'La profecía élfica [Parte 1]',                               'assets/book/eu/rwtss/rwtssTook1Ch54.txt'),
(67,  '2024-04-21', 2, 'Capítulo 55',  'La profecía élfica [Parte 2]',                               'assets/book/eu/rwtss/rwtssTook1Ch55.txt'),
(68,  '2024-04-21', 2, 'Capítulo 56',  'El amor de una madre',                                       'assets/book/eu/rwtss/rwtssTook1Ch56.txt'),
(69,  '2024-04-21', 2, 'Capítulo 57',  'Cosechando beneficios en medio del caos',                    'assets/book/eu/rwtss/rwtssTook1Ch57.txt'),
(70,  '2024-04-21', 2, 'Capítulo 58',  'Es hora de que te conviertas en mi esclavo',                 'assets/book/eu/rwtss/rwtssTook1Ch58.txt'),
(71,  '2024-04-21', 2, 'Capítulo 59',  'Disfruta tu primer sabor del sufrimiento',                   'assets/book/eu/rwtss/rwtssTook1Ch59.txt'),
(72,  '2024-04-21', 2, 'Capítulo 60',  'El hombre debe aprender a pagar sus deudas',                 'assets/book/eu/rwtss/rwtssTook1Ch60.txt'),
(73,  '2024-04-21', 2, 'Capítulo 61',  'La carta largamente esperada de Arwen',                      'assets/book/eu/rwtss/rwtssTook1Ch61.txt'),
(74,  '2024-04-21', 2, 'Capítulo 62',  'Es hora de ir al templo',                                    'assets/book/eu/rwtss/rwtssTook1Ch62.txt'),
(75,  '2024-04-21', 2, 'Capítulo 63',  'Viajando juntos [Parte 1]',                                  'assets/book/eu/rwtss/rwtssTook1Ch63.txt'),
(76,  '2024-04-21', 2, 'Capítulo 64',  'Viajando juntos [Parte 2]',                                  'assets/book/eu/rwtss/rwtssTook1Ch64.txt'),
(77,  '2024-04-21', 2, 'Capítulo 65',  'Cuando el cielo se cae',                                     'assets/book/eu/rwtss/rwtssTook1Ch65.txt'),
(78,  '2024-04-21', 2, 'Capítulo 66',  'El precio de la libertad',                                   'assets/book/eu/rwtss/rwtssTook1Ch66.txt'),
(79,  '2024-04-21', 2, 'Capítulo 67',  'Gran Hermano, ¿Estás feliz con tu vida actual?',             'assets/book/eu/rwtss/rwtssTook1Ch67.txt'),
(80,  '2024-04-21', 2, 'Capítulo 68',  'Los puntos de Dios',                                         'assets/book/eu/rwtss/rwtssTook1Ch68.txt'),
(81,  '2024-04-21', 2, 'Capítulo 69',  'Que las probabilidades estén a tu favor',                    'assets/book/eu/rwtss/rwtssTook1Ch69.txt'),
(82,  '2024-04-21', 2, 'Capítulo 70',  'Separación de caminos',                                      'assets/book/eu/rwtss/rwtssTook1Ch70.txt'),
(83,  '2024-04-21', 2, 'Capítulo 71',  'Llegando a un acuerdo',                                      'assets/book/eu/rwtss/rwtssTook1Ch71.txt'),
(84,  '2024-04-21', 2, 'Capítulo 72',  'El desafío del coraje [Parte 1]',                            'assets/book/eu/rwtss/rwtssTook1Ch72.txt'),
(85,  '2024-04-21', 2, 'Capítulo 73',  'El desafío del coraje [Parte 2]',                            'assets/book/eu/rwtss/rwtssTook1Ch73.txt'),
(86,  '2024-04-21', 2, 'Capítulo 74',  'Alguien que fue favorecido por los dioses',                  'assets/book/eu/rwtss/rwtssTook1Ch74.txt'),
(87,  '2024-04-21', 2, 'Capítulo 75',  'Concede tu poder sobre mis manos indignas',                  'assets/book/eu/rwtss/rwtssTook1Ch75.txt'),
(88,  '2024-04-21', 2, 'Capítulo 76',  'Desagradable a la vista',                                    'assets/book/eu/rwtss/rwtssTook1Ch76.txt'),
(89,  '2024-04-21', 2, 'Capítulo 77',  '¿Somos amigos ahora?',                                       'assets/book/eu/rwtss/rwtssTook1Ch77.txt'),
(90,  '2024-04-21', 2, 'Capítulo 78',  'El viejo duque de Griffith',                                 'assets/book/eu/rwtss/rwtssTook1Ch78.txt'),
(91,  '2024-04-21', 2, 'Capítulo 79',  'Una pareja perfecta',                                        'assets/book/eu/rwtss/rwtssTook1Ch79.txt'),
(92,  '2024-04-21', 2, 'Capítulo 80',  'Duelo después de 7 años',                                    'assets/book/eu/rwtss/rwtssTook1Ch80.txt'),
(93,  '2024-04-21', 2, 'Capítulo 81',  'Siguiendo el guión',                                         'assets/book/eu/rwtss/rwtssTook1Ch81.txt'),
(94,  '2024-04-21', 2, 'Capítulo 82',  'Está bien si nadie lo ve',                                   'assets/book/eu/rwtss/rwtssTook1Ch82.txt'),
(95,  '2024-04-21', 2, 'Capítulo 83',  'Una bendición disfrazada',                                   'assets/book/eu/rwtss/rwtssTook1Ch83.txt'),
(96,  '2024-04-21', 2, 'Capítulo 84',  '¿Te gustaría que William se convirtiera en tu esclavo exclusivo?', 'assets/book/eu/rwtss/rwtssTook1Ch84.txt'),
(97,  '2024-04-21', 2, 'Capítulo 85',  'El dilema de William',                                       'assets/book/eu/rwtss/rwtssTook1Ch85.txt'),
(98,  '2024-04-21', 2, 'Capítulo 86',  'El último clavo en el ataúd',                                'assets/book/eu/rwtss/rwtssTook1Ch86.txt'),
(99,  '2024-04-21', 2, 'Capítulo 87',  'Rankings y profesiones [Parte 1]',                            'assets/book/eu/rwtss/rwtssTook1Ch87.txt'),
(100, '2024-04-21', 2, 'Capítulo 88',  'Rankings y profesiones [Parte 2]',                            'assets/book/eu/rwtss/rwtssTook1Ch88.txt'),
(101, '2024-04-21', 2, 'Capítulo 89',  'El conquistador de mazmorras [Parte 1]',                     'assets/book/eu/rwtss/rwtssTook1Ch89.txt'),
(102, '2024-04-21', 2, 'Capítulo 90',  'El conquistador de mazmorras [Parte 2]',                     'assets/book/eu/rwtss/rwtssTook1Ch90.txt'),
(103, '2024-04-21', 2, 'Capítulo 91',  'El entrenamiento de resistencia de Owen',                     'assets/book/eu/rwtss/rwtssTook1Ch91.txt'),
(104, '2024-04-21', 2, 'Capítulo 92',  'Dentro del Bosque Silencioso [Parte 1]',                     'assets/book/eu/rwtss/rwtssTook1Ch92.txt'),
(105, '2024-04-21', 2, 'Capítulo 93',  'Dentro del Bosque Silencioso [Parte 2]',                     'assets/book/eu/rwtss/rwtssTook1Ch93.txt'),
(106, '2024-04-21', 2, 'Capítulo 94',  'El entrenamiento de artes marciales de Dwayne [Parte 1]',    'assets/book/eu/rwtss/rwtssTook1Ch94.txt'),
(107, '2024-04-21', 2, 'Capítulo 95',  'El entrenamiento de artes marciales de Dwayne [Parte 2]',    'assets/book/eu/rwtss/rwtssTook1Ch95.txt'),
(108, '2024-04-21', 2, 'Capítulo 96',  'El entrenamiento de artes marciales de Dwayne [Parte 3]',    'assets/book/eu/rwtss/rwtssTook1Ch96.txt'),
(109, '2024-04-21', 2, 'Capítulo 97',  'Dando en el blanco [Parte 1]',                               'assets/book/eu/rwtss/rwtssTook1Ch97.txt'),
(110, '2024-04-21', 2, 'Capítulo 98',  'Dar en el blanco [Parte 2]',                                 'assets/book/eu/rwtss/rwtssTook1Ch98.txt'),
(111, '2024-04-21', 2, 'Capítulo 99',  'Hace tiempo que no nos vemos, Maestro',                      'assets/book/eu/rwtss/rwtssTook1Ch99.txt'),
(112, '2024-04-21', 2, 'Capítulo 100', 'M-Maestro, es mi primera vez',                               'assets/book/eu/rwtss/rwtssTook1Ch100.txt'),
(113, '2024-04-21', 2, 'Capítulo 101', 'La ignorancia es una bendición [Parte 1]',                   'assets/book/eu/rwtss/rwtssTook1Ch101.txt'),
(114, '2024-04-21', 2, 'Capítulo 102', 'La ignorancia es una bendición [Parte 2]',                   'assets/book/eu/rwtss/rwtssTook1Ch102.txt'),
(115, '2024-04-21', 2, 'Capítulo 103', 'Maestro, te extraño',                                        'assets/book/eu/rwtss/rwtssTook1Ch103.txt'),
(116, '2024-04-21', 2, 'Capítulo 104', 'Entrenamiento del aura [Parte 1]',                           'assets/book/eu/rwtss/rwtssTook1Ch104.txt'),
(117, '2024-04-21', 2, 'Capítulo 105', 'Entrenamiento del aura [Parte 2]',                           'assets/book/eu/rwtss/rwtssTook1Ch105.txt'),
(118, '2024-04-21', 2, 'Capítulo 106', 'Entrenamiento del aura [Parte 3]',                           'assets/book/eu/rwtss/rwtssTook1Ch106.txt'),
(119, '2024-04-21', 2, 'Capítulo 107', 'Campana de Anthanasia',                                      'assets/book/eu/rwtss/rwtssTook1Ch107.txt'),
(120, '2024-04-21', 2, 'Capítulo 108', 'Los que residen en la oscuridad [Parte 1]',                  'assets/book/eu/rwtss/rwtssTook1Ch108.txt'),
(121, '2024-04-21', 2, 'Capítulo 109', 'Los que residen en la oscuridad [Parte 2]',                  'assets/book/eu/rwtss/rwtssTook1Ch109.txt'),
(122, '2024-04-21', 2, 'Capítulo 110', '¿Por qué es tan frágil la vida humana?',                    'assets/book/eu/rwtss/rwtssTook1Ch110.txt'),
(123, '2024-04-21', 2, 'Capítulo 111', 'El odio no puede expulsar al odio, sólo el amor puede hacerlo.', 'assets/book/eu/rwtss/rwtssTook1Ch111.txt'),
(124, '2024-04-21', 2, 'Capítulo 112', 'El paraíso final [Parte 1]',                                 'assets/book/eu/rwtss/rwtssTook1Ch112.txt'),
(125, '2024-04-21', 2, 'Capítulo 113', 'El paraíso final [Parte 2]',                                 'assets/book/eu/rwtss/rwtssTook1Ch113.txt'),
(126, '2024-04-21', 2, 'Capítulo 114', 'La elección depende de ti',                                  'assets/book/eu/rwtss/rwtssTook1Ch114.txt'),
(127, '2024-04-21', 2, 'Capítulo 115', 'Liberándose de los grilletes',                               'assets/book/eu/rwtss/rwtssTook1Ch115.txt'),
(128, '2024-04-21', 2, 'Capítulo 116', 'Amarte por siempre',                                         'assets/book/eu/rwtss/rwtssTook1Ch116.txt'),
(129, '2024-04-21', 2, 'Capítulo 117', 'Marcha hacia la capital',                                    'assets/book/eu/rwtss/rwtssTook1Ch117.txt'),
(130, '2024-04-21', 2, 'Capítulo 118', 'No deseo el dominio, pero no puedo dejar que los inocentes sufran', 'assets/book/eu/rwtss/rwtssTook1Ch118.txt');

-- Oskar - Took 1 (took_id=3)
INSERT INTO chapters (id, created_at, took_id, number, title, content) VALUES
(131, '2024-04-21', 3, 'Capítulo 0',      'Prologo',                      'assets/book/jp/oskar/oskarTook1Ch0.txt'),
(132, '2024-04-21', 3, 'Capítulo 1',      'Liam',                         'assets/book/jp/oskar/oskarTook1Ch1.txt'),
(133, '2024-04-21', 3, 'Capítulo 2',      'Maestro de la espada',         'assets/book/jp/oskar/oskarTook1Ch2.txt'),
(134, '2024-04-21', 3, 'Capítulo 3',      'El camino del destello',       'assets/book/jp/oskar/oskarTook1Ch3.txt'),
(135, '2024-04-21', 3, 'Capítulo 4',      'Liam a los treinta',           'assets/book/jp/oskar/oskarTook1Ch4.txt'),
(136, '2024-04-21', 3, 'Capítulo 5',      'Avid',                         'assets/book/jp/oskar/oskarTook1Ch5.txt'),
(137, '2024-04-21', 3, 'Capítulo 6',      'Trampa de miel',               'assets/book/jp/oskar/oskarTook1Ch6.txt'),
(138, '2024-04-21', 3, 'Capítulo 7',      'Comerciante malvado',          'assets/book/jp/oskar/oskarTook1Ch7.txt'),
(139, '2024-04-21', 3, 'Capítulo 8',      'Piratas del espacio',          'assets/book/jp/oskar/oskarTook1Ch8.txt'),
(140, '2024-04-21', 3, 'Capítulo 9',      'Primera batalla',              'assets/book/jp/oskar/oskarTook1Ch9.txt'),
(141, '2024-04-21', 3, 'Capítulo 10',     'Sucesor - Creador del cmino del destello', 'assets/book/jp/oskar/oskarTook1Ch10.txt'),
(142, '2024-04-21', 3, 'Capítulo 11',     'Tesoro',                       'assets/book/jp/oskar/oskarTook1Ch11.txt'),
(143, '2024-04-21', 3, 'Capítulo 12',     'La princesa caballero',        'assets/book/jp/oskar/oskarTook1Ch12.txt'),
(144, '2024-04-21', 3, 'Capítulo 13',     'Familia',                      'assets/book/jp/oskar/oskarTook1Ch13.txt'),
(145, '2024-04-21', 3, 'Capítulo 14',     'Gratitud',                     'assets/book/jp/oskar/oskarTook1Ch14.txt'),
(146, '2024-04-21', 3, 'Capítulo 15',     'Epílogo',                      'assets/book/jp/oskar/oskarTook1Ch15.txt'),
(147, '2024-04-21', 3, 'Historia adicional', 'El plan harem de Liam',     'assets/book/jp/oskar/oskarTook1Ch16.txt'),
(148, '2024-04-21', 3, 'Palabras del Autor', 'Palabras del Autor',       'assets/book/jp/oskar/oskarTook1Ch17.txt');

-- ADMIN profile (usuario creado manualmente en auth.users)
UPDATE profiles SET role = 'scan'
WHERE id = (SELECT id FROM auth.users WHERE email = 'admin@noveles.com');