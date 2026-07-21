# Regular User

> Default role for authenticated users — browse books, manage profile, and
favorites.

## Role Overview

`UserRole.user` is the default role assigned to new registrations. Regular users
can browse the library, read chapters, manage their profile, and maintain a
personal favorites list.

**Enum value**: `UserRole.user` (default in `UserRole.fromString()` for unknown
values)

**Source**: `lib/features/profiles/domain/user_role.dart`

## Permissions

| Action | Allowed |
| ------ | ------- |
| Browse visible books | ✅ |
| Read book details and chapters | ✅ |
| View and manage favorites | ✅ |
| Edit own profile (display name, bio, avatar) | ✅ |
| Change own password | ✅ |
| Filter books by genre | ✅ |
| Create/edit/delete books | ❌ |
| Manage genres or labels | ❌ |
| Access admin dashboard | ❌ |
| Suspend/reactivate users | ❌ |

## Screens

| Screen | File | Purpose |
| ------ | ---- | ------- |
| MainScreen | main_screen.dart | Home with book carousel,genre chips,pagin... |
| `BookScreen` | `book_screen.dart` | Book details, chapters list |
| `ChapterScreen` | `chapter_screen.dart` | Chapter content reader |
| ProfileScreen | profile_screen.dart | Edit profile,upload avatar,change p... |
| `FavoritesScreen` | `favorites_screen.dart` | List of favorited books |

## Navigation

The `AppDrawer` (`lib/features/app/presentation/widgets/app_drawer.dart`) shows
these items for regular users:

| Item | Icon | Destination |
| ---- | ---- | ----------- |
| Inicio | `Icons.home` | Closes drawer (stays on `MainScreen`) |
| Editar Perfil | `Icons.person` | `ProfileScreen` |
| Mis Favoritos | `Icons.favorite` | `FavoritesScreen` |
| Cerrar Sesión | `Icons.logout` | Logout confirmation dialog |

**Note**: Admin and Scan panel links are hidden for regular users via
`isAdmin`/`isScan` flags.

## Routing

In `lib/core/app/app.dart`, the auth state handler routes regular users to
`MainScreen`:

```dart
if (authState.user.isUser) {
  return const MainScreen();
}
```text

**Source**: `lib/core/app/app.dart` (lines 61-63)

## Restrictions

Regular users cannot:

1. **Create books** — `BookScreen` only shows existing books
2. **Manage genres** — `GenreScreen` is read-only
3. **Manage labels** — `LabelManagementScreen` not accessible
4. **Access admin dashboard** — `/admin` route not reachable
5. **Suspend users** — No admin panel access

## RLS Enforcement

Supabase Row Level Security ensures regular users can only:

- Read visible books (`is_visible = true`)
- Read/write their own profile
- Read/write their own favorites
- Read chapters of visible books

← Back to [index](../README.md)
