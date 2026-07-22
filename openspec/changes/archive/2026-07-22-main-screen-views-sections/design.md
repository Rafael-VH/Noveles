# Design: Main Screen Views Sections

## Technical Approach

3 ejes independientes pero relacionados: (1) secciones RecentViews/PopularViews con book_views + RPC functions, (2) tracking de capítulos leídos con tabla `chapter_reads`, (3) coloración en TookScreen según estado de lectura. Cada sección de vistas usa RPC → IDs → follow-up `.select()` con JOINs completos para reusar `BookModel`. Chapter reads usa queries directas a `chapter_reads` con RLS policy (cada user ve solo sus propios reads).

## Architecture Decisions

| Decision | Choice | Alternatives | Rationale |
|---|---|---|---|
| **Tracking de lectura** | `chapter_reads(user_id, chapter_id, read_at)` | Columnas en book_views | Separación de concerns: book_views = visitas, chapter_reads = progreso. PK compuesta evita duplicados naturalmente. |
| **RLS book_views** | SECURITY DEFINER functions | RLS policy directa | RLS no puede agregar COUNT(*) para most-viewed. SD functions explicitan el contrato de acceso. |
| **BLoC granularidad** | 2 BLoCs separados | Extender BookBloc | BookBloc ya maneja paginación + CRUD. Separados = testables, mockeables, independientes. |
| **Layout secciones** | Horizontal scroll (BookCardVertical) | Lista vertical | Consistencia visual con Novedades. Reusa widgets existentes. |
| **Chapter reads sin BLoC** | Query directa en TookScreen via use case + FutureBuilder | Bloc dedicado | Solo lectura al montar + escritura al salir. Un Bloc agregaría ceremony sin beneficio real. |
| **RPC return shape** | `SETOF book_ids` + follow-up select | RPC con joins completos | SQL simple. Reusa exactamente el `.select()` de getBooks(). Dos round-trips aceptables para carga inicial. |

## Data Flow

```
RecentViews:
  MainScreen.init → RecentViewsBloc(LoadRecentViews)
    → GetRecentViews(userId)
      → supabase.rpc('get_user_recent_views', {uid, max_results:6})
      ← [book_id, ...]
      → supabase.from('books').select('*, authors(*), ...').in('id', ids)
      ← List<BookWithRelations>
    → RecentViewsLoaded(books)

PopularViews: (idem, pero con get_most_viewed_books)

Continuar leyendo navigation:
  Card tap → buscar bookId → chapter_reads WHERE user_id=X AND chapter_id IN (
    SELECT id FROM chapters WHERE took_id IN (
      SELECT id FROM tooks WHERE book_id=Y
    )
  ) ORDER BY read_at DESC LIMIT 1
  → si existe → ChapterScreen(i: indexOf(chapter), chapters: allChapters)
  → si no existe → BookScreen(book)

TookScreen coloring:
  initState → GetReadChapterIds(tookId, userId)
    → chapter_reads WHERE user_id=X AND chapter_id IN (chapters ids)
    ← Set<int> readIds
  → ListTile title: Text(color: readIds.contains(ch.id) ? grey : white)

ChapterScreen mark as read:
  initState → MarkChapterAsRead(chapterId, userId)
    → INSERT INTO chapter_reads ON CONFLICT (user_id, chapter_id) DO NOTHING
```

## File Changes

| File | Action | Description |
|---|---|---|
| `supabase/migrations/YYYYMMDD_chapter_reads.sql` | Create | chapter_reads table + book_views RPC functions |
| `lib/features/books/domain/book_repository.dart` | Modify | +2 abstract methods |
| `lib/features/books/domain/get_recent_views.dart` | Create | Use case |
| `lib/features/books/domain/get_most_viewed_books.dart` | Create | Use case |
| `lib/features/books/data/book_repository_impl.dart` | Modify | +2 impl (RPC + follow-up) |
| `lib/features/chapters/domain/mark_chapter_as_read.dart` | Create | Use case |
| `lib/features/chapters/domain/get_read_chapter_ids.dart` | Create | Use case |
| `lib/features/chapters/data/chapter_repository_impl.dart` | Modify | +2 impl (chapter_reads queries) |
| `lib/features/books/presentation/bloc/recent_views_bloc.dart` | Create | BLoC |
| `lib/features/books/presentation/bloc/recent_views_event.dart` | Create | Event |
| `lib/features/books/presentation/bloc/recent_views_state.dart` | Create | States |
| `lib/features/books/presentation/bloc/popular_views_bloc.dart` | Create | BLoC |
| `lib/features/books/presentation/bloc/popular_views_event.dart` | Create | Event |
| `lib/features/books/presentation/bloc/popular_views_state.dart` | Create | States |
| `lib/features/app/presentation/widgets/section_recent_views.dart` | Create | Widget |
| `lib/features/app/presentation/widgets/section_mas_vistos.dart` | Create | Widget |
| `lib/features/tooks/presentation/screens/took_screen.dart` | Modify | Text color según readIds |
| `lib/core/di/injection_books.dart` | Modify | +2 use cases + 2 BLoCs |
| `lib/features/app/presentation/screens/main_screen.dart` | Modify | +BlocProviders + secciones |

## Interfaces / Contracts

```sql
-- Migration
CREATE TABLE chapter_reads (
  user_id UUID NOT NULL REFERENCES auth.users(id),
  chapter_id INTEGER NOT NULL REFERENCES chapters(id),
  read_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, chapter_id)
);

-- RPCs (SECURITY DEFINER, STABLE, RETURNS TABLE(book_id BIGINT))
-- get_user_recent_views(uid UUID, max_results INT DEFAULT 6)
-- get_most_viewed_books(max_results INT DEFAULT 6)
```

```dart
// BookRepository (+2)
Future<Result<List<BookWithRelations>>> getRecentViews(String userId);
Future<Result<List<BookWithRelations>>> getMostViewedBooks();

// ChapterRepository (+2)
Future<Result<void>> markChapterAsRead(int chapterId, String userId);
Future<Result<Set<int>>> getReadChapterIds(int tookId, String userId);

// BLoC events
class LoadRecentViews extends RecentViewsEvent { const LoadRecentViews(); }
class LoadPopularViews extends PopularViewsEvent { const LoadPopularViews(); }

// Widget props (self-contained, no direct props — read bloc from context)
SectionRecentViews({super.key});
SectionMasVistos({super.key});
```

## Testing Strategy

| Layer | What | Approach |
|---|---|---|
| **Use case unit** | RecentViews, MostViewedBooks, MarkAsRead, GetReadIds | Mock repository, verify delegate |
| **Bloc** | RecentViewsBloc, PopularViewsBloc | blocTest, mock use case, verify state sequence |
| **Widget** | SectionRecentViews, SectionMasVistos | Inject mocked bloc state, verify cards / empty / error |
| **Widget** | TookScreen coloring | Inject readIds set, verify ListTile text color |
| **Integration** | TookScreen → Chapter mark → back to TookScreen | Verificar que el color cambia después de leer |

## Migration / Rollout

**Migration**: Single SQL file (CREATE TABLE + 2 RPC functions). Reversible: `DROP FUNCTION ...; DROP TABLE chapter_reads;`. Non-destructive.

**Rollback plan**: Remove BlocProviders + sections from MainScreen, revert TookScreen text color, revert ChapterRepository, drop table + functions.

## Open Questions

- TookScreen no tiene Bloc propio. Para obtener `readIds`, se puede usar un `FutureBuilder` con el use case directamente, o pasar el userId desde BookScreen. Se resuelve en tasks.
