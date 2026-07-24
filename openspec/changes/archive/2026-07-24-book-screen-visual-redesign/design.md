# Design: Book Screen Visual Redesign

## Technical Approach

Reestructurar `BookScreen` utilizando un `CustomScrollView` unificado. Se preserva `SliverAppBarBook` y se desacopla la información inferior en una barra flotante de estadísticas (`BookQuickStatsBar`), una barra de acciones principales (`BookActionBar`), una cabecera de pestañas en `SliverPersistentHeader` y un conjunto de slivers/widgets modulares (`BookMetadataGrid`, `SliverBookDescriptionCard`, `BookTookList`) en lugar del contenedor monolítico rígido `CardInfoDetail`.

## Architecture Decisions

### Decision 1: Descomposición de CardInfoDetail en Tarjetas Modulares (`BookMetadataGrid`)

**Choice**: Reemplazar la tabla monolítica rígida por una grilla/wrap de tarjetas modulares independientes (`BookMetadataGrid`), donde cada dato (Publicado, Tipo, País, Estado) es una tarjeta con su propio icono, gradiente sutil e id de accesibilidad.
**Alternatives considered**: Mantener `CardInfoDetail` y solo ajustar padding/colores.
**Rationale**: El usuario solicitó explícitamente evitar contenedores rígidos monolíticos para otorgar mayor personalidad visual y flexibilidad de layout.

### Decision 2: Navegación por Pestañas con SliverPersistentHeader & TabController

**Choice**: Usar un `SliverPersistentHeader` con un delegate personalizado `_BookTabHeaderDelegate` que alberga un `TabBar` para alternar entre la pestaña de "Información" (Descripción, Metadatos, Géneros, Fuente) y la pestaña de "Tomos & Capítulos" (`BookTookList`).
**Alternatives considered**: Scroll largo único sin pestañas.
**Rationale**: Reduce la carga cognitiva y evita que el usuario tenga que hacer scroll excesivo cuando solo desea acceder a la lista de tomos.

### Decision 3: Barra de Acción Flotante / Primaria (`BookActionBar`)

**Choice**: Crear `BookActionBar` que presenta el botón primario prominentemente ("Empezar a leer" / "Continuar Lectura") y el `FavoriteButton` al lado.
**Alternatives considered**: Mantener el botón de Favorito al lado del título de Descripción.
**Rationale**: Mayor visibilidad de la acción principal del usuario (comenzar la lectura de la novela).

## Data Flow

```
   BookWithRelations (Entity)
            │
            ├─→ SliverAppBarBook (Portada + Titulo)
            ├─→ BookQuickStatsBar (Rating, Tomos, Estado)
            ├─→ BookActionBar (Boton Leer + FavoriteButton)
            └─→ SliverPersistentHeader (Pestañas: Info | Tomos)
                     ├── [Tab 0: Info] ──→ DescriptionCard + MetadataGrid + Genres + Source
                     └── [Tab 1: Tomos] ─→ BookTookList
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `lib/features/books/presentation/screens/book_screen.dart` | Modify | Integración de CustomScrollView con TabController y slivers unificados |
| `lib/features/books/presentation/screens/widgets/book_quick_stats_bar.dart` | Create | Widget flotante para mostrar métricas destacadas del libro |
| `lib/features/books/presentation/screens/widgets/book_action_bar.dart` | Create | Widget para botón "Empezar a leer" y favorito |
| `lib/features/books/presentation/screens/widgets/book_metadata_grid.dart` | Create | Tarjetas modulares individuales para los metadatos |
| `lib/features/books/presentation/screens/widgets/card_info_detail.dart` | Delete/Deprecate | Eliminación del antiguo contenedor monolítico |

## Interfaces / Contracts

```dart
/// Tarjeta modular de metadato con icono y color de acento
class MetadataCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color? accentColor;

  const MetadataCardData({
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor,
  });
}
```

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Unit/Widget | `BookQuickStatsBar` & `BookMetadataGrid` | `testWidgets` para verificar renderizado de tarjetas y cambio de pestañas |
| Widget | `BookActionBar` | Widget test verificando tap en botón de lectura y favorito |
| Analyze | Linting y Clean Architecture | `flutter analyze` 0 warnings/errors |

## Migration / Rollout

No requiere migración de datos. Cambio puramente visual en la capa de presentación.

## Open Questions

- None
