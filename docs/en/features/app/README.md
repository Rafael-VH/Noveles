# App

> Application shell — main screen, navigation drawer, and home carousel.

## Overview

The App feature provides the root-level UI components: the main home screen for
regular users, the navigation drawer shared across roles, and the carousel app
bar. It orchestrates multiple BLoCs (`BookBloc`, `GenreBloc`) and handles
infinite scroll pagination for the book feed.

## Components

- **MainScreen** — main home screen for regular users with carousel, sections,
  infinite scroll
- **AppDrawer** — Material 3 NavigationDrawer with role-based sections,
  sub-widgets (AppDrawerHeader, DrawerSectionLabel, LogoutFooter)
- **SliverAppBarHome (Carousel)** — carousel slider of book covers in the sliver
  app bar

### MainScreen

**File**: `lib/features/app/presentation/screens/main_screen.dart`

The primary home screen for regular users. It combines:

- **Carousel**: A `SliverAppBarHome` widget showing featured books in a carousel
at the top
- **Continuar leyendo**: `SectionRecentViews` — horizontal scroll of recently
viewed books (auth-dependent, triggers `LoadRecentViews(userId)`)
- **Novedades**: `SectionNovedades` — newest books sorted by creation date
- **Más vistos**: `SectionMasVistos` — most viewed books globally (horizontal
scroll)
- **Populares**: `SectionPopulares` — sorted by took/chapter count
- **Genre chips**: Horizontal scrolling genre filter — tapping navigates to
`GenreScreen`
- **Infinite scroll**: `ScrollController` listener triggers `LoadMoreBooks` when
within 200px of bottom
- **Empty state**: Shows `EmptyState` widget when no books are available

**BLoCs provided**:

- `BookBloc` with `onlyVisible: true` — regular users only see published books
- `GenreBloc` — loaded via `getIt<GenreBloc>()`
- `RecentViewsBloc` — loaded via `getIt<RecentViewsBloc>()`
- `PopularViewsBloc` — loaded via `getIt<PopularViewsBloc>()`

### AppDrawer

**File**: `lib/features/app/presentation/widgets/app_drawer.dart`

Shared navigation drawer used by all roles. Built with Material 3 `NavigationDrawer`
(replaces legacy `Drawer` + `ListView` + `ListTile`). Menu items are organized into
role-based sections; items that don't apply to the current role are excluded entirely
(not hidden).

**Role-based section structure**:

| Section | Items | reader | scan | admin |
| --------- | ------- | -------- | ------ | ------- |
| Navegación | Inicio | ✅ | ✅ | — |
| Navegación | Panel Admin | — | — | ✅ |
| Perfil | Editar Perfil | ✅ | ✅ | ✅ |
| Perfil | Mis Favoritos | ✅ | — | — |
| Gestión | Etiquetas | — | ✅ | ✅ |
| Sesión | Cerrar Sesión | ✅ | ✅ | ✅ |

**Key behaviors**:

- **Admin users**: only see "Panel Admin" and "Editar Perfil" in
  Navegación/Perfil sections — no "Mis Favoritos" or "Etiquetas"
- **Scan users**: see "Inicio", "Editar Perfil", "Etiquetas" — no
  "Panel Admin" or "Mis Favoritos"
- **Regular users (lectores)**: see "Inicio", "Editar Perfil", "Mis Favoritos"
  — no admin or scan items
- **Suspended users**: not routed to any home screen (blocked at `AuthBloc` level)
- **Unauthenticated**: shows simplified header with "Iniciar Sesión" option
- **Loading**: renders `SizedBox.shrink()` while auth state resolves

**Sub-widgets**:

- **AppDrawerHeader** (`lib/features/app/presentation/widgets/drawer/app_drawer_header.dart`):
  Gradient background (primary → primaryContainer), avatar 48px with fallback icon,
  display name, email. Simplified variant used when unauthenticated.
- **DrawerSectionLabel** (`lib/features/app/presentation/widgets/drawer/drawer_section_label.dart`):
  Section divider with `labelSmall` text style (e.g., "Navegación", "Perfil", "Gestión",
  "Sesión"). Passed through as non-selectable items.
- **LogoutFooter** (`lib/features/app/presentation/widgets/drawer/logout_footer.dart`):
  Divider + ListTile with error-colored leading icon and "Cerrar Sesión". Dispatches
  `LogoutRequested` via `showConfirmationDialog`.

**Theme**: NavigationDrawer customizes `indicatorShape` (borderRadius 12),
`tileHeight` (56), and `indicatorColor` (primaryContainer) in both light and
dark themes.

### SliverAppBarHome (Carousel)

**File**: `lib/features/app/presentation/widgets/carousel_appbar_sliver.dart`

- Carousel slider of book covers using `carousel_slider` package
- Each cover is tappable — navigates to `BookScreen` with a 1-second page
transition
- Actions slot for the drawer hamburger icon

## Navigation

The app uses a mix of named routes and imperative navigation:

- Named routes: `/admin` (defined in `App`), `/label-management`
- Imperative: `Navigator.push(MaterialPageRoute(...))` for profile, favorites,
book detail, genre screen

## Related

- [Books](../../features/books/README.md) — `BookBloc`, `BookWithRelations`,
`GetRecentViews`, `GetMostViewedBooks`
- [Chapters](../../features/chapters/README.md) — `MarkChapterAsRead`,
`GetReadChapterIds`, read tracking
- [Genres](../../features/genres/README.md) — `GenreBloc`, genre chips
- [Favorites](../../features/favorites/README.md) — Favorites screen via drawer
- [Auth](../../features/auth/README.md) — `AuthBloc` drives drawer visibility
- [Routing](../../architecture/routing.md) — Role-based home selection
- [Theme](../../architecture/theme.md) — ThemeBloc drives app theme

← Back to [index](../../README.md)
