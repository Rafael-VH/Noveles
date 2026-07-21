# Admin

> Admin dashboard — book management, user role control, and analytics overview.

## Overview

The Admin feature provides an admin-only dashboard with three tabs: Books (visibility toggle, delete), Users (role changes, suspend/reactivate), and Analytics (views trend, top books, overview stats). The `AdminBloc`, `AdminUsersBloc`, and `AdminAnalyticsBloc` each manage their respective tab state independently.

## Domain

**`AnalyticsRepository`** (`lib/features/admin/domain/analytics_repository.dart`):

The only domain-level abstraction in this feature. Admin book/user operations reuse use cases from the `books` and `profiles` features directly.

| Method | Signature | Purpose |
|--------|-----------|---------|
| `getViewsTrend` | `Future<Result<List<Map<String, dynamic>>>> call({int daysBack})` | Views over last N days |
| `getTopBooks` | `Future<Result<List<Map<String, dynamic>>>> call({int limitCount})` | Most-viewed books |
| `getOverview` | `Future<Result<Map<String, dynamic>>> call()` | Dashboard summary stats |

**Implementation**: `AnalyticsRepositoryImpl` calls Supabase RPC functions (`get_views_trend`, `get_top_books`, `get_analytics_overview`).

## BLoCs

### AdminBloc (Books Tab)

**File**: `lib/features/admin/presentation/bloc/admin_bloc.dart`

| Event | Description |
|-------|-------------|
| `LoadAdminBooks` | Load all books (including hidden) |
| `ToggleBookVisibility` | Publish or hide a book |
| `DeleteAdminBook` | Delete a book (2-second cooldown) |

| State | Data | When |
|-------|------|------|
| `AdminInitial` | — | Initial |
| `AdminLoading` | — | Fetching |
| `AdminLoaded` | `List<BookWithRelations> books, String? message` | Loaded |
| `AdminError` | `String message` | Error |

Reuses `GetBooks`, `ToggleBookVisibility`, `DeleteBook` from the books feature.

### AdminUsersBloc (Users Tab)

**File**: `lib/features/admin/presentation/bloc/admin_users_bloc.dart`

| Event | Description |
|-------|-------------|
| `LoadAdminUsers` | Load all user profiles |
| `ChangeUserRole` | Change a user's role |
| `SuspendUser` | Toggle suspend/unsuspend a user |

| State | Data | When |
|-------|------|------|
| `AdminUsersInitial` | — | Initial |
| `AdminUsersLoading` | — | Fetching |
| `AdminUsersLoaded` | `List<UserEntity> users, String? message` | Loaded |
| `AdminUsersError` | `String message` | Error |

Self-protection: cannot change own role or suspend self.

### AdminAnalyticsBloc (Analytics Tab)

**File**: `lib/features/admin/presentation/bloc/admin_analytics_bloc.dart`

| Event | Description |
|-------|-------------|
| `LoadAnalytics` | Load overview + trend + top books |

| State | Data | When |
|-------|------|------|
| `AnalyticsInitial` | — | Initial |
| `AnalyticsLoading` | — | Fetching |
| `AnalyticsLoaded` | `Map overview, List trend, List topBooks` | Loaded |
| `AnalyticsError` | `String message` | Error |

## Screens

### AdminDashScreen

**File**: `lib/features/admin/presentation/screens/admin_dash_screen.dart`

Tabbed dashboard with three tabs:

| Tab | Screen File | Description |
|-----|-------------|-------------|
| Analytics | `analytics_tab.dart` | Overview stats, views trend chart, top books |
| Books | `books_tab.dart` | Book list with visibility toggle and delete |
| Genres | `genres_tab.dart` | Genre CRUD management |
| Users | `users_tab.dart` | User list with role change and suspend actions |

## DI Registration

**File**: `lib/core/di/injection_admin.dart`

- `AnalyticsRepository` → `LazySingleton`
- `AdminBloc` → `Factory` (depends on books use cases)
- `AdminAnalyticsBloc` → `Factory`

**Note**: `AdminUsersBloc` is created in the users tab with `GetAllProfiles` and `UpdateUserRole` from the profiles feature.

## Related

- [Books](../../features/books/README.md) — Book management use cases
- [Profiles](../../features/profiles/README.md) — User management use cases
- [User Types](../../user-types/admin-user.md) — Admin permissions
- [Error Handling](../../architecture/error-handling.md) — `AnalyticsFailure`

← Back to [index](../../README.md)
