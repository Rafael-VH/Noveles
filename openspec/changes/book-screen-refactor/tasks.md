# Tasks: book-screen-refactor

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~350 (+200 new / -300 deleted) |
| 400-line budget risk | Low |
| Chained PRs recommended | No |
| Decision needed before apply | No |

**Recommendation**: Single PR.

---

## Task Dependency Graph

```
T1 ──┐
     ├──► T3 ──► T4
T2 ──┘

T5 (tests) ← paralelo con T1/T2/T3, verify después de T4

```

---

## T1 — Crear `BookDetailContent`

**Descripción**: Crear widget `BookDetailContent` como StatelessWidget que encapsula la info del libro. Extraído de `DetailView`. Sin SafeArea, sin scroll.

**Props**: `BookWithRelations books`

**Contenido**:
- Row: `TitleWidget(text: 'Descripción')` + `FavoriteButton(bookId:, initialIsFavorite:)`
- Text con `books.description`
- `CardInfoDetail` × 3: (Publicado/Tipo), (País/Estado), (Tomos/Capítulos)
- `TitleWidget(text: 'Generos')` + Wrap de Chips con `books.listGenre`
- Sección condicional de Fuente (si `books.source.isNotEmpty || books.link.isNotEmpty`):
  - `TitleWidget(text: 'Fuente')`
  - `CardInfoDetail` con source/link
  - Enlace clickeable si `books.link.isNotEmpty` (url_launcher)

**Archivos**:
- Crear: `lib/features/books/presentation/screens/widgets/book_detail_content.dart`

**Dependencias**: ninguna

**Estimación**: ~90 líneas

**TDD**: Escribir widget test que verifique que:
- Renderiza descripción, tarjetas, géneros
- Muestra sección de fuente condicionalmente
- FavoriteButton está presente

---

## T2 — Crear `BookTookList`

**Descripción**: Crear widget `BookTookList` como StatelessWidget que encapsula la lista de tomos. Extraído de `TookView`. Sin SafeArea, sin scroll.

**Props**: `List<TookEntity> tooks`, `void Function(TookEntity) onTookTap`

**Contenido**:
- `Column` con los items, o directamente `ListView` con `NeverScrollableScrollPhysics` + `shrinkWrap: true` (porque va dentro de un sliver)
- Cada item: `Card` + `ListTile` con:
  - `title: item.number`
  - `subtitle: item.title`
  - Trailing: "Capítulos" + `item.listChapterIds.length`
- `onTap → onTookTap(item)`

**Archivos**:
- Crear: `lib/features/books/presentation/screens/widgets/book_took_list.dart`

**Dependencias**: ninguna

**Estimación**: ~60 líneas

**TDD**: Escribir widget test que verifique que:
- Renderiza la cantidad correcta de items
- Muestra número, título y capítulos
- Callback onTookTap se dispara al tap

---

## T3 — Modificar `BookScreen`

**Descripción**: Reemplazar `NestedScrollView` + `TabBarView` por `CustomScrollView` con slivers usando los nuevos widgets.

**Cambios**:
- Eliminar `SingleTickerProviderStateMixin`
- Eliminar `TabController _tabController`
- Eliminar `ScrollController _scrollController`
- Eliminar `bool isVisible`
- Eliminar listener de scroll en `initState`
- Simplificar `dispose` (solo queda `super.dispose()` o nada si es StatelessWidget)
- Mantener `Future.delayed(2s)` con `TrackBookView` en initState
- **Estructura nueva del body**:
```dart
Scaffold(
  body: CustomScrollView(
    slivers: [
      SliverAppBarBook(books: widget.book),
      SliverToBoxAdapter(
        child: BookDetailContent(books: widget.book),
      ),
      SliverToBoxAdapter(
        child: BookTookList(
          tooks: widget.book.listTook,
          onTookTap: (took) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => TookScreen(tooks: took),
            ),
          ),
        ),
      ),
    ],
  ),
)
```
- Actualizar imports: agregar `BookDetailContent`, `BookTookList`; eliminar imports de `DetailView`, `TookView`, `SliverPersistentHeaderBook`, `SliverAppBarDelegate`

**Archivos**:
- Modificar: `lib/features/books/presentation/screens/book_screen.dart`

**Dependencias**: T1, T2

**Estimación**: ~40 líneas modificadas

**TDD**: Verificar que el scroll funciona, que los dos widgets hijos se renderizan, que la navegación a TookScreen funciona.

---

## T4 — Eliminar archivos obsoletos

**Descripción**: Eliminar archivos que ya no se usan después de la refactorización.

**Archivos**:
- `lib/features/books/presentation/views/detail/detail_view.dart`
  - Verificar que ningún otro archivo lo importa (grep)
- `lib/features/tooks/presentation/views/took_view.dart`
  - Verificar que ningún otro archivo lo importa (grep)
- `lib/features/books/presentation/screens/widgets/sliver_persistent_header_book.dart`
  - Verificar que ningún otro archivo lo importa (grep)
- `lib/core/presentation/delegates/sliver_app_bar_delegate.dart`
  - Verificar que ningún otro archivo lo importa (grep)

**Archivos**:
- Eliminar: los 4 archivos listados

**Dependencias**: T3

**Estimación**: 4 eliminaciones, ~5 min

---

## T5 — Tests

**Descripción**: Escribir tests para los nuevos widgets y verificar que los tests existentes siguen pasando.

**Tests nuevos**:
- `test/widgets/book_detail_content_test.dart`
- `test/widgets/book_took_list_test.dart`

**Verificación**:
- `flutter test` pasa sin roturas
- Ningún test existente importa los archivos eliminados

**Archivos**:
- Crear: tests nuevos
- Ejecutar: suite completa

**Dependencias**: T1, T2, T3 (puede correr en paralelo con T1/T2/T3 para escribir tests, verify después de T4)

**Estimación**: ~80 líneas de tests

---

## Resumen

| Task | Acción | Archivos | Deps | Líneas |
|------|--------|----------|------|--------|
| T1 | Crear `BookDetailContent` | +1 | - | ~90 |
| T2 | Crear `BookTookList` | +1 | - | ~60 |
| T3 | Modificar `BookScreen` | ~1 | T1, T2 | ~40 |
| T4 | Eliminar obsoletos | -4 | T3 | -300 |
| T5 | Tests | +2 | T1-T3 | ~80 |
| **Total** | | **+3/-4 neto** | | **~+200 / ~-300** |
