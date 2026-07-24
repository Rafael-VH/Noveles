# App

> Shell de la aplicación — pantalla principal, drawer de navegación y carrusel
> de inicio.

## Resumen

El feature App provee los componentes de UI a nivel raíz: la pantalla de inicio
principal para usuarios regulares, el drawer de navegación compartido entre
roles y la barra de app con carrusel. Orquesta múltiples BLoCs (`BookBloc`,
`GenreBloc`) y maneja la paginación con scroll infinito para el feed de libros.

## Componentes

- **MainScreen** — pantalla de inicio principal para usuarios regulares con
  carrusel, secciones y scroll infinito
- **AppDrawer** — NavigationDrawer de Material 3 con secciones basadas en rol,
  sub-widgets (AppDrawerHeader, DrawerSectionLabel, LogoutFooter)
- **SliverAppBarHome (Carrusel)** — slider de carrusel de portadas de libros en
  la sliver app bar

### MainScreen

**Archivo**: `lib/features/app/presentation/screens/main_screen.dart`

La pantalla de inicio principal para usuarios regulares. Combina:

- **Carrusel**: Un widget `SliverAppBarHome` que muestra libros destacados en un
  carrusel en la parte superior
- **Continuar leyendo**: `SectionRecentViews` — scroll horizontal de libros
  vistos recientemente (depende de auth, dispara `LoadRecentViews(userId)`)
- **Novedades**: `SectionNovedades` — libros más nuevos ordenados por fecha de
  creación
- **Más vistos**: `SectionMasVistos` — libros más vistos globalmente (scroll
  horizontal)
- **Populares**: `SectionPopulares` — ordenados por cantidad de tooks/capítulos
- **Chips de género**: Filtro de género con scroll horizontal — al tocar
  navega a `GenreScreen`
- **Scroll infinito**: un listener de `ScrollController` dispara
  `LoadMoreBooks` cuando está a menos de 200px del final
- **Estado vacío**: Muestra el widget `EmptyState` cuando no hay libros
  disponibles

**BLoCs provistos**:

- `BookBloc` con `onlyVisible: true` — los usuarios regulares solo ven libros
  publicados
- `GenreBloc` — cargado vía `getIt<GenreBloc>()`
- `RecentViewsBloc` — cargado vía `getIt<RecentViewsBloc>()`
- `PopularViewsBloc` — cargado vía `getIt<PopularViewsBloc>()`

### AppDrawer

**Archivo**: `lib/features/app/presentation/widgets/app_drawer.dart`

Drawer de navegación compartido usado por todos los roles. Construido con
`NavigationDrawer` de Material 3 (reemplaza el `Drawer` + `ListView` + `ListTile`
legado). Los elementos del menú se organizan en secciones basadas en rol; los
ítems que no aplican al rol actual se excluyen por completo (no se ocultan).

**Estructura de secciones por rol**:

| Sección | Ítems | lector | scan | admin |
| ------- | ----- | ------ | ---- | ----- |
| Navegación | Inicio | ✅ | ✅ | — |
| Navegación | Panel Admin | — | — | ✅ |
| Perfil | Editar Perfil | ✅ | ✅ | ✅ |
| Perfil | Mis Favoritos | ✅ | — | — |
| Gestión | Etiquetas | — | ✅ | ✅ |
| Sesión | Cerrar Sesión | ✅ | ✅ | ✅ |

**Comportamientos clave**:

- **Admin**: solo ve "Panel Admin" y "Editar Perfil" en las secciones
  Navegación/Perfil — ni "Mis Favoritos" ni "Etiquetas"
- **Scan**: ve "Inicio", "Editar Perfil", "Etiquetas" — ni "Panel Admin" ni
  "Mis Favoritos"
- **Usuarios regulares (lectores)**: ven "Inicio", "Editar Perfil",
  "Mis Favoritos" — sin ítems de admin ni scan
- **Usuarios suspendidos**: no se les asigna ninguna pantalla de inicio
  (bloqueados a nivel de `AuthBloc`)
- **No autenticados**: muestra un encabezado simplificado con la opción
  "Iniciar Sesión"
- **Cargando**: renderiza `SizedBox.shrink()` mientras se resuelve el estado de
  auth

**Sub-widgets**:

- **AppDrawerHeader**
  (`lib/features/app/presentation/widgets/drawer/app_drawer_header.dart`):
  Fondo degradado (primary → primaryContainer), avatar de 48px con ícono de
  fallback, nombre visible, email. Variante simplificada cuando no está
  autenticado.
- **DrawerSectionLabel**
  (`lib/features/app/presentation/widgets/drawer/drawer_section_label.dart`):
  Divisor de sección con estilo de texto `labelSmall` (ej., "Navegación",
  "Perfil", "Gestión", "Sesión"). Se pasa como ítems no seleccionables.
- **LogoutFooter**
  (`lib/features/app/presentation/widgets/drawer/logout_footer.dart`):
  Divisor + ListTile con ícono leading en color de error y "Cerrar Sesión".
  Despacha `LogoutRequested` mediante `showConfirmationDialog`.

**Tema**: NavigationDrawer personaliza `indicatorShape` (borderRadius 12),
`tileHeight` (56) e `indicatorColor` (primaryContainer) en temas claro y
oscuro.

### SliverAppBarHome (Carrusel)

**Archivo**: `lib/features/app/presentation/widgets/carousel_appbar_sliver.dart`

- Carrusel de portadas de libros usando el paquete `carousel_slider`
- Cada portada es táctil — navega a `BookScreen` con una transición de 1
  segundo
- Espacio para el ícono de hamburguesa del drawer

## Navegación

La app usa una combinación de rutas nombradas y navegación imperativa:

- Rutas nombradas: `/admin` (definida en `App`), `/label-management`
- Imperativa: `Navigator.push(MaterialPageRoute(...))` para perfil, favoritos,
  detalle de libro, pantalla de género

## Relacionados

- [Books](../../es/features/books/README.md) — `BookBloc`, `BookWithRelations`,
  `GetRecentViews`, `GetMostViewedBooks`
- [Chapters](../../es/features/chapters/README.md) — `MarkChapterAsRead`,
  `GetReadChapterIds`, seguimiento de lectura
- [Genres](../../es/features/genres/README.md) — `GenreBloc`, chips de género
- [Books/Favorites](../../es/features/books/README.md) — Libros y favoritos vía
  drawer
- [Auth](../../es/features/auth/README.md) — `AuthBloc` controla la visibilidad
  del drawer
- [Ruteo](../../es/architecture/routing.md) — Selección de inicio según rol
- [Tema](../../es/architecture/theme.md) — ThemeBloc controla el tema de la app

← Volver al [índice](../../es/README.md)
