# Admin

> Panel de administración — gestión de libros, control de roles de usuario y
> resumen de analíticas.

## Resumen

El feature Admin provee un panel exclusivo para administradores con tres
pestañas: Libros (toggle de visibilidad, eliminar), Usuarios (cambio de rol,
suspender/reactivar) y Analíticas (tendencia de vistas, libros top, estadísticas
generales). El `AdminBloc`, `AdminUsersBloc` y `AdminAnalyticsBloc` gestionan el
estado de cada pestaña de forma independiente.

## Dominio

**`AnalyticsRepository`**
(`lib/features/admin/domain/analytics_repository.dart`):

La única abstracción a nivel de dominio en este feature. Las operaciones de
libros y usuarios del admin reutilizan directamente los casos de uso de los
features `books` y `profiles`.

| Método | Firma | Propósito |
| ------ | ----- | --------- |
| getViewsTrend | `FR<List<AnalyticsTrendEntry>>` call({int n}) | Vistas últimos N días |
| getTopBooks | `FR<List<AnalyticsTopBook>>` call({int n}) | Libros más vistos |
| getOverview | `FR<AnalyticsOverview>` call() | Estadísticas resumidas del dashboard |

**Implementación**: `AnalyticsRepositoryImpl` llama a funciones RPC de Supabase
(`get_views_trend`, `get_top_books`, `get_analytics_overview`). Usa entidades
tipadas de `lib/features/admin/domain/analytics_entities.dart`.

## BLoCs

### AdminBloc (Pestaña Libros)

**Archivo**: `lib/features/admin/presentation/bloc/admin_bloc.dart`

| Evento | Descripción |
| ------ | ----------- |
| `LoadAdminBooks` | Cargar todos los libros (incluyendo ocultos) |
| `ToggleBookVisibility` | Publicar u ocultar un libro |
| `DeleteAdminBook` | Eliminar un libro (cooldown de 2 segundos) |

| Estado | Dato | Cuándo |
| ------ | ---- | ------ |
| `AdminInitial` | — | Inicial |
| `AdminLoading` | — | Obteniendo |
| `AdminLoaded` | `List<BookWithRelations> books, String? message` | Cargado |
| `AdminError` | `String message` | Error |

Reutiliza `GetBooks`, `ToggleBookVisibility`, `DeleteBook` del feature books.

### AdminUsersBloc (Pestaña Usuarios)

**Archivo**: `lib/features/admin/presentation/bloc/admin_users_bloc.dart`

| Evento | Descripción |
| ------ | ----------- |
| `LoadAdminUsers` | Cargar todos los perfiles de usuario |
| `ChangeUserRole` | Cambiar el rol de un usuario |
| `SuspendUser` | Alternar suspender/activar un usuario |

| Estado | Dato | Cuándo |
| ------ | ---- | ------ |
| `AdminUsersInitial` | — | Inicial |
| `AdminUsersLoading` | — | Obteniendo |
| `AdminUsersLoaded` | `List<UserEntity> users, String? message` | Cargado |
| `AdminUsersError` | `String message` | Error |

Autoprotección: no puede cambiar su propio rol ni suspenderse a sí mismo.

### AdminAnalyticsBloc (Pestaña Analíticas)

**Archivo**: `lib/features/admin/presentation/bloc/admin_analytics_bloc.dart`

| Evento | Descripción |
| ------ | ----------- |
| `LoadAnalytics` | Cargar resumen + tendencia + libros top |

| Estado | Dato | Cuándo |
| ------ | ---- | ------ |
| `AnalyticsInitial` | — | Inicial |
| `AnalyticsLoading` | — | Obteniendo |
| `AnalyticsLoaded` | `AnalyticsOverview overview, List<AnalyticsTrendEntry> trend, List<AnalyticsTopBook> topBooks` | Cargado |
| `AnalyticsError` | `String message` | Error |

## Pantallas

### AdminDashScreen

**Archivo**: `lib/features/admin/presentation/screens/admin_dash_screen.dart`

Dashboard con pestañas:

| Pestaña | Archivo de pantalla | Descripción |
| ------- | ------------------- | ----------- |
| Analíticas | analytics_tab.dart | Estadísticas, tendencia, libros top |
| Libros | `books_tab.dart` | Lista de libros con toggle de visibilidad |
| Géneros | `genres_tab.dart` | CRUD de géneros |
| Usuarios | `users_tab.dart` | Lista de usuarios: cambio de rol/suspensión |

## Registro en DI

**Archivo**: `lib/features/admin/di/injection_admin.dart`

- `AnalyticsRepository` → `LazySingleton`
- `AdminBloc` → `Factory` (depende de casos de uso de books)
- `AdminAnalyticsBloc` → `Factory`

**Nota**: `AdminUsersBloc` se crea en la pestaña de usuarios con
`GetAllProfiles` y `UpdateUserRole` del feature profiles.

## Relacionados

- [Books](../../es/features/books/README.md) — Casos de uso de gestión de libros
- [Profiles](../../es/features/profiles/README.md) — Casos de uso de gestión de
  usuarios
- [Tipos de usuario](../../es/user-types/admin-user.md) — Permisos de admin
- [Manejo de errores](../../es/architecture/error-handling.md) —
  `AnalyticsFailure`

← Volver al [índice](../../es/README.md)
