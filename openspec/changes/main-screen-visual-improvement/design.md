# Design: main-screen-visual-improvement — Fase 1

## Technical Approach

Refactor puramente presentacional de `MainScreen`: se toman los widgets existentes (`carousel_appbar_sliver.dart`, `_buildContent`) y se les agregan dots + altura responsive, y se insertan 4 nuevos widgets puros (`SectionHeader`, `BookCardVertical`, `BookCardHorizontal`, `GenreChipStyled`) más 2 secciones contenedoras (`SectionNovedades`, `SectionPopulares`) en el `CustomScrollView`. Todo el ordenamiento es local (sort client-side sobre `listBook`). No se tocan BLoCs, repositorios ni casos de uso.

Flujo:

```
MainScreen (StatefulWidget)
  └─ _buildContent(listBook, listGenre)
       └─ CustomScrollView
            ├─ SliverAppBarHome (modificado: dots + responsive height)
            ├─ SectionNovedades     [nuevo]
            │    └─ BookCardVertical × N (sorted createdAt DESC)
            ├─ SectionPopulares     [nuevo]
            │    └─ BookCardHorizontal × N (sorted tookCount DESC)
            ├─ Géneros (existente, refactorizado con GenreChipStyled)
            └─ Loading indicator (preservado)
```

## Architecture Decisions

### Decision: Widgets en `lib/features/app/presentation/widgets/` (no shared)

| Opción | Tradeoff |
|--------|----------|
| **Elegido**: `lib/features/app/presentation/widgets/` | Los widgets son específicos de MainScreen (no reusados fuera de app feature). Co-located con `carousel_appbar_sliver.dart`. |
| `shared/presentation/widgets/` | Tendrían que importar `app/presentation` de todas formas. Separación prematura. |

### Decision: Carousel convertido a StatefulWidget

| Opción | Tradeoff |
|--------|----------|
| **Elegido**: StatefulWidget con `_carouselIndex` | Necesario para tracking del índice actual en los dots. Mínimo estado. |
| ValueNotifier externo | Overkill para un solo valor que solo usa el carrusel. |
| StatelessWidget con callback al padre | Rompe encapsulamiento — los dots son internos del carrusel. |

### Decision: Cover URL resuelta con `getIt<CoverUrlService>()` dentro de cada widget

| Opción | Tradeoff |
|--------|----------|
| **Elegido**: `getIt<CoverUrlService>()` inline | Patrón ya establecido en `carousel_appbar_sliver.dart`. No agregar acoplamiento nuevo. |
| Pasar `CoverUrlService` por constructor | Todos los widgets y MainScreen tendrían que recibirlo y re-pasarlo. Ruido innecesario. |
| Resolver en MainScreen y pasar URL string | MainScreen tendría que mapear cada book → coverUrl. Duplica lógica en cada sección. |

### Decision: Ordenamiento inline en `_MainScreenState` (métodos privados)

| Opción | Tradeoff |
|--------|----------|
| **Elegido**: `_sortedNovedades()` y `_sortedPopulares()` | Fácil de leer, testear y reemplazar cuando llegue backend (Fase 2). |
| Helper separado en `utils/` | Solo se usa acá. YAGNI. |

### Decision: SectionNovedades y SectionPopulares como widgets separados (no inline en MainScreen)

| Opción | Tradeoff |
|--------|----------|
| **Elegido**: Widgets separados `section_novedades.dart`, `section_populares.dart` | Testeables individualmente. MainScreen no crece. |
| Inline en `_buildContent` | _buildContent ya tiene 85 líneas. Agregar 60 más rompe SRP. |

### Decision: No SectionHeader con `VoidCallback? onViewAll` (usar `Widget? trailing`)

| Opción | Tradeoff |
|--------|----------|
| **Elegido**: `Widget? trailing` | Más flexible. Si Fase 2 necesita un botón "Ver todo", se pasa un `TextButton`. Si necesita otra cosa, funciona igual. |
| `VoidCallback? onViewAll` | Menos flexible. Habría que cambiarlo después. |

## Data Flow

```
lib/features/app/presentation/widgets/      ← new widgets
lib/features/app/presentation/screens/      ← MainScreen (modified)
lib/features/app/presentation/screens/      ← carousel_appbar_sliver.dart (modified)
```

```
BookBloc ──→ BookLoaded.books ──→ _buildContent(listBook, listGenre)
                                        │
                                        ├── listBook ──→ _sortedNovedades() ──→ SectionNovedades ──→ BookCardVertical
                                        │                                   (createdAt DESC, 6 max)
                                        ├── listBook ──→ _sortedPopulares() ──→ SectionPopulares ──→ BookCardHorizontal
                                        │                                   (tookCount DESC, 6 max)
                                        └── listGenre ──→ GenreChipStyled (inline, mismo que hoy)
                                                              (static map genre→icon)
```

No hay BLoCs nuevos. No hay data layer. Todo el flujo es de ida: MainScreen recibe datos de los BLoCs existentes y los distribuye por constructor a widgets hijos.

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `lib/features/app/presentation/widgets/carousel_appbar_sliver.dart` | **MODIFY** | Convertir a StatefulWidget, agregar `_carouselIndex`, dots indicadores, altura responsive (clamp 200-300px). |
| `lib/features/app/presentation/widgets/section_header.dart` | **CREATE** | StatelessWidget. Título + icon opcional + trailing opcional + padding configurable. |
| `lib/features/app/presentation/widgets/book_card_vertical.dart` | **CREATE** | StatelessWidget. Card vertical con portada (aspect ratio 3:4) + info. Para scroll horizontal en Novedades. |
| `lib/features/app/presentation/widgets/book_card_horizontal.dart` | **CREATE** | StatelessWidget. Card horizontal con portada 80px + info expandida. Para Populares. |
| `lib/features/app/presentation/widgets/section_novedades.dart` | **CREATE** | StatelessWidget. SectionHeader + ListView horizontal de BookCardVertical. Sort createdAt DESC. Empty → SizedBox.shrink(). |
| `lib/features/app/presentation/widgets/section_populares.dart` | **CREATE** | StatelessWidget. SectionHeader + Column de BookCardHorizontal. Sort tookCount DESC. Empty → SizedBox.shrink(). |
| `lib/features/app/presentation/widgets/genre_chip_styled.dart` | **CREATE** | StatelessWidget. Chip con ícono por género + `InkWell` + navegación. |
| `lib/features/app/presentation/screens/main_screen.dart` | **MODIFY** | Agregar secciones Novedades + Populares en `_buildContent`. Refactorizar sección de géneros a `GenreChipStyled`. Agregar `_sortedNovedades()` y `_sortedPopulares()`. |

## Interfaces / Contracts

### S1 — CarouselAppBarHome (modificado)

```dart
class SliverAppBarHome extends StatefulWidget {  // era StatelessWidget
  final List<BookWithRelations> listBook;
  final List<Widget> actions;
  final void Function(BookWithRelations book) onBookTap;
  // constructor igual
}

class _SliverAppBarHomeState extends State<SliverAppBarHome> {
  int _carouselIndex = 0;

  double _responsiveHeight(BuildContext context) {
    return (MediaQuery.of(context).size.height * 0.35)
        .clamp(200.0, 300.0);
  }

  // build: SliverAppBar(
  //   expandedHeight: _responsiveHeight(context),
  //   flexibleSpace: Stack([
  //     CarouselSlider(
  //       options: CarouselOptions(
  //         ..., onPageChanged: (i, _) => setState(() => _carouselIndex = i),
  //       ),
  //     ),
  //     Positioned(bottom: 8, left/right: 0, child: _CarouselDots),
  //   ]),
  // )
}
```

### S2 — SectionHeader

```dart
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsets? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
    this.padding,
  });

  // build: Padding(
  //   padding: padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //   child: Row([icon? + SizedBox(8), Text(title, ...), Spacer(), trailing?]),
  // )
}
```

### S3 — BookCardVertical

```dart
class BookCardVertical extends StatelessWidget {
  final BookWithRelations book;
  final VoidCallback onTap;
  final double? width;

  const BookCardVertical({
    super.key,
    required this.book,
    required this.onTap,
    this.width,
  });

  // build: SizedBox(
  //   width: width ?? 140,
  //   child: Card(
  //     clipBehavior: Clip.antiAlias,
  //     child: InkWell(
  //       onTap: onTap,
  //       child: Column([
  //         AspectRatio(aspectRatio: 3/4, child: CachedNetworkImage(cover)),
  //         Padding(all: 8, child: Column([Text(name, maxLines:2), Text(author, style: caption)])),
  //       ]),
  //     ),
  //   ),
  // )
}
```

Cover URL resolution: `getIt<CoverUrlService>()(book.cover)` — mismo patrón que carrusel.

### S4 — SectionNovedades

```dart
class SectionNovedades extends StatelessWidget {
  final List<BookWithRelations> books;
  final void Function(BookWithRelations) onBookTap;

  const SectionNovedades({
    super.key,
    required this.books,
    required this.onBookTap,
  });

  // build: books.isEmpty ? SizedBox.shrink() : Column([
  //   SectionHeader(title: 'Novedades', icon: Icons.new_releases),
  //   SizedBox(height: 220, child: ListView.builder(
  //     scrollDirection: Axis.horizontal,
  //     padding: EdgeInsets.symmetric(horizontal: 16),
  //     itemCount: books.length.clamp(0, 6),
  //     itemBuilder: (_, i) => Padding(
  //       right: 12,
  //       child: BookCardVertical(book: books[i], onTap: () => onBookTap(books[i])),
  //     ),
  //   )),
  // ])
}
```

Sort: `..sort((a, b) => b.createdAt.compareTo(a.createdAt))` aplicado por el caller (`_sortedNovedades`).

### S5 — BookCardHorizontal

```dart
class BookCardHorizontal extends StatelessWidget {
  final BookWithRelations book;
  final VoidCallback onTap;

  const BookCardHorizontal({
    super.key,
    required this.book,
    required this.onTap,
  });

  // build: Card(
  //   margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  //   clipBehavior: Clip.antiAlias,
  //   child: InkWell(
  //     onTap: onTap,
  //     child: SizedBox(height: 120, child: Row([
  //       SizedBox(width: 80, child: CachedNetworkImage(cover)),
  //       Expanded(Padding(all: 12, child: Column([
  //         Text(name, style: titleSmall, maxLines: 2),
  //         Text(author, style: bodySmall, maxLines: 1),
  //         Spacer(),
  //         Row([Icon(menu_book, 16), Text('${book.tookCount} tomos')]),
  //       ]))),
  //     ])),
  //   ),
  // )
}
```

### S6 — SectionPopulares

```dart
class SectionPopulares extends StatelessWidget {
  final List<BookWithRelations> books;
  final void Function(BookWithRelations) onBookTap;

  const SectionPopulares({
    super.key,
    required this.books,
    required this.onBookTap,
  });

  // build: books.isEmpty ? SizedBox.shrink() : Column([
  //   SectionHeader(title: 'Populares', icon: Icons.trending_up),
  //   ...books.take(6).map((book) =>
  //     BookCardHorizontal(book: book, onTap: () => onBookTap(book)),
  //   ),
  // ])
}
```

Sort: `..sort((a, b) { final c = b.tookCount.compareTo(a.tookCount); return c != 0 ? c : b.chapterCount.compareTo(a.chapterCount); })` aplicado por el caller (`_sortedPopulares`).

### S7 — GenreChipStyled

```dart
class GenreChipStyled extends StatelessWidget {
  final GenreEntity genre;
  final VoidCallback onTap;
  final IconData? icon;  // override opcional, default from _iconForGenre()

  const GenreChipStyled({
    super.key,
    required this.genre,
    required this.onTap,
    this.icon,
  });

  static IconData _iconForGenre(String name) {
    const map = <String, IconData>{
      'aventura': Icons.explore,
      'romance': Icons.favorite,
      'fantasía': Icons.auto_stories,
      'ciencia ficción': Icons.rocket_launch,
      'terror': Icons.dangerous,
      'misterio': Icons.search,
      'comedia': Icons.sentiment_satisfied,
      'drama': Icons.theater_comedy,
      'acción': Icons.flash_on,
      'histórico': Icons.history,
      'suspenso': Icons.psychology,
    };
    return map[name.toLowerCase()] ?? Icons.book;
  }

  // build: InkWell(
  //   onTap: onTap,
  //   child: Container(
  //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: theme.colorScheme.surfaceContainerLow,
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Row(mainAxisSize: MainAxisSize.min, children: [
  //       Icon(icon ?? _iconForGenre(genre.name), size: 18),
  //       SizedBox(width: 6),
  //       Text(genre.name),
  //     ]),
  //   ),
  // )
}
```

### M1 — MainScreen modificado

```dart
// en _MainScreenState:
List<BookWithRelations> _sortedNovedades(List<BookWithRelations> books) {
  final sorted = List<BookWithRelations>.from(books);
  sorted.sort((a, b) {
    final c = b.createdAt.compareTo(a.createdAt);
    return c != 0 ? c : b.id.compareTo(a.id);
  });
  return sorted.take(6).toList();
}

List<BookWithRelations> _sortedPopulares(List<BookWithRelations> books) {
  final sorted = List<BookWithRelations>.from(books);
  sorted.sort((a, b) {
    final c = b.tookCount.compareTo(a.tookCount);
    return c != 0 ? c : b.chapterCount.compareTo(a.chapterCount);
  });
  return sorted.take(6).toList();
}

// en _buildContent, dentro del CustomScrollView, después del carrusel:
// (antes de la sección de géneros)
SliverToBoxAdapter(
  child: SectionNovedades(
    books: _sortedNovedades(listBook),
    onBookTap: (book) => Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => BookScreen(book: book),
        transitionDuration: const Duration(seconds: 1),
      ),
    ),
  ),
),

SliverToBoxAdapter(
  child: SectionPopulares(
    books: _sortedPopulares(listBook),
    onBookTap: (book) => Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => BookScreen(book: book),
        transitionDuration: const Duration(seconds: 1),
      ),
    ),
  ),
),

// La sección de géneros existente se refactoriza a:
SliverToBoxAdapter(
  child: SectionHeader(title: 'Géneros', icon: Icons.category),
),
SliverToBoxAdapter(
  child: SizedBox(
    height: 60,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12),
      children: listGenre
          .map((g) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: GenreChipStyled(
                  genre: g,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GenreScreen(
                        genre: g.name,
                        books: listBook,
                        coverUrlService: getIt<CoverUrlService>(),
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    ),
  ),
),
```

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Widget | **SectionHeader** renders title + icon + trailing | `WidgetTester` — pump SectionHeader, find Text(title), find Icon(icon), find trailing widget |
| Widget | **SectionHeader** without icon/trailing | Verificar que no se renderizan si no se pasan |
| Widget | **BookCardVertical** renders cover + name + author | Mock BookWithRelations (o usar constructor real con datos mínimos), find Text(name), verify AspectRatio |
| Widget | **BookCardVertical** tap calls onTap | `tester.tap(find.byType(BookCardVertical))` + verify onTap was called |
| Widget | **BookCardHorizontal** renders cover + name + author + tookCount | find Text, verify Row con Icon(Icons.menu_book) + "N tomos" |
| Widget | **BookCardHorizontal** tap calls onTap | `tester.tap` + verify callback |
| Widget | **SectionNovedades** renders sorted books | Pump con lista mock, verify order by createdAt DESC |
| Widget | **SectionNovedades** empty = no render | Pump con `books: []`, verificar que no hay SectionHeader |
| Widget | **SectionPopulares** renders sorted books | Pump con lista mock, verify order by tookCount DESC |
| Widget | **SectionPopulares** empty = no render | Pump con `books: []`, verificar que no hay SectionHeader |
| Widget | **GenreChipStyled** renders icon + name | Pump, find Icon, find Text(genre.name) |
| Widget | **GenreChipStyled** tap navigates | `tester.tap`, verify onTap called |
| Widget | **GenreChipStyled** unknown genre → fallback icon | GenreEntity(name: 'Unknown'), verify Icon(Icons.book) |
| Widget | **SliverAppBarHome** dots render correct count | Pump con N books, find N dots widgets |
| Widget | **SliverAppBarHome** first dot active by default | Verify first dot uses primary color, wider |
| Widget | **SliverAppBarHome** responsive height clamp | Pump en 400px y 1000px viewports, verify height clamped to 200/300 |
| Integration | **MainScreen** renders all sections cuando hay datos | Pump con BookLoaded + GenreLoaded, scroll, verify Novedades + Populares + Géneros visible |
| Regression | **MainScreen** existing error/loading states preserved | Pump BookError, verify error text; pump BookLoading, verify CircularProgressIndicator |
| Regression | **MainScreen** existing empty state preserved | Pump BookLoaded(books: []), verify EmptyState |

**Test infrastructure**: usar `mocktail` (ya en dev_deps). Crear helpers de mock para `BookWithRelations` con valores mínimos (id, name, author, createdAt, tookCount, chapterCount, cover). No mockear `CoverUrlService` a menos que falle — `CachedNetworkImage` tiene `errorWidget` que maneja URLs vacías.

**Nuevos archivos de test**:
- `test/widgets/section_header_test.dart`
- `test/widgets/book_card_vertical_test.dart`
- `test/widgets/book_card_horizontal_test.dart`
- `test/widgets/section_novedades_test.dart`
- `test/widgets/section_populares_test.dart`
- `test/widgets/genre_chip_styled_test.dart`
- `test/widgets/carousel_dots_test.dart` (o incluir en test existente del carrusel)
- `test/widgets/main_screen_sections_test.dart` (integración)
- O modificar `test/widgets/admin_main_screen_test.dart` si corresponde

## Clean Architecture Verification

- **SectionHeader**: importa solo `flutter/material.dart`. Sin acoplamiento. ✅
- **BookCardVertical**: importa `BookWithRelations` (domain entity), `CachedNetworkImage`, `get_it`. Sin BLoC. ✅
- **BookCardHorizontal**: importa `BookWithRelations`, `CachedNetworkImage`, `get_it`. Sin BLoC. ✅
- **SectionNovedades**: importa `SectionHeader`, `BookCardVertical`, `BookWithRelations`. Sin BLoC. ✅
- **SectionPopulares**: importa `SectionHeader`, `BookCardHorizontal`, `BookWithRelations`. Sin BLoC. ✅
- **GenreChipStyled**: importa `GenreEntity` (domain entity), Material. Sin BLoC. ✅
- **MainScreen**: ya depende de `BookBloc`, `GenreBloc`, `AuthBloc`. No se agregan nuevos BLoCs. ✅
- Todos los widgets nuevos viven en `lib/features/app/presentation/widgets/`. ✅
- `CoverUrlService` se resuelve con `getIt` — patrón ya establecido en el codebase. ✅

## Migration / Rollout

No requiere migración. Rollback: `git revert` del commit de Fase 1. Los archivos nuevos se eliminan con `git clean -f`.

## Delivery Forecast

- **Archivos creados**: 6 (`section_header.dart`, `book_card_vertical.dart`, `book_card_horizontal.dart`, `section_novedades.dart`, `section_populares.dart`, `genre_chip_styled.dart`)
- **Archivos modificados**: 2 (`carousel_appbar_sliver.dart`, `main_screen.dart`)
- **Líneas estimadas**: ~320-380 total (nuevas + modificadas)
- **Chained PRs**: No necesario — dentro de budget 400 líneas
- **Riesgo**: Bajo — UI pura, sin BLoCs, sin data layer

## Open Questions

Ninguno. El diseño está completo para Fase 1.

## After Implementation

1. `flutter analyze` — 0 errors
2. `flutter test` — todos los tests existentes pasan + nuevos tests pasan
3. Verificar visualmente: carrusel con dots, altura responsive, secciones Novedades/Populares con datos reales
4. Verificar que `_onScroll` del infinite scroll sigue funcionando después del refactor de secciones
