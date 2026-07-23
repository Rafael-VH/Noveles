# Tasks: books-visual-improvement

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~320 (9 files modified, 1 deprecated) |
| 400-line budget risk | Low |
| Chained PRs recommended | No |
| Suggested split | Single PR |
| Delivery strategy | exception-ok |
| Chain strategy | size-exception |

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: size-exception
400-line budget risk: Low

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | All 8 visual changes + tests | PR 1 | Single cohesive PR, < 400 lines, same module |

## Phase 1: Foundation

- [x] 1.1 Set `cardTheme.elevation: 2.0` en `lib/core/utils/theme/light_theme.dart` y `dark_theme.dart`
- [x] 1.2 Crear `InfoPair` data class en `lib/features/books/presentation/screens/widgets/card_info_detail.dart`
- [x] 1.3 Crear `SectionTitle` widget en `lib/features/app/presentation/widgets/section_title.dart` (renombrar archivo/clase, agregar `showAccent`)
- [x] 1.4 Marcar `TitleWidget` como `@Deprecated('Use SectionTitle with showAccent')` en `lib/core/presentation/widgets/title_widget.dart`

## Phase 2: Core Widgets

- [x] 2.1 Refactor `CardInfoDetail`: migrar API a `pairs: List<InfoPair>`, eliminar elevation hardcodeada, Spacer → SizedBox(8)
- [x] 2.2 Refactor `SliverAppBarBook` en `sliver_app_bar_book.dart`: blur sigma 10→5, `stretch: true` + parallax, collapsed title dinámico con `book.name`, thumbnail a `AspectRatio(3/4)`, `expandedHeight` responsivo clamp(280, 420)
- [x] 2.3 Refactor `BookDetailContent` en `book_detail_content.dart`: description a `bodyLarge`, agrupar secciones, chips a `GenreChipStyled`, `FavoriteButton` alineado derecha, padding 10→16
- [x] 2.4 Convertir `BookCardVertical` a `StatefulWidget` + `AnimatedScale(0.97)` en `onTapDown/Up/Cancel`, padding texto 2→4 (nota: padding revertido a 2 para evitar overflow en secciones existentes)
- [x] 2.5 Convertir `BookCardHorizontal` a `StatefulWidget` + `AnimatedScale(0.97)` en `onTapDown/Up/Cancel`
- [x] 2.6 Refactor `CarouselAppBarSliver` en `carousel_appbar_sliver.dart`: `labelLarge`→`titleLarge`, dots a `Positioned(bottom:0, left:16)`, agregar indicador "1/N"
- [x] 2.7 Migrar callers de `TitleWidget` a `SectionTitle` en `BookDetailContent` y limpiar imports

## Phase 3: Testing

- [x] 3.1 Actualizar test existente `test/widgets/book_detail_content_test.dart`: verificar `bodyLarge`, `GenreChipStyled`, `SectionTitle`, `FavoriteButton` alineado
- [x] 3.2 Actualizar test existente `test/widgets/book_card_vertical_test.dart`: verificar `AnimatedScale` y padding de texto
- [x] 3.3 Actualizar test existente `test/widgets/book_card_horizontal_test.dart`: verificar `AnimatedScale`
- [x] 3.4 Actualizar test existente `test/widgets/carousel_dots_test.dart`: verificar indicador "1/N" y tipografía `titleLarge`
- [x] 3.5 Agregar test para `CardInfoDetail` con `pairs`: verifica renderiza N pares
- [x] 3.6 Agregar test para `SliverAppBarBook`: collapsed title muestra `book.name`, blur overlay presente
- [x] 3.7 Agregar test para `SectionTitle` con `showAccent=true`: verifica `Container` de 6px ancho
- [x] 3.8 Smoke test visual: ambos temas sin regresiones, scroll parallax, press states
