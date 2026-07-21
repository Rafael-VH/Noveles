# App

> Application shell — main screen, navigation drawer, and home carousel.

## Overview

The App feature provides the root-level UI components: the main home screen for
regular users, the navigation drawer shared across roles, and the carousel app
bar. It orchestrates multiple BLoCs (`BookBloc`, `GenreBloc`) and handles
infinite scroll pagination for the book feed.

## Components

### MainScreen

**File**: `lib/features/app/presentation/screens/main_screen.dart`

The primary home screen for regular users. It combines:

- **Carousel**: A `SliverAppBarHome` widget showing featured books in a carousel
at the top
- **Genre chips**: Horizontal scrolling genre filter — tapping navigates to
`GenreScreen`
- **Infinite scroll**: `ScrollController` listener triggers `LoadMoreBooks` when
within 200px of bottom
- **Empty state**: Shows `EmptyState` widget when no books are available

**BLoCs provided** (created locally, not from DI):

- `BookBloc` with `onlyVisible: true` — regular users only see published books
- `GenreBloc` — loaded via `getIt<GenreBloc>()`

### AppDrawer

**File**: `lib/features/app/presentation/widgets/app_drawer.dart`

Shared navigation drawer used by all roles. Menu items are role-conditional:

| Item | Visible To | Action |
| ------ | ----------- | -------- |
| Panel Admin | Admin only | Push named route `/admin` |
| Panel Scan / Inicio | All roles | Pop drawer (home) |
| Editar Perfil | All roles | Push `ProfileScreen` |
| Mis Favoritos | All roles | Push `FavoritesScreen` |
| Etiquetas | Scan only | Push `LabelManagementScreen` |
| Cerrar Sesion | All roles | Confirm + `LogoutRequested` |

Drawer header shows user avatar (or fallback icon), display name, and email.

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

- [Books](../../features/books/README.md) — `BookBloc`, `BookWithRelations`
- [Genres](../../features/genres/README.md) — `GenreBloc`, genre chips
- [Favorites](../../features/favorites/README.md) — Favorites screen via drawer
- [Auth](../../features/auth/README.md) — `AuthBloc` drives drawer visibility
- [Routing](../../architecture/routing.md) — Role-based home selection
- [Theme](../../architecture/theme.md) — ThemeBloc drives app theme

← Back to [index](../../README.md)
