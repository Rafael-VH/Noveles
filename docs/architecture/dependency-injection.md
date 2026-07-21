# Dependency Injection

> GetIt service locator manages all dependencies across features.

## Overview

Noveles uses `GetIt` as a service locator for dependency injection. The central instance is defined in `lib/core/di/injection.dart` as `final getIt = GetIt.instance;`. Dependencies are registered in a structured way: core services first, then per-feature modules via dedicated injection files.

## Core Registration

Core services are registered in `_registerCore()` within `lib/core/di/injection.dart`:

| Service | Type | Registration |
|---------|------|--------------|
| `SupabaseClientProvider` | `LazySingleton` | Provides Supabase client instance |
| `CoverUrlService` | `LazySingleton` | Generates cover URLs from storage paths |

```dart
void _registerCore() {
  getIt.registerLazySingleton<SupabaseClientProvider>(
    () => SupabaseClientProviderImpl(),
  );
  getIt.registerLazySingleton(
    () => CoverUrlService(getIt<SupabaseClientProvider>().client),
  );
}
```

## Feature Modules

Each feature has its own injection file that registers repositories, use cases, and BLoCs:

| Module | File | What It Registers |
|--------|------|-------------------|
| **Auth** | `lib/core/di/injection_auth.dart` | `AuthRepository`, 5 use cases, `AuthBloc` |
| **Books** | `lib/core/di/injection_books.dart` | `BookRepository`, 10 use cases, `BookBloc` |
| **Chapters** | `lib/core/di/injection_chapters.dart` | `ChapterRepository`, 7 use cases, `ChapterBloc` |
| **Tooks** | `lib/core/di/injection_tooks.dart` | `TookRepository`, 6 use cases (no BLoC) |
| **Genres** | `lib/core/di/injection_genres.dart` | `GenreRepository`, 5 use cases, `GenreBloc` |
| **Labels** | `lib/core/di/injection_labels.dart` | `LabelRepository`, 7 use cases, `LabelBloc` |
| **Profiles** | `lib/core/di/injection_profiles.dart` | `ProfilesRepository`, 6 use cases, `ProfileBloc` |
| **Favorites** | `lib/core/di/injection_favorites.dart` | `FavoriteRepository`, `FavoriteBloc` (no use cases) |
| **Scan** | `lib/core/di/injection_scan.dart` | `ScanBookBloc`, `ScanCoverBloc`, `GenreCubit`, `ScanTookBloc`, `ScanChapterBloc` |
| **Admin** | `lib/core/di/injection_admin.dart` | `AnalyticsRepository`, `AdminBloc`, `AdminAnalyticsBloc` |

## Registration Types

### LazySingleton

Used for repositories, use cases, and services that should be created once and reused. The instance is created on first access:

```dart
getIt.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(getIt<SupabaseClientProvider>()),
);
```

**When to use**: Stateful dependencies (repositories, services) or expensive-to-create objects.

### Factory

Used for BLoCs and Cubits that need fresh instances each time. Each widget tree gets its own BLoC:

```dart
getIt.registerFactory(
  () => AuthBloc(
    login: getIt(),
    register: getIt(),
    logout: getIt(),
    getCurrentUser: getIt(),
    listenAuthState: getIt(),
  ),
);
```

**When to use**: Stateless state management (BLoCs, Cubits) or when a new instance per request is needed.

## Initialization Flow

1. `main()` calls `setupDependencies()`
2. `setupDependencies()` calls `_registerCore()` first
3. Then calls each feature's `init*Dependencies()` in order:
   - Profiles → Auth → Books → Chapters → Favorites → Genres → Labels → Tooks → Scan → Admin
4. Each feature function registers its own dependencies using `getIt`

```dart
void setupDependencies() {
  _registerCore();
  initProfilesDependencies();
  initAuthDependencies();
  initBooksDependencies();
  initChaptersDependencies();
  initFavoritesDependencies();
  initGenresDependencies();
  initLabelsDependencies();
  initTooksDependencies();
  initScanDependencies();
  initAdminDependencies();
}
```

**Note**: Scan and Admin modules reuse use cases from other features (e.g., `ScanBookBloc` uses `GetBooks`, `CreateBook` from the books module).

← Back to [index](../README.md)