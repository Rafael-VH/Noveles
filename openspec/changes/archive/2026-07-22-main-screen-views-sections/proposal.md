# Proposal: main-screen-views-sections

## Intent

Agregar dos nuevas secciones a MainScreen con datos reales del backend, usando la tabla existente `book_views`, más un sistema de tracking de capítulos leídos con indicador visual en TookScreen:

1. **Continuar leyendo** — Muestra los últimos libros que el usuario autenticado visitó, con navegación directa al último capítulo leído.
2. **Más vistos** — Muestra los libros más vistos globalmente (agregación de `book_views`).
3. **Tracking de lectura** — Tabla `chapter_reads` para marcar capítulos como leídos y colorear el texto en TookScreen (blanco = no leído, gris = leído).

## Scope

### In Scope
- Migración DB: nueva tabla `chapter_reads(user_id, chapter_id, read_at)`
- Migración DB / RPC: funciones SECURITY DEFINER para queries de `book_views`
- 2 nuevos métodos en `BookRepository` (interfaz + implementación)
- 2 nuevos use cases: `GetRecentViews`, `GetMostViewedBooks`
- 2 nuevos BLoCs: `RecentViewsBloc`, `PopularViewsBloc`
- 2 nuevos section widgets: `SectionRecentViews`, `SectionMasVistos`
- Nuevo use case `MarkChapterAsRead` + repository method para `chapter_reads`
- Modificar `TookScreen` para colorear títulos según lectura (gris/white)
- Modificar `ChapterScreen` para marcar capítulo como leído al abrirlo
- Integración en `MainScreen` (BlocProviders + secciones en CustomScrollView)
- Tests completos (unit + widget)

### Out of Scope
- Fase 3 (Tus favoritos con FavoriteBloc) — será otro cambio
- Sincronización de progreso de lectura entre dispositivos
- Animaciones de transición entre estados de lectura

## Approach

### Database Migration
```sql
CREATE TABLE IF NOT EXISTS chapter_reads (
  user_id UUID NOT NULL REFERENCES auth.users(id),
  chapter_id INTEGER NOT NULL REFERENCES chapters(id),
  read_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, chapter_id)
);
```

### SECURITY DEFINER Functions
Crear dos funciones en Supabase para bypassear RLS en `book_views`:
- `get_user_recent_views(uid uuid, max_results int)` — returns book IDs del user
- `get_most_viewed_books(max_results int)` — returns book IDs agregados

### Repository
Extender `BookRepository` con:
```dart
Future<Result<List<BookWithRelations>>> getRecentViews(String userId);
Future<Result<List<BookWithRelations>>> getMostViewedBooks();
```
Implementación: `_supabase.client.rpc(...)` + follow-up `.select('*, authors(*), ...')` con los IDs.

Agregar a `ChapterRepository` (o nuevo repo):
```dart
Future<Result<void>> markChapterAsRead(int chapterId, String userId);
Future<Result<Set<int>>> getReadChapterIds(int tookId, String userId);
```

### BLoCs
Dos BLoCs independientes:
- **RecentViewsBloc**: `LoadRecentViews` event → consulta `getRecentViews(userId)`. Sin auth → `RecentViewsEmpty`.
- **PopularViewsBloc**: `LoadPopularViews` event → consulta `getMostViewedBooks()`.

### Navigation
- **Continuar leyendo**: Card tap → busca el último `chapter_reads` de ese libro → navega a `ChapterScreen` con ese capítulo. Si no hay chapter_reads → navega a `BookScreen`.
- **Más vistos**: Card tap → navega a `BookScreen` (mismo que Novedades/Populares).

### Chapter Read Status
- **TookScreen**: al cargar la lista de capítulos, consulta `getReadChapterIds(tookId, userId)`. Aplica color: `Colors.white` si no leído, `Colors.grey` si leído.
- **ChapterScreen**: al inicializar (o al salir), llama a `markChapterAsRead(chapterId, userId)`.
- BD: `chapter_reads` con PK `(user_id, chapter_id)` — upsert para evitar duplicados.

### Widgets
- Reusar `SectionHeader` + `BookCardVertical` para ambas secciones (scroll horizontal)
- `SectionRecentViews` y `SectionMasVistos`: wrappers BlocConsumer, mismo patrón que `SectionNovedades`

### Auth
- RecentViews y chapter_reads usan `currentUser.id`. Sin auth → secciones no se renderizan.

## File Changes

### New Files (12-14)
```
lib/features/books/domain/get_recent_views.dart
lib/features/books/domain/get_most_viewed_books.dart
lib/features/books/presentation/bloc/recent_views_bloc.dart
lib/features/books/presentation/bloc/recent_views_event.dart
lib/features/books/presentation/bloc/recent_views_state.dart
lib/features/books/presentation/bloc/popular_views_bloc.dart
lib/features/books/presentation/bloc/popular_views_event.dart
lib/features/books/presentation/bloc/popular_views_state.dart
lib/features/app/presentation/widgets/section_recent_views.dart
lib/features/app/presentation/widgets/section_mas_vistos.dart
lib/features/chapters/domain/mark_chapter_as_read.dart     (nuevo use case)
lib/features/chapters/domain/get_read_chapter_ids.dart     (nuevo use case)
supabase/migrations/YYYYMMDD_chapter_reads.sql
+ archivos de test
```

### Modified Files (6)
| File | Change |
|------|--------|
| `lib/features/books/domain/book_repository.dart` | +2 métodos abstractos |
| `lib/features/books/data/book_repository_impl.dart` | +2 implementaciones (RPC + follow-up select) |
| `lib/features/chapters/data/chapter_repository_impl.dart` | +2 métodos: markAsRead, getReadChapterIds |
| `lib/core/di/injection_books.dart` | +2 use cases + 2 BLoCs |
| `lib/features/tooks/presentation/screens/took_screen.dart` | Color de texto según lectura |
| `lib/features/app/presentation/screens/main_screen.dart` | +BlocProviders + secciones |

## Phases

| Phase | Contenido | Dependencias |
|-------|-----------|-------------|
| **P1** | Migración DB (chapter_reads) + RPC functions + Repository + Use cases | Ninguna |
| **P2** | BLoCs (RecentViewsBloc + PopularViewsBloc) | P1 |
| **P3** | Widgets secciones + Chapter read tracking (TookScreen + ChapterScreen) | P1 (parcial) |
| **P4** | Integración MainScreen + Tests | P1+P2+P3 |

## Risks

1. **RLS**: Las funciones SECURITY DEFINER deben crearse antes de cualquier query.
2. **chapter_reads sin auth**: Si el user no está autenticado, no se marca lectura ni se colorean capítulos.
3. **TookScreen actualmente no tiene Bloc/estado propio**: Habrá que decidir si inyectar el userId y hacer la query directa, o agregar un bloc mínimo.

## Decisiones Tomadas

| Decisión | Opción Elegida | Alternativa |
|----------|---------------|-------------|
| Tracking de lectura | Nueva tabla `chapter_reads` | Columnas en `book_views` (descartado) |
| RLS book_views | SECURITY DEFINER functions | Policy directa |
| BLoCs vistas | Separados (2 RecentViewsBloc + PopularViewsBloc) | BookBloc extendido |
| Widget de card | BookCardVertical (scroll horizontal) | BookCardHorizontal |
| Capítulo leído vía | ChapterRepository | Nuevo repo separado |
| Navigation "Continuar leyendo" | Último chapter_reads del libro | last_chapter_id en book_views (descartado) |
| Orden MainScreen | Carrusel → Cont. leyendo → Novedades → Más vistos → Populares → Géneros | Orden original |
