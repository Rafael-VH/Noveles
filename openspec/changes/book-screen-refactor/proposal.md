# Proposal: book-screen-refactor

## Intent

Eliminar el crash `element._lifecycleState.active` causado por `NestedScrollView` + `TabBarView` que ya se fixeó con un workaround en el pasado. La raíz del problema es que `TabBarView` mantiene dos children vivos (Info y Took) con scroll physics `NeverScrollableScrollPhysics()` anidados dentro del scroll externo, generando conflictos de lifecycle. Además:

- `SingleTickerProviderStateMixin`, `ScrollController` y `isVisible` son código muerto que nadie usa
- `SliverPersistentHeaderBook` + `SliverAppBarDelegate` solo existen para darle pin al TabBar, innecesario sin tabs
- La arquitectura actual fuerza a `DetailView` y `TookView` a usar `NeverScrollableScrollPhysics()` — un code smell claro

## Scope

### In Scope

1. **CREAR** `BookDetailContent` — widget stateless con la info del libro (extraído de `DetailView`)
2. **CREAR** `BookTookList` — widget con `SliverList` + `SliverChildBuilderDelegate` para lazy render de tomos
3. **MODIFICAR** `BookScreen` — reemplazar `NestedScrollView` + `TabBarView` por `CustomScrollView` unificado con slivers
4. **ELIMINAR** `DetailView` — su contenido se migra a `BookDetailContent`
5. **ELIMINAR** `TookView` — su contenido se migra a `BookTookList`
6. **ELIMINAR** `SliverPersistentHeaderBook` — ya no hay tabs que pin
7. **ELIMINAR** `SliverAppBarDelegate` — único cliente era `SliverPersistentHeaderBook`

### Out of Scope

- `CardInfoDetail`, `TitleWidget`, `FavoriteButton`, `SliverAppBarBook` — se mantienen intactos
- `TookScreen` — no tocar, sigue siendo el destino de navegación
- `main_screen.dart` — no tocar
- BLoCs, use cases, repositories, entities — cambio 100% UI
- Tests existentes de otras features

## Capabilities

> Refactor puro de UI — no cambia comportamiento observable por el usuario ni introduce nuevas capacidades.

### New Capabilities

None.

### Modified Capabilities

None.

## Approach

### Estructura final del `CustomScrollView` en `BookScreen`

```dart
Scaffold(
  body: SafeArea(
    child: CustomScrollView(
      slivers: [
        SliverAppBarBook(books: widget.book),          // se mantiene
        SliverToBoxAdapter(
          child: BookDetailContent(books: widget.book), // nuevo widget
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ... // BookTookList item
          ),
        ),
      ],
    ),
  ),
)
```

### Por archivo

| Archivo | Acción | Detalle |
|---------|--------|---------|
| `BookDetailContent` | Crear | StatelessWidget. Recibe `BookWithRelations`. Contiene: descripción, 3x `CardInfoDetail` (publicado/tipo, país/estado, tomos/capítulos), Wrap de géneros, fuente + enlace. `FavoriteButton` junto a `TitleWidget('Descripción')`. |
| `BookTookList` | Crear | StatelessWidget. Recibe `List<TookEntity>` + `onTookTap`. Render interno con `SliverList` + `SliverChildBuilderDelegate`. Mismo layout de card que `TookView`. |
| `BookScreen` | Modificar | Quitar `SingleTickerProviderStateMixin`, `TabController`, `ScrollController`, `isVisible`. Reemplazar `NestedScrollView` + `TabBarView` por `CustomScrollView` con los slivers de arriba. |
| `DetailView` | Eliminar | Contenido migrado a `BookDetailContent`. |
| `TookView` | Eliminar | Contenido migrado a `BookTookList`. |
| `SliverPersistentHeaderBook` | Eliminar | Sin tabs, sobra. |
| `SliverAppBarDelegate` | Eliminar | Único cliente era `SliverPersistentHeaderBook`. |

## Data Flow

Sin cambios. `BookScreen` sigue recibiendo `BookWithRelations` y lo reparte:

```
BookScreen
  └─ SliverAppBarBook (widget.book — BookEntity)
  └─ BookDetailContent (widget.book — BookWithRelations)
  └─ BookTookList (widget.book.listTook, onTookTap → TookScreen)
```

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Scroll position perdido al volver de TookScreen | Baja | `CustomScrollView` mantiene posición naturalmente. No hay TabController que reseteé. |
| SafeArea duplicado | Baja | `DetailView` y `TookView` tenían `SafeArea` interno. `BookScreen` ya tiene `SafeArea` externo. Asegurarse de NO duplicar. |
| Alguien importa DetailView/TookView en otra parte | Media | Buscar con grep antes de eliminar. Si existe, mantener archivo como wrapper o refactorizar ese importador. |

## Rollback Plan

Revertir el commit que borra los 4 archivos y modifica `BookScreen`. Los archivos eliminados existen en git — `git checkout HEAD~1 -- <path>` por cada uno.

## Success Criteria

- [ ] BookScreen compila sin `TabBarView`, `NestedScrollView`, `TabController`
- [ ] La pantalla muestra: SliverAppBar → info del libro → lista de tomos
- [ ] Tap en un tomo navega a `TookScreen`
- [ ] Scroll suave de principio a fin
- [ ] `flutter test` pasa sin regresiones
- [ ] No hay imports rotos a `DetailView` o `TookView`

## Dependencies

Ninguna. Refactor 100% interno de widgets.
