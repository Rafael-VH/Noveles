# Proposal: Book Screen Visual Redesign

## Intent

Modernizar la interfaz visual y UX de `BookScreen` (manteniendo `SliverAppBarBook`). La pantalla actual presenta la información en un scroll vertical plano con un container monolítico (`CardInfoDetail`) rígido. El rediseño desempaquetará las secciones en slivers independientes con personalidad visual propia para cada dato (metadatos, géneros, fuentes, tomos), además de incluir una barra flotante de estadísticas clave, botones de acción primaria ("Continuar leyendo", "Favorito") y un Segmented Control en Sliver para alternar pestañas.

## Scope

### In Scope
- **Floating Quick-Stats Bar**: Rating, Estado, Tomos/Capítulos y Tipo de Novela con diseño tipo píldora/card flotante.
- **Barra de Acción Principal**: Botón destacado "Continuar / Empezar Lectura" + Botón de Favorito animado + Link a Fuente.
- **Segmented Control / Tab System**: Pestañas con animación sutil ("Información" y "Tomos / Capítulos") usando Slivers.
- **Desarticulación de CardInfoDetail en Slivers Granulares**: Eliminación del Container monolítico rígido de 2xN. Cada metadato (Fecha publicación, País, Tipo, Estado) tendrá su propio widget/card con jerarquía visual única.
- **Rediseño de Sección Géneros y Fuente**: Chips estilizados con interacción y tarjeta de fuente independiente.
- **Mejora visual de BookTookList**: Tarjetas de tomos refinadas con progreso de lectura e indicadores claros.

### Out of Scope
- Cambio de contratos BLoC, repositorios o llamadas a API (todos los datos provienen de `BookWithRelations`).
- Rediseño de `ChapterScreen` o `SliverAppBarBook` (conservado intacto por pedido del usuario).

## Capabilities

### New Capabilities
- `book-detail-ui`: Nueva especificación de diseño visual e interacción desarticulada en slivers granulares para la pantalla de detalle de libros.

### Modified Capabilities
- None

## Approach

Reestructurar `BookScreen` en `lib/features/books/presentation/screens/book_screen.dart` utilizando `CustomScrollView` con slivers independientes:
1. Mantener `SliverAppBarBook`.
2. Insertar `SliverToBoxAdapter` para el Quick Stats Header y el Action Bar.
3. Implementar un `SliverPersistentHeader` con `TabBar` / `SegmentedButton` para alternar entre "Información" y "Tomos".
4. Reemplazar `CardInfoDetail` por múltiples Slivers (`SliverBookMetadataGrid`, `SliverBookDescriptionCard`, `SliverBookGenresWrap`) con tarjetas de personalidad propia.
5. Garantizar soporte impecable para Light/Dark mode.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `lib/features/books/presentation/screens/book_screen.dart` | Modified | Reestructuración completa con slivers independientes |
| `lib/features/books/presentation/screens/widgets/card_info_detail.dart` | Deprecated/Refactored | Reemplazado por widgets granulares de sliver |
| `lib/features/books/presentation/screens/widgets/sliver_book_metadata.dart` | New | Tarjetas de metadatos granulares por sliver |
| `lib/features/books/presentation/screens/widgets/book_took_list.dart` | Modified | Estilización refinada de la lista de tomos |
| `lib/features/books/presentation/screens/widgets/book_action_bar.dart` | New | Nuevo widget de acciones principales (Leer / Favorito) |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Ruptura de coordinaciones de scroll en Slivers | Low | Se usará `CustomScrollView` unificado sin `NestedScrollView` anidados |
| Overlap visual en pantallas pequeñas | Low | Uso de `Wrap` y layouts adaptables con `SingleChildScrollView` en pestañas |

## Rollback Plan

Revertir los cambios en `lib/features/books/presentation/screens/` usando Git (`git checkout feat/...`).

## Success Criteria

- [ ] `SliverAppBarBook` conservado 100% intacto.
- [ ] Container monolítico `CardInfoDetail` descompuesto en slivers/widgets granulares con personalidad propia.
- [ ] Quick Stats Bar y barra de acción principal integrados.
- [ ] Pestañas de alternancia "Información" vs "Tomos y Capítulos".
- [ ] 0 regresiones en compilación (`flutter analyze`) y tests pasando.
