# Tasks: main-screen-visual-improvement — Fase 1

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~720-780 (impl: ~350 + tests: ~370) |
| 400-line budget risk | Medium (impl solo: Low; +tests: High) |
| Chained PRs recommended | No — single PR con 5 commits |
| Suggested split | 1 PR, 5 commits ordenados por dependencia |
| Delivery strategy | auto-forecast |

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: size-exception
400-line budget risk: Medium

> **Nota**: El presupuesto de 400 líneas aplica a código de implementación (~350 líneas). Los tests (~370 líneas) son mecánicos y no deberían requerir revisión línea por línea. Review budget declarado "sin límite" por el usuario.

### Suggested Work Units

| Unit | Goal | Commits |
|------|------|---------|
| 1 | Carrusel + Dots + Altura responsive | 1 commit |
| 2 | SectionHeader + BookCardVertical + BookCardHorizontal | 2 commits |
| 3 | GenreChipStyled + SectionNovedades + SectionPopulares | 1 commit |
| 4 | MainScreen integration | 1 commit |
| 5 | Tests completos | 1 commit |

---

## Phase 1: Widgets Base (Foundation)

### T1 — Carrusel mejorado

- [x] **Descripción**: Convertir `SliverAppBarHome` de StatelessWidget a StatefulWidget. Agregar `_carouselIndex`, altura responsive con `clamp(200.0, 300.0)`, dots indicadores en un `Positioned(bottom: 8)` dentro de `Stack`. Dot activo: primary color 24×8, inactivo: gray 8×8. Preservar portada, gradiente, nombre, autor, labels.
- **Archivos**: `lib/features/app/presentation/widgets/carousel_appbar_sliver.dart`
- **Dependencias**: ninguna
- **Estimación**: ~50 líneas (+47, -5)
- **TDD**:
  - [x] Test: carrusel renderiza N dots cuando hay N books
  - [x] Test: primer dot activo por defecto (primary color, más ancho)
  - [x] Test: altura responsive clamp (200px min, 300px max)
  - [x] Test: carrusel vacío no crashea, 0 dots

### T2 — SectionHeader

- [x] **Descripción**: Crear `SectionHeader` StatelessWidget. Props: `required String title`, `IconData? icon`, `Widget? trailing`, `EdgeInsets? padding`. Row con icono opcional (primary), título bold, Spacer, trailing opcional. Padding default `EdgeInsets.symmetric(horizontal: 16, vertical: 8)`.
- **Archivos**: `lib/features/app/presentation/widgets/section_header.dart` (CREATE)
- **Dependencias**: ninguna
- **Estimación**: ~50 líneas nuevas
- **TDD**:
  - [x] Test: renderiza title text
  - [x] Test: renderiza icon + title cuando se pasa icon
  - [x] Test: renderiza trailing cuando se pasa trailing
  - [x] Test: sin icon no renderiza Icon widget
  - [x] Test: sin trailing no renderiza trailing widget

### T3 — BookCardVertical

- [x] **Descripción**: Crear `BookCardVertical` StatelessWidget. Props: `required BookWithRelations book`, `required VoidCallback onTap`, `double? width` (default 140). Card con `AspectRatio(3:4)` para portada (CachedNetworkImage + getIt<CoverUrlService>), nombre (maxLines: 2, ellipsis), autor (bodySmall, onSurfaceVariant). Clip con `Clip.antiAlias`.
- **Archivos**: `lib/features/app/presentation/widgets/book_card_vertical.dart` (CREATE)
- **Dependencias**: ninguna
- **Estimación**: ~60 líneas nuevas
- **TDD**:
  - [x] Test: renderiza portada + nombre + autor
  - [x] Test: tap invoca onTap
  - [x] Test: nombre largo se trunca con ellipsis (2 líneas)

### T5 — BookCardHorizontal

- [x] **Descripción**: Crear `BookCardHorizontal` StatelessWidget. Props: `required BookWithRelations book`, `required VoidCallback onTap`. Card con Row: portada 80px (CachedNetworkImage), Expanded info column con nombre (titleMedium, bold), autor (bodySmall), Spacer, Row con icono menu_book + "N tomos". Height 120px.
- **Archivos**: `lib/features/app/presentation/widgets/book_card_horizontal.dart` (CREATE)
- **Dependencias**: ninguna
- **Estimación**: ~65 líneas nuevas
- **TDD**:
  - [x] Test: renderiza portada + nombre + autor + tomos count
  - [x] Test: tap invoca onTap
  - [x] Test: card height es 120px

### T7 — GenreChipStyled

- [x] **Descripción**: Crear `GenreChipStyled` StatelessWidget. Props: `required GenreEntity genre`, `required VoidCallback onTap`, `IconData? icon` (override opcional). Static map género → IconData (aventura→explore, romance→favorite, fantasía→auto_stories, ciencia ficción→rocket_launch, terror→dangerous, misterio→search, comedia→sentiment_satisfied, drama→theater_comedy, acción→flash_on, histórico→history, suspenso→psychology). Fallback: Icons.book. Container redondeado (radius 20), color surfaceContainerLow, padding horizontal 16 vertical 8.
- **Archivos**: `lib/features/app/presentation/widgets/genre_chip_styled.dart` (CREATE)
- **Dependencias**: ninguna
- **Estimación**: ~70 líneas nuevas
- **TDD**:
  - [x] Test: renderiza icon + name para género conocido
  - [x] Test: tap invoca onTap
  - [x] Test: género desconocido → fallback Icons.book
  - [x] Test: icon override funciona

---

## Phase 2: Secciones Contenedoras

### T4 — SectionNovedades

- [x] **Descripción**: Crear `SectionNovedades` StatelessWidget. Props: `required List<BookWithRelations> books`, `required void Function(BookWithRelations) onBookTap`. SectionHeader("Novedades", icon: Icons.new_releases) + SizedBox(height: 250) con ListView horizontal de BookCardVertical. Padding horizontal 16, spacing 12. Empty → SizedBox.shrink(). El sorting se recibe ya ordenado desde MainScreen.
- **Archivos**: `lib/features/app/presentation/widgets/section_novedades.dart` (CREATE)
- **Dependencias**: T2 (SectionHeader), T3 (BookCardVertical)
- **Estimación**: ~40 líneas nuevas
- **TDD**:
  - [x] Test: renderiza header "Novedades" + hasta 6 BookCardVertical
  - [x] Test: empty → SizedBox.shrink() (no header)
  - [x] Test: tap en card invoca onBookTap

### T6 — SectionPopulares

- [x] **Descripción**: Crear `SectionPopulares` StatelessWidget. Props: `required List<BookWithRelations> books`, `required void Function(BookWithRelations) onBookTap`. SectionHeader("Populares", icon: Icons.trending_up) + Column con BookCardHorizontal items (take 6). Empty → SizedBox.shrink(). El sorting se recibe ya ordenado desde MainScreen.
- **Archivos**: `lib/features/app/presentation/widgets/section_populares.dart` (CREATE)
- **Dependencias**: T2 (SectionHeader), T5 (BookCardHorizontal)
- **Estimación**: ~35 líneas nuevas
- **TDD**:
  - [x] Test: renderiza header "Populares" + hasta 6 BookCardHorizontal
  - [x] Test: empty → SizedBox.shrink()
  - [x] Test: tap en card invoca onBookTap

---

## Phase 3: Integración

### T8 — MainScreen

- [x] **Descripción**: Modificar `_MainScreenState`. Agregar `_sortedNovedades()`: sort createdAt DESC, fallback id DESC, take 6. Agregar `_sortedPopulares()`: sort tookCount DESC, fallback chapterCount DESC, take 6. Insertar en CustomScrollView: SliverToBoxAdapter con SectionNovedades, SliverToBoxAdapter con SectionPopulares (entre carrusel y géneros). Refactorizar sección géneros existente: SectionHeader("Géneros", icon: Icons.category) + ListView horizontal con GenreChipStyled (reemplazar Chip actual). Agregar imports. Preservar loading indicator y empty state.
- **Archivos**: `lib/features/app/presentation/screens/main_screen.dart`
- **Dependencias**: T4 (SectionNovedades), T6 (SectionPopulares), T7 (GenreChipStyled)
- **Estimación**: ~56 líneas (+46, -10)
- **TDD**:
  - [x] Test: `_sortedNovedades` ordena por createdAt DESC, máximo 6
  - [x] Test: `_sortedPopulares` ordena por tookCount DESC, fallback chapterCount
  - [x] Test: CustomScrollView contiene Novedades + Populares + Géneros en orden
  - [x] Test: loading indicator preservado si hasMore
  - [x] Test: error states preservados (BookError, GenreError)
  - [x] Test: empty state preservado (listBook.isEmpty)

---

## Phase 4: Tests de Integración y Regresión

### T9 — Suite completa de tests

- [x] **Descripción**: Escribir tests para cada widget y la integración de MainScreen. 8 archivos de test nuevos en `test/widgets/`. Mock data helpers para `BookWithRelations` con valores mínimos. Usar `mocktail` (ya en dev_deps). Verificar todos los escenarios de spec.md.
- **Archivos** (CREATE):
  - `test/widgets/carousel_dots_test.dart`
  - `test/widgets/section_header_test.dart`
  - `test/widgets/book_card_vertical_test.dart`
  - `test/widgets/book_card_horizontal_test.dart`
  - `test/widgets/section_novedades_test.dart`
  - `test/widgets/section_populares_test.dart`
  - `test/widgets/genre_chip_styled_test.dart`
  - `test/widgets/main_screen_sections_test.dart` (integración)
  - `test/widgets/test_helpers.dart` (helper)
- **Dependencias**: T1-T8 implementados
- **Estimación**: ~370 líneas nuevas
- **TDD**: Todos los tests pasan. `flutter test` = 321/321 pass.
  - [x] Verificar escenarios de spec.md
  - [x] Verificar regresión: estados error/loading/empty existentes
  - [x] Verificar que `_onScroll` del infinite scroll sigue funcionando

---

## Resumen de Archivos

### Creados (7)
| Archivo | Task |
|---------|------|
| `lib/features/app/presentation/widgets/section_header.dart` | T2 |
| `lib/features/app/presentation/widgets/book_card_vertical.dart` | T3 |
| `lib/features/app/presentation/widgets/book_card_horizontal.dart` | T5 |
| `lib/features/app/presentation/widgets/genre_chip_styled.dart` | T7 |
| `lib/features/app/presentation/widgets/section_novedades.dart` | T4 |
| `lib/features/app/presentation/widgets/section_populares.dart` | T6 |
| `test/widgets/` — 8 archivos de test | T9 |

### Modificados (2)
| Archivo | Task | Cambio |
|---------|------|--------|
| `lib/features/app/presentation/widgets/carousel_appbar_sliver.dart` | T1 | StatefulWidget + dots + responsive height |
| `lib/features/app/presentation/screens/main_screen.dart` | T8 | Secciones nuevas + sorting + refactor géneros |

### Orden de Implementación Recomendado

```
T1 ──┐
T2 ──┤
T3 ──┤      T4 ──┐
     │            │
T5 ──┤      T6 ──┤
     │            │
T7 ──┴────────────┤
                  │
            T8 <──┘
                  │
            T9 <──┘ (verificación final)
```

**Ejecutar en orden**: T1 → T2 → T3 → T5 → T7 (paralelizables) → T4 → T6 → T8 → T9. Correr `flutter test` después de cada paso.
