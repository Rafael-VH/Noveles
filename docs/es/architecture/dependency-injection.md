# Inyección de Dependencias

> El localizador de servicios GetIt gestiona todas las dependencias entre
> funcionalidades.

## Resumen

Noveles usa `GetIt` como localizador de servicios para la inyección de
dependencias. La instancia central se define en `lib/core/di/injection.dart`
como `final getIt = GetIt.instance;`. Las dependencias se registran de forma
estructurada: primero los servicios core, luego los módulos por funcionalidad
mediante archivos de inyección dedicados.

## Registro Core

Los servicios core se registran en `_registerCore()` dentro de
`lib/core/di/injection.dart`:

| Servicio | Tipo | Registro |
| -------- | ---- | -------- |
| SupabaseClientProvider | LazySingleton | Provee instancia cliente Supabase |
| CoverUrlService | LazySingleton | Genera URLs de portada desde storage |

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

## Módulos de Funcionalidad

**10 módulos de funcionalidad**:

Cada funcionalidad tiene su propio archivo de inyección que registra
repositorios, casos de uso y BLoCs:

| Módulo | Archivo | Lo que Registra |
| ------ | ------- | --------------- |
| **Auth** | `features/auth/di/injection_auth.dart` | `AuthRepository`, 5 UC, `AuthBloc` |
| Books | `features/books/di/injection_books.dart` | `BookRepository`, 10 UC, `BookBloc`, `FavoriteRepository`, `FavoriteBloc` |
| Chapters | `features/chapters/di/injection_chapters.dart` | `ChapterRepository`, 7 casos de uso, `ChapterBloc` |
| **Tooks** | `features/tooks/di/injection_tooks.dart` | `TookRepository`, 6 UC (sin BLoC) |
| Genres | `features/genres/di/injection_genres.dart` | `GenreRepository`, 5 casos de uso, `GenreBloc` |
| Labels | `features/labels/di/injection_labels.dart` | LabelRepo+Bloc, LabelRuleRepo+RulesBloc (7+4 UC) |
| Profiles | `features/profiles/di/injection_profiles.dart` | `ProfilesRepository`, 6 UC, `ProfileBloc` |
| Scan | `features/scan/di/injection_scan.dart` | ScanBookB, ScanCoverB, GenreC, ScanTookB, ScanChapterB |
| Admin | `features/admin/di/injection_admin.dart` | `AnalyticsRepository`, `AdminBloc`, `AdminAnalyticsBloc` |
| App | `features/app/di/injection_app.dart` | BLoCs de pantalla principal, dependencias del drawer |

## Tipos de Registro

### LazySingleton

Se usa para repositorios, casos de uso y servicios que deben crearse una vez y
reutilizarse. La instancia se crea en el primer acceso:

```dart
getIt.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(getIt<SupabaseClientProvider>()),
);
```text

**Cuándo usarlo**: Dependencias con estado (repositorios, servicios) u objetos
costosos de crear.

### Factory

Se usa para BLoCs y Cubits que necesitan instancias nuevas cada vez. Cada árbol
de widgets recibe su propio BLoC:

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

**Cuándo usarlo**: Gestión de estado sin estado (BLoCs, Cubits) o cuando se
necesita una instancia nueva por solicitud.

## Flujo de Inicialización

1. `main()` llama a `setupDependencies()`
2. `setupDependencies()` llama a `_registerCore()` primero
3. Luego llama a cada `init*Dependencies()` de cada funcionalidad en orden:
   - Profiles → Auth → Books → Chapters → Genres → Labels → Tooks →
     Scan → Admin → App

4. Cada función de funcionalidad registra sus propias dependencias usando `getIt`

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

**Nota**: Los módulos Scan y Admin reutilizan casos de uso de otras
funcionalidades (ej.: `ScanBookBloc` usa `GetBooks`, `CreateBook` del módulo de
books).

← Volver al [índice](../README.md)
