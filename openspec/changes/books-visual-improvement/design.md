# Design: books-visual-improvement

## Technical Approach

Refactor UI puro: 8 cambios independientes sobre widgets existentes. Sin tocar BLoC, repositorios, entidades ni DB. Capas de aplicación: (1) rendimiento — blur sigma, elevaciones; (2) consistencia — chips, headers, tipografía; (3) pulido — parallax, press states, agrupación.

## Architecture Decisions

| Decisión | Opciones | Tradeoff | Elección |
|----------|----------|----------|----------|
| Parallax en SliverAppBar | `flexibleSpace` + `LayoutBuilder` con `MediaQuery` leyendo scroll offset | Sin AnimationController, solo transform/opacity. El cover se mueve con el scroll nativo | `SliverAppBar.stretch: true` + `flexibleSpace` con `MediaQuery` para `expandedHeight` responsivo |
| Blur sigma 5 | 3 / 5 / 7 | 3 es muy nítido, 7 se acerca al original borroso | 5 como default; configurable vía constante para test visual |
| Título colapsado | `title: Text(books.name)` + `overflow: TextOverflow.ellipsis` | Nombres largos se cortan con ellipsis | `maxLines: 1, overflow: ellipsis` en collapsed title |
| Aspect ratio thumbnail | `AspectRatio(3/4)` reemplazando `Expanded(flex: 10)` | Altura fija en vez de proporcional al espacio disponible. Consistente con `BookCardVertical` | `AspectRatio(3/4)` envuelto en `ClipRRect` dentro del `Positioned` |
| Unificación header | Nueva clase `SectionTitle` que reemplaza ambos | TitleWidget (barra color) usado solo en book detail; SectionHeader usado en home/browse | Nueva clase `SectionTitle` con `{title, icon?, trailing?, padding?, showAccent?}`. TitleWidget deprecado, callers migrados |
| Cards merge en CardInfoDetail | Aceptar `List<(String, String)>` en vez de `title1/text1/title2/text2` | Más flexible, elimina repetición en caller | Nueva prop `pairs: List<InfoPair>` con `InfoPair(title, value)` |
| Card elevation default | 0 / 2 / 4 en theme | 0 = sin sombra (actual), 2 = sutil, 4 = notoria | 2.0 en `cardTheme.elevation` (light + dark) |
| Press-state feedback | `InkWell` splash + `AnimatedScale` vía `StatefulWidget` | Scale animation requiere StatefulWidget, splash es gratis con InkWell ya presente | Convertir cards a `StatefulWidget` + `AnimatedScale(0.97)` en `onTapDown/Up` |

## File Changes

| Archivo | Acción | Descripción |
|---------|--------|-------------|
| `lib/features/books/.../sliver_app_bar_book.dart` | Modificar | blur sigma 10→5, parallax/stretch, collapsed title dinámico, AspectRatio thumbnail, expandedHeight responsivo |
| `lib/features/books/.../book_detail_content.dart` | Modificar | description → bodyLarge(16px), FavoriteButton alineado derecha, secciones agrupadas, chips→GenreChipStyled, padding 10→16 |
| `lib/features/books/.../card_info_detail.dart` | Modificar | elevation→theme default, Spacer→SizedBox(8), API a `pairs: List<InfoPair>` |
| `lib/features/app/.../book_card_vertical.dart` | Modificar | StatefulWidget + AnimatedScale press, padding texto 2→4 top/bottom |
| `lib/features/app/.../book_card_horizontal.dart` | Modificar | StatefulWidget + AnimatedScale press, Spacer→SizedBox |
| `lib/features/app/.../carousel_appbar_sliver.dart` | Modificar | title→titleLarge, dots→Positioned(bottom: 0, left: 16) + page indicator "1/N" |
| `lib/core/.../title_widget.dart` | Deprecar | Marcar @Deprecated, migrar callers a SectionTitle |
| `lib/features/app/.../section_header.dart` | Renombrar a `SectionTitle` | Agregar `showAccent` para barra de color opcional |
| `lib/core/utils/theme/light_theme.dart` | Modificar | cardTheme.elevation: 0→2.0 |
| `lib/core/utils/theme/dark_theme.dart` | Modificar | cardTheme.elevation: 0→2.0 |

## Component Design

### SliverAppBarBook — Parallax Approach

```dart
// Responsive expandedHeight
final expandedHeight = MediaQuery.of(context).size.height * 0.48;

// SliverAppBar con stretch
SliverAppBar(
  title: Text(books.name, overflow: TextOverflow.ellipsis),
  stretch: true,
  expandedHeight: expandedHeight.clamp(280.0, 420.0),
  flexibleSpace: FlexibleSpaceBar(
    stretchModes: const [StretchMode.zoomBackground],
    background: Stack(
      children: [
        // Cover image (full-bleed)
        // Blur overlay sigma 5
        // Gradient fading into surface
        // Positioned bottom: AspectRatio 3/4 thumbnail + title + author
      ],
    ),
  ),
)
```

El gradient usa `Color.lerp(surface.withValues(alpha: 0.5), surface, scrollFactor)` para fusión suave con scaffold al colapsar.

### CardInfoDetail — API Unificada

```dart
class CardInfoDetail extends StatelessWidget {
  const CardInfoDetail({
    super.key,
    required this.pairs,
  });

  final List<InfoPair> pairs;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,  // usa theme default 2.0
    child: Row(
      children: pairs.map((p) => Expanded(
        child: Column(children: [
          Text(p.title, style: theme.textTheme.bodySmall),
          Text(p.value, style: theme.textTheme.bodyMedium?.bold),
        ]),
      )).toList(),
    ),
  );
}
```

Caller pasa `pairs: [InfoPair('Publicado', books.release), ...]` en un solo `CardInfoDetail`.

### SectionTitle — Header Unificado

```dart
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    required this.title,
    this.icon,
    this.trailing,
    this.padding,
    this.showAccent = false,  // barra de color tipo TitleWidget
  });
}
```

TitleWidget se depreca con `@Deprecated('Use SectionTitle with showAccent')`.

### Press-State en Book Cards

Convertir a `StatefulWidget` con `_isPressed` estado. `InkWell` splash nativo + `AnimatedScale` animado por `onTapDown`/`onTapUp`/`onTapCancel`.

```dart
// Dentro del build
AnimatedScale(
  scale: _isPressed ? 0.97 : 1.0,
  duration: const Duration(milliseconds: 100),
  child: Card(elevation: 2.0, ...)
)
```

## Testing Strategy

| Capa | Qué probar | Cómo |
|------|-----------|------|
| Visual | Blur sigma 5 en ambos temas | Side-by-side screenshot en simulator |
| Visual | Gradiente fade en SliverAppBar | Scroll test visual |
| Widget | Collapsed title = book.name | `find.text('Details')` desaparece, `find.text(bookName)` existe |
| Widget | CardInfoDetail con `pairs` | Renderiza N pares correctamente |
| Widget | GenreChipStyled reemplaza Chip raw | Wrap contiene GenreChipStyled widgets |
| Widget | SectionTitle con showAccent=true | Aparece Container de 6px de ancho |
| Widget | Carousel page indicator "1/N" | Texto "1/{N}" visible |
| Integración | BookScreen sin crash con datos reales | smoke test navegación |
| Tema | Ambos temas sin regresiones | Test visual side-by-side |
| Accesibilidad | Press feedback visible | ElevatedButton estándar soporta TalkBack |

## Open Questions

- [ ] Blur sigma 5: verificar visualmente que no sea muy nítido. Si el cover tiene mucho detalle, probar sigma 6 como fallback. No hay test automático — decisión visual.
- [ ] Constante `expandedHeight = 0.48 * screenHeight` — puede necesitar ajuste en tablets o landscape. Verificar en al menos 3 tamaños de pantalla.
- [ ] `AnimatedScale` en book cards: decidir si el efecto vale la complejidad de `StatefulWidget` vs. solo splash de `InkWell`. Si el rendimiento es crítico, omitir scale.
