# Plan de Integración Supabase + NovelEs

> Proyecto: `xozqqjcuuesxcqwhillr` (NovelEs)
> URL: https://xozqqjcuuesxcqwhillr.supabase.co
> CLI: v2.95.4

---

## FASE 0: Crear migración inicial con CLI

```bash
supabase migration new initial_schema
```

Esto crea `supabase/migrations/<timestamp>_initial_schema.sql`.

Luego pegar el schema de la FASE 1 en ese archivo.

---

## FASE 1: Schema SQL (migración)

Agregar a `supabase/migrations/<timestamp>_initial_schema.sql`:

```sql
CREATE TABLE genres (
  id          INT PRIMARY KEY,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  name        TEXT NOT NULL,
  description TEXT DEFAULT ''
);

CREATE TABLE books (
  id          SERIAL PRIMARY KEY,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  cover       TEXT NOT NULL,
  name        TEXT NOT NULL,
  short       TEXT DEFAULT '',
  alternative TEXT DEFAULT '',
  description TEXT DEFAULT '',
  author      TEXT DEFAULT '',
  country     TEXT DEFAULT '',
  state       TEXT DEFAULT '',
  type        TEXT DEFAULT '',
  release     TEXT DEFAULT '',
  took        TEXT DEFAULT '',
  chapter     TEXT DEFAULT '',
  source      TEXT DEFAULT '',
  link        TEXT DEFAULT '',
  is_favorite BOOLEAN DEFAULT FALSE
);

CREATE TABLE books_genres (
  book_id  INT REFERENCES books(id) ON DELETE CASCADE,
  genre_id INT REFERENCES genres(id) ON DELETE CASCADE,
  PRIMARY KEY (book_id, genre_id)
);

CREATE TABLE tooks (
  id         SERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  book_id    INT REFERENCES books(id) ON DELETE CASCADE,
  cover      TEXT DEFAULT '',
  number     TEXT DEFAULT '',
  title      TEXT DEFAULT '',
  content    TEXT DEFAULT ''
);

CREATE TABLE chapters (
  id         SERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  took_id    INT REFERENCES tooks(id) ON DELETE CASCADE,
  number     TEXT DEFAULT '',
  title      TEXT DEFAULT '',
  content    TEXT DEFAULT ''
);
```

Aplicar migración:

```bash
supabase db push
```

---

## FASE 2: Dependencias Flutter

Agregar a `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.10.0
```

```bash
flutter pub get
```

---

## FASE 3: Inicializar Supabase en la App

**Modificar `lib/main.dart`**:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xozqqjcuuesxcqwhillr.supabase.co',
    anonKey: 'sb_publishable_4KI-2PHTvKTReCqx2xbU2A_8TgtzItJ',
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  setupDependencies();
  runApp(const App());
}
```

---

## FASE 4: Seed de datos

Crear `supabase/seed.sql` con los datos de:

- `GenreLocalDataSource.allGenre` (20 géneros)
- `BookLocalDataSource.allBook` (7 libros activos)
- Relaciones `books_genres`
- Tomos y capítulos de cada libro

```bash
supabase db reset  # Aplica migrations + seed local
supabase db push   # Sube migrations a prod
```

---

## FASE 5: Reimplementar Repositorios

**5.1 `lib/features/data/repositories/book_repository_impl.dart`** — usar `Supabase.instance.client`
**5.2** Ídem para Genre, Took, Chapter
**5.3** Actualizar `lib/core/di/injection.dart` para inyectar repositorios reales

---

## FASE 6: Refactor UI para usar BLoC

**6.1** `MainPage` — dejar de usar `BookLocalDataSource.allBook` directo, usar `BlocBuilder<BookBloc>`
**6.2** Pasar `BookEntity` en vez de `BookLocalModel` a `BookScreen`/`BookPage`
**6.3** Actualizar `GenreScreen` para filtrar desde BLoC
**6.4** `TookView`, `TookPage`, `ChapterPage` — usar `BookEntity`/`TookEntity`

---

## FASE 7: RLS

Desde el SQL Editor o una nueva migración:

```sql
ALTER TABLE genres ENABLE ROW LEVEL SECURITY;
ALTER TABLE books ENABLE ROW LEVEL SECURITY;
ALTER TABLE books_genres ENABLE ROW LEVEL SECURITY;
ALTER TABLE tooks ENABLE ROW LEVEL SECURITY;
ALTER TABLE chapters ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lectura pública" ON genres FOR SELECT USING (true);
CREATE POLICY "Lectura pública" ON books FOR SELECT USING (true);
CREATE POLICY "Lectura pública" ON books_genres FOR SELECT USING (true);
CREATE POLICY "Lectura pública" ON tooks FOR SELECT USING (true);
CREATE POLICY "Lectura pública" ON chapters FOR SELECT USING (true);
```

---

## FASE 8: Limpieza

Eliminar archivos locales que ya no se usan:

| Archivo | Motivo |
|---------|--------|
| `lib/features/data/local/` (casi todo) | Datos ahora en Supabase |
| `assets/book/` (archivos .txt de capítulos) | Contenido en tabla `chapters` |
| `lib/features/data/local/string/` | Ya no necesario |

> Las imágenes de portada (`assets/cover/*.png`) se **quedan como assets locales**.
> Solo migras la metadata a Supabase.

---

## Resumen ejecución

```bash
# 1. Crear migración
supabase migration new initial_schema

# 2. Pegar schema SQL en el archivo creado

# 3. Subir schema
supabase db push

# 4. Agregar dependencia Flutter + flutter pub get

# 5. Modificar main.dart con init de Supabase

# 6. Crear seed.sql con datos actuales
# 7. Reimplementar repositorios (4 archivos)
# 8. Refactor UI para usar BLoC (10+ archivos)
# 9. Agregar RLS
# 10. Limpiar código local antiguo
```

¿Por qué fase quieres empezar?
