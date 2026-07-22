# Proposal: main-screen-visual-improvement

## Intent

Modernizar `MainScreen` con secciones visuales dinámicas (Novedades, Populares, Continuar leyendo, Favoritos) en 3 fases progresivas. Hoy la pantalla tiene solo carrusel + chips de géneros — no hay descubrimiento ni personalización.

## Scope

### In Scope

- **Fase 1** (UI pura): Carrusel con dots indicadores, secciones Novedades + Populares (sort desde `listBook` existente), géneros con íconos/colores, widgets `SectionHeader`, `BookCardHorizontal`, `BookCardVertical`, `GenreChipStyled`
- **Fase 2** (backend): Use cases `GetRecentViews` + `GetMostViewedBooks`, endpoint en repository, secciones Continuar leyendo y Más vistos
- **Fase 3** (personalización): Sección Tus favoritos cruzando `FavoriteBloc` + `listBook`, widgets de recomendación

### Out of Scope

- Backend search / FTS — no tocar
- `BookDetailContent` o `BookTookList` — pertenecen a `book-screen-refactor`
- `GenreEntity` con campos `icon`/`color` — se usa mapeo estático en Fase 1, postergado a otra change
- Scroll hacia arriba para refrescar (pull-to-refresh) — deferred
- Splash / onboarding / empty states de secciones individuales

## Capabilities

### New Capabilities

- `recent-book-views`: Recuperar vistas recientes por usuario (Fase 2)
- `most-viewed-books`: Ranking global de libros por count de vistas (Fase 2)

### Modified Capabilities

None — cambio de presentación, no de comportamiento de specs existentes.

## Approach

```
MainScreen (CustomScrollView)
  ├─ SliverAppBarHome mejorado (dots, altura responsive)
  ├─ SliverToBoxAdapter → SectionHeader("Novedades")
  ├─ SliverToBoxAdapter → BookCardHorizontal (4-6 items, horizontal)
  ├─ SliverToBoxAdapter → SectionHeader("Populares")
  ├─ SliverToBoxAdapter → BookCardVertical (grid-like, 4 items)
  ├─ SliverToBoxAdapter → SectionHeader("Géneros")
  ├─ SliverToBoxAdapter → GenreChipStyled (horizontal list)
  ├─ [Fase 2] Continuar leyendo / Más vistos
  ├─ [Fase 3] Tus favoritos
  └─ Loading indicator (infinite scroll footer)
```

**Fase 1**: `listBook` se ordena con `sorted()` para Novedades (`createdAt` DESC) y Populares (`tookCount` DESC). Sin BLoCs nuevos. Widgets puros.

**Fase 2**: `GetRecentViews(userId)` → `BookRepository.getRecentViews(userId)` → query `book_views WHERE user_id = ? ORDER BY viewed_at DESC`. `GetMostViewedBooks()` → query `book_views` con `GROUP BY book_id ORDER BY count(*) DESC`.

**Fase 3**: `FavoriteBloc` ya existe. Se inyecta en `MainScreen` y se cruzan `favorite.bookId` con `listBook` para mostrar cards. Si un favorito no está en `listBook`, no aparece (alcance limitado).

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `main_screen.dart` | Modified | Agregar secciones, providers, estado de fases |
| `carousel_appbar_sliver.dart` | Modified | Dots indicadores, altura responsive |
| `core/presentation/widgets/section_header.dart` | **New** | Título + "Ver todo" opcional |
| `shared/presentation/widgets/book_card_horizontal.dart` | **New** | Card horizontal portada + info |
| `shared/presentation/widgets/book_card_vertical.dart` | **New** | Card vertical compacta |
| `shared/presentation/widgets/genre_chip_styled.dart` | **New** | Chip con ícono + color |
| `shared/presentation/widgets/carousel_with_dots.dart` | **New** | Carrusel + dots (wrapper refactor) |
| `books/domain/book_repository.dart` | Modified | +getRecentViews, +getMostViewed (Fase 2) |
| `books/data/book_repository_impl.dart` | Modified | Implementar nuevos métodos (Fase 2) |
| `books/domain/get_recent_views.dart` | **New** | Use case (Fase 2) |
| `books/domain/get_most_viewed_books.dart` | **New** | Use case (Fase 2) |
| `di/injection.dart` | Modified | Registrar nuevos use cases (Fase 2) |
| `favorites/presentation/bloc/favorite_bloc.dart` | (usado) | Ya existe, se inyecta en MainScreen (Fase 3) |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| `listBook` no contiene los libros más recientes/populares si la paginación los trajo en orden `id` ASC | Medium | `listBook` completo (50 por página) permite sort local confiable para Novedades/Populares |
| Carrusel con dots necesita estado local (`_currentIndex`) | Low | StatefulWidget o ValueNotifier en wrapper |
| Géneros sin íconos/colores en DB se ven pobres | Medium | Static map `Map<String, IconData>` en widget, fácil de extender |
| Fase 2 requiere userId — puede ser null (no auth) | Low | Ocultar sección si userId es null |
| Cruzar favoritos con `listBook` puede no mostrar nada si los favs no están cargados | Medium | Aceptado — alcance limitado; mejora futura con endpoint dedicado |

## Rollback Plan

Por fase: revertir commit de la fase. Los archivos nuevos se borran con `git clean`, los modificados vuelven con `git checkout HEAD~1`.

- **Fase 1**: Revertir `main_screen.dart` + `carousel_appbar_sliver.dart`; borrar 5 nuevos widgets
- **Fase 2**: Revertir `BookRepository` + impl + use cases + DI
- **Fase 3**: Revertir `main_screen.dart` (provider + sección favoritos)

## Dependencies

- **Fase 1 → Fase 3**: Fase 1 debe estar completa (widgets base necesarios)
- **Fase 2 → Fase 3**: Independientes (pueden implementarse en paralelo)
- Ninguna externa; todos los datos existen o se agregan dentro del proyecto

## Success Criteria

- [ ] Fase 1: `MainScreen` muestra Novedades (sort createdAt DESC) + Populares (sort tookCount DESC) + géneros con estilo
- [ ] Fase 1: Carrusel tiene dots indicadores y altura responsive
- [ ] Fase 2: Sección "Continuar leyendo" muestra últimos 4 libros vistos por el usuario
- [ ] Fase 2: Sección "Más vistos" muestra ranking global
- [ ] Fase 3: Sección "Tus favoritos" muestra últimos 4 favoritos del usuario
- [ ] `flutter analyze` pasa sin errores en cada fase
- [ ] Todos los tests existentes siguen pasando
