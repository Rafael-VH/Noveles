# Dependency Injection

> GetIt service locator manages all dependencies across features.

## Overview

Noveles uses `GetIt` as a service locator for dependency injection. The central
instance is defined in `lib/core/di/injection.dart` as `final getIt =
GetIt.instance;`. Dependencies are registered in a structured way: core services
first, then per-feature modules via dedicated injection files.

## Core Registration

Core services are registered in `_registerCore()` within
`lib/core/di/injection.dart`:

| Service | Type | Registration |
| --------- | ------ | -------------- |
| SupabaseClientProvider | LazySingleton | Provides Supabase client instance |
| CoverUrlService | LazySingleton | Generates cover URLs from storage paths |

```dart
void _registerCore() {
  getIt.registerLazySingleton<SupabaseClientProvider>(
    () => SupabaseClientProviderImpl(),
  );
  getIt.registerLazySingleton(
    () => CoverUrlService(getIt<SupabaseClientProvider>().client),
  );
}
```text

## Feature Modules

**12 feature modules** (with `label_rules` inside `injection_labels.dart`):

Each feature has its own injection file that registers repositories, use cases,
and BLoCs:

| Module | File | What It Registers |
| -------- | ------ | ------------------- |
| **Auth** | `injection_auth.dart` | `AuthRepository`, 5 use cases, `AuthBloc` |
| Books | `injection_books.dart` | `BookRepository`, 10 use cases, `BookBloc` |
| Chapters | ``chapters`` | `ChapterRepository`, 7 use cases, `ChapterBloc` |
| **Tooks** | `injection_tooks.dart` | `TookRepository`, 6 use cases (no BLoC) |
| Genres | ``genres`` | `GenreRepository`, 5 use cases, `GenreBloc` |
| Labels | injection_labels.dart | LabelRepo+Bloc, LabelRuleRepo+RulesBloc |
| Profiles | ``profiles`` | `ProfilesRepository`, 6 use cases, `ProfileBloc` |
| Favorites | ``favorites`` | FavoriteRepo, FavoriteBloc (no use cases) |
| Scan | `scan` | ScanBookB,ScanCoverB,GenreC,ScanTookB,ScanChapterB |
| Admin | ``admin`` | `AnalyticsRepository`, `AdminBloc`, `AdminAnalyticsBloc` |

## Registration Types

### LazySingleton

Used for repositories, use cases, and services that should be created once and
reused. The instance is created on first access:

```dart
getIt.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(getIt<SupabaseClientProvider>()),
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
- Profiles → Auth → Books → Chapters → Favorites → Genres → Labels → Tooks →
Scan → Admin

> **Note**: `label_rules` dependencies are registered inside
> `initLabelsDependencies()` (in `injection_labels.dart`, not a separate file).

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
```text

**Note**: Scan and Admin modules reuse use cases from other features (e.g.,
`ScanBookBloc` uses `GetBooks`, `CreateBook` from the books module).

← Back to [index](../README.md)
