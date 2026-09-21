# Dependency Injection

> GetIt service locator manages all dependencies across features.

## Overview

Noveles uses `GetIt` as a service locator for dependency injection. The central
instance is defined in `lib/bootstrap/injection.dart` as `final getIt =
GetIt.instance;`. Dependencies are registered in a structured way: core services
first, then per-feature modules via dedicated injection files.

## Core Registration

Core services are registered in `_registerCore()` within
`lib/bootstrap/injection.dart`:

| Service | Type | Registration |
| --------- | ------ | -------------- |
| DataGateway, AuthGateway, StorageGateway | LazySingleton | The backend ports, bound to the current backend's adapters |
| CoverUrlService | LazySingleton | Generates cover URLs from storage paths (through `StorageGateway`) |

```dart
void _registerCore() {
  // Binds the three ports to the adapters of the current backend. Nothing
  // above this line knows which vendor that is.
  registerBackendDependencies(getIt);
  getIt.registerLazySingleton(
    () => CoverUrlService(getIt<StorageGateway>()),
  );
}
```text

## Feature Modules

**10 feature modules**:

Each feature has its own injection file that registers repositories, use cases,
and BLoCs:

| Module | File | What It Registers |
| -------- | ------ | ------------------- |
| **Auth** | `features/auth/di/injection_auth.dart` | `AuthRepository`, 5 use cases, `AuthBloc` |
| Books | `features/books/di/injection_books.dart` | `BookRepository`, 10 use cases, `BookBloc`, `FavoriteRepository`, `FavoriteBloc` |
| Chapters | `features/chapters/di/injection_chapters.dart` | `ChapterRepository`, 7 use cases, `ChapterBloc` |
| **Tooks** | `features/tooks/di/injection_tooks.dart` | `TookRepository`, 6 use cases (no BLoC) |
| Genres | `features/genres/di/injection_genres.dart` | `GenreRepository`, 5 use cases, `GenreBloc` |
| Labels | `features/labels/di/injection_labels.dart` | LabelRepo+Bloc, LabelRuleRepo+RulesBloc (7+4 use cases) |
| Profiles | `features/profiles/di/injection_profiles.dart` | `ProfilesRepository`, 6 use cases, `ProfileBloc` |
| Scan | `features/scan/di/injection_scan.dart` | ScanBookB, ScanCoverB, GenreC, ScanTookB, ScanChapterB |
| Admin | `features/admin/di/injection_admin.dart` | `AnalyticsRepository`, `AdminBloc`, `AdminAnalyticsBloc` |
| App | `features/app/di/injection_app.dart` | Home screen BLoCs, drawer dependencies |

## Registration Types

### LazySingleton

Used for repositories, use cases, and services that should be created once and
reused. The instance is created on first access:

```dart
getIt.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(
    getIt<AuthGateway>(),
    getIt<DataGateway>(),
  ),
);
```text

**When to use**: Stateful dependencies (repositories, services) or
expensive-to-create objects.

### Factory

Used for BLoCs and Cubits that need fresh instances each time. Each widget tree
gets its own BLoC:

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
```text

**When to use**: Stateless state management (BLoCs, Cubits) or when a new
instance per request is needed.

## Initialization Flow

1. `main()` calls `setupDependencies()`
2. `setupDependencies()` calls `_registerCore()` first
3. Then calls each feature's `init*Dependencies()` in order:
- Profiles → Auth → Books → Chapters → Genres → Labels → Tooks →
Scan → Admin → App

4. Each feature function registers its own dependencies using `getIt`

```dart
void setupDependencies() {
  _registerCore();
  initProfilesDependencies();
  initAuthDependencies();
  initBooksDependencies();
  initChaptersDependencies();
  initGenresDependencies();
  initLabelsDependencies();
  initTooksDependencies();
  initScanDependencies();
  initAdminDependencies();
  initAppDependencies();
}
```text

**Note**: Scan and Admin modules reuse use cases from other features (e.g.,
`ScanBookBloc` uses `GetBooks`, `CreateBook` from the books module).

← Back to [index](../README.md)
