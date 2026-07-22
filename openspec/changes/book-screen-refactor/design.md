# Design: book-screen-refactor

## Technical Approach

Reemplazar `NestedScrollView` + `TabBarView` + `TabController` por un `CustomScrollView` unificado con slivers. Extraer el contenido de `DetailView` y `TookView` a dos nuevos widgets planos (`BookDetailContent`, `BookTookList`) que se insertan como sliver children. Eliminar 4 archivos muertos.

No cambia comportamiento observable. La navegación a `TookScreen` se mantiene idéntica.

## Architecture Decisions

### Decision: BookScreen sigue StatefulWidget (mínimo)

| Opción | Tradeoff |
|--------|----------|
| **Elegido**: StatefulWidget con initState solo para `TrackBookView` | Mínimo estado. El `Future.delayed` de 2s es un side effect que necesita mounted check. StatelessWidget forzaría `addPostFrameCallback` en build — antipatrón. |
| StatelessWidget puro | Side effect en build es incorrecto. No hay widget binding para programarlo. |

### Decision: BookTookList como widget plano envuelto en `SliverToBoxAdapter`

| Opción | Tradeoff |
|--------|----------|
| **Elegido**: `BookTookList` (StatelessWidget) + `SliverToBoxAdapter` | Testable. El widget no sabe de slivers. Fácil de mover a `SliverList.builder` si hay N tomos grande. |
| `SliverList.builder` inline | Más performante para listas largas, pero no extraíble para test. El viewport del `CustomScrollView` ya maneja scroll. |

Performance: el `TookView` original usaba `NeverScrollableScrollPhysics()` — los items igual se construían todos. No regresamos.

### Decision: Eliminar SafeArea anidado

`BookScreen` ya envuelve el `CustomScrollView` en un `SafeArea` externo. `DetailView` y `TookView` tenían `SafeArea` propio que se elimina en los nuevos widgets.

## Data Flow

```
BookScreen (BookWithRelations)
 │
 ├─ SliverAppBarBook (books — BookEntity)       ← sin cambios
 ├─ SliverToBoxAdapter
 │    └─ BookDetailContent(books)               ← nuevo
 │         ├─ Row: TitleWidget + FavoriteButton
 │         ├─ Text(description)
 │         ├─ CardInfoDetail × 3
 │         ├─ Wrap(generos)
 │         └─ [condicional] Fuente + enlace
 │
 └─ SliverToBoxAdapter
      └─ BookTookList(tooks, onTookTap)         ← nuevo
           └─ Card[ ListTile(number, title, trailing: "Capítulos" + count) ] × N
                └─ onTap → Navigator.push → TookScreen(tooks: took)
```

No hay BLoCs ni capas de datos — todo fluye por constructor desde `BookScreen`.

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `lib/features/books/presentation/screens/widgets/book_detail_content.dart` | **CREATE** | StatelessWidget. Contenido de DetailView sin SafeArea, sin scroll, sin StatefulWidget. |
| `lib/features/books/presentation/screens/widgets/book_took_list.dart` | **CREATE** | StatelessWidget. Lista de tomos con Card + ListTile. Callback `onTookTap`. |
| `lib/features/books/presentation/screens/book_screen.dart` | **MODIFY** | Eliminar TabController, ScrollController, isVisible, SingleTickerProviderStateMixin, SliverPersistentHeaderBook. Reemplazar body con CustomScrollView + slivers. Mantener StatefulWidget solo para TrackBookView. |
| `lib/features/books/presentation/views/detail/detail_view.dart` | **DELETE** | Contenido migrado a BookDetailContent. Solo BookScreen importaba. |
| `lib/features/tooks/presentation/views/took_view.dart` | **DELETE** | Contenido migrado a BookTookList. Solo BookScreen importaba. |
| `lib/features/books/presentation/screens/widgets/sliver_persistent_header_book.dart` | **DELETE** | Sin tabs, sobra. Solo BookScreen lo usaba. |
| `lib/core/presentation/delegates/sliver_app_bar_delegate.dart` | **DELETE** | Único cliente era SliverPersistentHeaderBook (verificado con grep). |

## Interfaces / Contracts

### BookDetailContent

```dart
class BookDetailContent extends StatelessWidget {
  const BookDetailContent({super.key, required this.books});
  final BookWithRelations books;
  // build: Column sin scroll, sin SafeArea
}
```

### BookTookList

```dart
class BookTookList extends StatelessWidget {
  const BookTookList({
    super.key,
    required this.tooks,
    required this.onTookTap,
  });
  final List<TookEntity> tooks;
  final void Function(TookEntity took) onTookTap;
  // build: Column con Cards, sin scroll, sin SafeArea
}
```

### BookScreen (modified)

```dart
class BookScreen extends StatefulWidget { ... }  // se mantiene
class _BookScreenState extends State<BookScreen> {
  // NO SingleTickerProviderStateMixin
  // NO TabController, ScrollController, isVisible

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        GetIt.instance<TrackBookView>()(widget.book.id);
      }
    });
  }

  // NO dispose (no hay controllers)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBarBook(books: widget.book),   // igual
            const SliverToBoxAdapter(
              child: BookDetailContent(books: widget.book),
            ),
            SliverToBoxAdapter(
              child: BookTookList(
                tooks: widget.book.listTook,
                onTookTap: (took) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TookScreen(tooks: took),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Widget | `BookDetailContent` renders description, cards, genres | `WidgetTester` — pump con BookWithRelations mock, find Text/CardInfoDetail |
| Widget | `BookTookList` renders tooks and tap handler | `WidgetTester` — pump con List<TookEntity>, tap item, verify onTookTap called |
| Widget | `BookScreen` scrolls and renders all sections | `WidgetTester` — pump con BookWithRelations, scroll, verify both sections visible |

**Existing tests**: no hay tests para `BookScreen`, `DetailView`, ni `TookView` (verificado con glob). Riesgo cero de regresión.

## Clean Architecture Verification

- `BookDetailContent` importa: `BookWithRelations` (domain entity), `CardInfoDetail` (widget), `TitleWidget` (widget), `FavoriteButton` (widget). **OK** — solo depende de domain y presentación.
- `BookTookList` importa: `TookEntity` (domain entity), widgets de Material. **OK**.
- `BookScreen` importa: `BookWithRelations`, `TookScreen`, `TrackBookView` (domain use case). **OK** — la dependencia a `GetIt` para `TrackBookView` es aceptable (inyección de dependencia).
- Los archivos eliminados no tenían dependencias de data layer. **OK**.

## Delivery Forecast

- **Líneas**: ~4 new files + 1 modified ≈ 250-350 líneas total (dentro del budget de 400)
- **Chained PRs**: No necesario
- **Riesgo**: Bajo — refactor puramente UI, sin BLoCs, sin data layer

## Open Questions

Ninguno. El diseño está completo.

## After Implementation

1. `flutter test` — pasa sin regresiones
2. Verificar scroll suave de SliverAppBar hasta el último tomo
3. Verificar que el enlace "Abrir enlace" aún funciona (url_launcher)
4. Verificar que FavoriteButton mantiene estado (es StatefulWidget interno, no afectado)
5. Verificar grep de imports: `DetailView`, `TookView`, `SliverPersistentHeaderBook`, `SliverAppBarDelegate` — deben dar 0 hits en `lib/`
