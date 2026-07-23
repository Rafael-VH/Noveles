# Propuesta: books-visual-improvement

## Intención

Mejorar la presentación visual del módulo de Books para lectores regulares: rendimiento de scroll, consistencia tipográfica, elevaciones uniformes, y pulido general de componentes. Se adoptan las mejoras de Approach 2 (Performance + Cohesion Pass) identificadas en la exploración.

## Alcance

### In Scope
- SliverAppBarBook: reducir blur sigma 10→5, collapsed title dinámico con el nombre del libro, parallax/stretch, aspect ratio fijo en thumbnail, expandedHeight responsivo
- BookDetailContent: tipografía description a bodyLarge(16px), alineación FavoriteButton, agrupación visual por secciones, padding consistente
- CardInfoDetail: eliminar elevation hardcodeada 6.0 (usar theme), Spacer(flex:1)→SizedBox, fusionar cards repetitivas
- Genre chips: reemplazar Chip crudo por GenreChipStyled, eliminar onTap vacío, corregir elevation 8.0
- Book cards (vertical/horizontal): agregar sombra (elevation theme), padding de texto, press-state feedback (InkWell + scale)
- Carousel: typografía title de labelLarge→titleLarge, dot indicator sin overlap, indicador de página "1/N"
- Header unification: fusionar TitleWidget y SectionHeader en un solo widget
- Cohesión general: elevation/spacing consistente, agrupación de contenido en detalle

### Out of Scope
- Hero transition (cards → detail screen)
- Token system de elevation/spacing para toda la app
- Efecto Ken Burns en carousel
- Animaciones escalonadas de entrada
- Nuevos campos DB en UI

## Capacidades

> Refactor UI puro — no cambia comportamiento ni specs existentes.

### Nuevas Capacidades
None

### Capacidades Modificadas
None

## Enfoque

Abordaje por capas: (1) parches de rendimiento (blur sigma, elevaciones), (2) consistencia visual (chips, headers, tipografía), (3) pulido (parallax, press states, agrupación). Cada capa toca ~4-6 archivos y es revisable independientemente por PR.

## Áreas Afectadas

| Archivo | Cambio |
|---------|--------|
| `lib/features/books/.../sliver_app_bar_book.dart` | Blur sigma 10→5, parallax/stretch, collapsed title, aspect ratio, responsive height |
| `lib/features/books/.../book_detail_content.dart` | Typography 14→16, FavoriteButton alignment, section grouping, padding, genre chips swap |
| `lib/features/books/.../card_info_detail.dart` | Elevation→theme default, Spacer→SizedBox, merge cards |
| `lib/features/app/.../book_card_vertical.dart` | Elevation, text padding, press state |
| `lib/features/app/.../book_card_horizontal.dart` | Elevation, cover aspect ratio, press state |
| `lib/features/app/.../carousel_appbar_sliver.dart` | Typography labelLarge→titleLarge, dot position, page indicator |
| `lib/core/.../title_widget.dart` + `section_header.dart` | Unificar en un widget |
| `lib/core/utils/theme/light_theme.dart` | Default card elevation, chip elevation |
| `lib/core/utils/theme/dark_theme.dart` | Default card elevation, chip elevation |

## Riesgos

| Riesgo | Prob. | Mitigación |
|--------|-------|------------|
| Parallax causa jank en 60Hz | Media | Usar solo opacity+translateY, sin scale |
| Título colapsado muy largo | Baja | `overflow: ellipsis`, maxLines: 1 |
| Reducción de blur cambia look | Media | Testear sigma 3/5/7; elegir mínimo que luzca bien |
| Unificación de headers rompe callers | Media | Deprecar viejo, migrar solo callers de books |
| Dark mode regresión por elevación | Baja | Testear side-by-side antes de mergear |

## Rollback

Por PR individual: revertir commit del PR problemático. Si se aplican todos juntos (branch única): `git revert <merge-commit>` y re-aplicar por capas.

## Dependencias

Ninguna. Todos los cambios son UI pura sobre widgets existentes.

## Criterios de Éxito

- [ ] SliverAppBarBook: collapsed title muestra nombre del libro, blur funciona a sigma 5 sin jank visible
- [ ] Book cards: sombra visible, texto con padding adecuado, press feedback funcional
- [ ] Genre chips: visualmente idénticos a GenreChipStyled del main screen, sin onTap falso
- [ ] Carousel: título en titleLarge, dots no solapan contenido, indicador "1/N" presente
- [ ] CardInfoDetail: elevation igual al theme default, sin Spacer flex
- [ ] TitleWidget y SectionHeader unificados sin regresiones en callers migrados
- [ ] Sin cambios en comportamiento existente ni regresiones visuales en dark theme
