# Usuario Regular (`role = 'user'`) — Auditoría Completa

> **Fecha de auditoría**: 2026-07-21
> **Proyecto**: Noveles (Flutter + Supabase)
> **Roles en sistema**: `user`, `scan`, `admin`, `suspended`

---

## Tabla de Contenidos

1. [Definición y Modelo](#1-definición-y-modelo)
2. [Flujo de Autenticación](#2-flujo-de-autenticación)
3. [Pantallas y Navegación](#3-pantallas-y-navegación)
4. [Experiencia de Navegación
   (Home)](#4-experiencia-de-navegación-home)
5. [Detalle de Libro](#5-detalle-de-libro)
6. [Lector de Capítulos](#6-lector-de-capítulos)
7. [Gestión de Favoritos](#7-gestión-de-favoritos)
8. [Gestión de Perfil](#8-gestión-de-perfil)
9. [Interacciones con Supabase
   (RLS)](#9-interacciones-con-supabase-rls)
10. [BLoCs y Estado](#10-blocs-y-estado)
11. [Casos de Uso (Domain Layer)](#11-casos-de-uso-domain-layer)
12. [Restricciones vs Admin/Scan](#12-restricciones-vs-adminscan)
13. [Inyección de Dependencias](#13-inyección-de-dependencias)
14. [Archivos Relacionados (Lista
    Completa)](#14-archivos-relacionados-lista-completa)
15. [Hallazgos y Recomendaciones](#15-hallazgos-y-recomendaciones)

---

## 1. Definición y Modelo

### 1.1 UserRole

**Archivo**: `lib/features/profiles/domain/user_role.dart` (18 líneas)

```dart
enum UserRole {
  user,
  scan,
  admin,
  suspended;

  static UserRole fromString(String? role) {
    return switch (role) {
      'user' => UserRole.user,
      'scan' => UserRole.scan,
      'admin' => UserRole.admin,
      'suspended' => UserRole.suspended,
      _ => UserRole.user,
    };
  }
}
```

**`UserRole.user`** es el **valor por defecto** — tanto en el enum como en
`UserRole.fromString()`. Si la BD no tiene `role` o el valor es
desconocido/null, el usuario se convierte en `user`.

### 1.2 UserEntity

**Archivo**: `lib/features/profiles/domain/user_entity.dart` (53 líneas)

```dart
class UserEntity extends Equatable {
  final String id;       // UUID de Supabase Auth
  final String email;
  final UserRole role;   // UserRole enum: user, scan, admin, suspended
  final String? displayName;
  final String? bio;
  final String? avatarUrl;

  bool get isScan => role == UserRole.scan;         // Línea 21
  bool get isAdmin => role == UserRole.admin;       // Línea 22
  bool get isUser => role == UserRole.user;         // Línea 23
  bool get isSuspended => role == UserRole.suspended; // Línea 24
}
```

**Getters de rol**:

- `isUser` → `role == UserRole.user` (L23) — **el más relevante para este
  doc**
- `isScan` → `role == UserRole.scan` (L21)
- `isAdmin` → `role == UserRole.admin` (L22)
- `isSuspended` → `role == UserRole.suspended` (L24)

### 1.3 UserModel

**Archivo**: `lib/features/profiles/data/user_model.dart` (40 líneas)

```dart
factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: (json['email'] as String?) ?? '',
  role: UserRole.fromString(json['role'] as String?),  // Default: UserRole.user
  displayName: json['display_name'] as String?,
  bio: json['bio'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);
```

**Nota**: El `role` se mapea desde la tabla `profiles` (no de `auth.users`)
usando `UserRole.fromString()`. El default es `UserRole.user`.

### 1.4 Roles en Supabase

**Tabla `profiles`** — CHECK constraint:

```sql
CHECK (role IN ('user', 'scan', 'admin', 'suspended'))
```

**Trigger auto-create**: Cada usuario nuevo recibe `role = 'user'` por
defecto al registrarse. Un admin debe promoverlo a `'scan'` o `'admin'`
manualmente.

### 1.5 Fuente de Datos

| Campo | Tipo | Origen |
| ----- | ---- | ------ |
| `id` | `String` (UUID) | `auth.users.id` |
| `email` | `String` | `auth.users.email` |
| `role` | `String` | `profiles.role` (default `'user'`) |
| `display_name` | `String?` | `profiles.display_name` |
| `bio` | `String?` | `profiles.bio` |
| `avatar_url` | `String?` | `profiles.avatar_url` |

---

## 2. Flujo de Autenticación

### 2.1 AuthBloc

**Archivo**: `lib/features/auth/presentation/bloc/auth_bloc.dart` (115
líneas)

El `AuthBloc` maneja login, registro, logout y verificación de sesión.
**No distingue roles** — simplemente emite `AuthAuthenticated(user)` con
el `UserEntity` completo.

**5 casos de uso inyectados**:

| Caso de uso | Tipo | Descripción |
| ----------- | ---- | ----------- |
| `Login` | Autenticación | Login con email/password |
| `Register` | Autenticación | Registro con email/password |
| `Logout` | Autenticación | Cerrar sesión |
| `GetCurrentUser` | Sesión | Verificar sesión existente |
| `ListenAuthState` | Listener | Escuchar cambios de auth |

**4 eventos**:

| Evento | Acción | Estado resultante |
| ------ | ------ | ----------------- |
| `CheckAuthSession` | Verifica sesión | `Auth...` o `Unauth...` |
| `LoginRequested(email, password)` | Login | `AuthAuthenticated(user)` |
| `RegisterRequested(email, password)` | Registro | `AuthAuthenticated(user)` |
| `LogoutRequested` | Logout | `AuthUnauthenticated()` |

**3 estados**:

| Estado | Datos |
| ------ | ----- |
| `AuthInitial` | — |
| `AuthLoading` | — |
| `AuthAuthenticated` | `user: UserEntity` |
| `AuthUnauthenticated` | — |
| `AuthError` | `message: String` |

### 2.2 Listener de Cambios de Auth

```dart
_authSubscription = listenAuthState().listen((event) {
  if (event == domain.AuthEvent.signedOut && !_manualLogoutInProgress) {
    add(LogoutRequested());
  }
});
```

El `ListenAuthState` se suscribe a eventos de Supabase Auth. Si la sesión
expira o el usuario cierra sesión desde otro dispositivo, se dispara
`LogoutRequested` automáticamente (excepto durante un logout manual).

### 2.3 Routing por Rol (CRÍTICO)

**Archivo**: `lib/core/app/app.dart` (76 líneas), líneas 54-63:

```dart
if (authState is AuthAuthenticated) {
  if (authState.user.isAdmin) {
    return const AdminDashScreen();    // ← Admin va al dashboard
  }
  if (authState.user.isScan) {
    return const ScanMainScreen();     // ← Scan va a su panel
  }
  if (authState.user.isUser) {
    return const MainScreen();         // ← User va a home de lectura
  }
  return const LoginScreen();          // ← Fallback
}
```

**Prioridad**: Admin primero → Scan segundo → User tercero.

**Flujo del usuario regular**: Login → `AuthAuthenticated` →
`isUser == true` → `MainScreen`

**No hay pantalla de bienvenida, onboarding, ni selección.** El usuario
es redirigido automáticamente a `MainScreen`.

### 2.4 Persistencia de Sesión

Supabase maneja la persistencia de sesión automáticamente. Al reiniciar
la app, `CheckAuthSession` llama `getCurrentUser()` para verificar si hay
una sesión válida.

---

## 3. Pantallas y Navegación

### 3.1 MainScreen — Pantalla Principal

**Archivo**: `lib/features/app/presentation/screens/main_screen.dart`
(240 líneas)

Pantalla de inicio del usuario regular. Muestra libros destacados y
géneros.

**Componentes**:

- `MultiBlocProvider`: provee `BookBloc` (con `onlyVisible: true`) y
  `GenreBloc`
- `Scaffold` con `Drawer` (`AppDrawer`)
- `CustomScrollView` con `SliverAppBar` (carousel) y chips de géneros
- Infinite scroll vía `ScrollController`

**Lo que ve el usuario**:

- **Carousel** de libros destacados (auto-play) con cover, nombre, autor
  y labels
- **Chips de géneros** en scroll horizontal — tap para filtrar
- **Loading states**: `CircularProgressIndicator` mientras carga
- **Error state**: Mensaje de error + botón reintentar
- **Empty state**: "No hay libros disponibles"

### 3.2 BookScreen — Detalle de Libro

**Archivo**: `lib/features/books/presentation/screens/book_screen.dart`
(92 líneas)

Pantalla de detalle de un libro con pestañas de información y tomos.

**Componentes**:

- `NestedScrollView` con `SliverAppBarBook` (cover con blur) y
  `SliverPersistentHeaderBook` (tabs)
- `TabBarView` con 2 pestañas: "Info" y "Took"
- `DetailView`: información del libro + `FavoriteButton`
- `TookView`: lista de tomos

**Interacciones**:

- Tap en un tomo → navega a `TookScreen`
- Tap en "Abrir enlace" → abre URL externa
- Tap en `FavoriteButton` → toggle favorito
- Scroll para ocultar/mostrar AppBar (auto-hide)

**Tracking**: Después de 2 segundos en la pantalla, se registra una vista
del libro vía `TrackBookView`.

### 3.3 GenreScreen — Filtro por Género

**Archivo**: `lib/features/genres/presentation/screens/genre_screen.dart`
(109 líneas)

Pantalla que muestra libros filtrados por un género específico.

**Componentes**:

- `AppBar` con título del género
- `GridView` de 2 columnas con portadas de libros
- Cada card muestra cover + nombre del libro
- `EmptyState` si no hay libros para ese género

**Nota**: Los libros se filtran localmente — se pasan todos los libros
disponibles y se filtran por `listGenre.any((g) => g.name == genre)`.
No hay petición adicional a Supabase.

### 3.4 TookScreen — Lista de Capítulos

**Archivo**: `lib/features/tooks/presentation/screens/took_screen.dart`
(64 líneas)

Pantalla que muestra los capítulos de un tomo específico.

**Componentes**:

- `SliverAppBar` con número del tomo
- `SliverList.builder` con capítulos
- Cada `ListTile` muestra título y número del capítulo

**Interacciones**:

- Tap en capítulo → navega a `ChapterScreen` con el índice y la lista
  completa de capítulos

**Nota**: Los capítulos se obtienen del `TookModel` via cast runtime:
`(widget.tooks as TookModel).chapters`. Esto significa que los datos
deben venir hidratados desde la consulta padre.

### 3.5 ChapterScreen — Lector de Capítulo

**Archivo**: `lib/features/chapters/presentation/screens/chapter_screen.dart`
(167 líneas)

Pantalla de lectura de capítulos con soporte para swiping entre capítulos.

**Componentes**:

- `BlocListener` para errores
- `PageView.builder` con swiping entre capítulos
- `CustomScrollView` con `SliverAppBar` (número de capítulo) y contenido
- Modo inmersivo: `SystemUiMode.immersive` al entrar,
  `SystemUiMode.edgeToEdge` al salir

**Interacciones**:

- Swipe izquierda/derecha para cambiar de capítulo
- Scroll para ocultar/mostrar AppBar (auto-hide)

### 3.6 ProfileScreen — Edición de Perfil

**Archivo**:
`lib/features/profiles/presentation/screens/profile_screen.dart`
(180 líneas)

Pantalla de edición de perfil. **Común a todos los roles**.

**Componentes**:

- `AvatarSection`: muestra avatar actual o preview de nuevo avatar
- Email del usuario (solo lectura)
- `ProfileEditForm`: campos display name y bio
- `PasswordChangeForm`: cambiar contraseña
- `LogoutSection`: botón de cerrar sesión

**Interacciones**:

- Tap en avatar → `ImagePicker` (galería) → preview del nuevo avatar
- Editar display name y bio → tap "Guardar"
- Cambiar contraseña → formulario con validación de coincidencia
- Cerrar sesión → dispara `LogoutRequested`

### 3.7 FavoritesScreen — Lista de Favoritos

**Archivo**:
`lib/features/favorites/presentation/screens/favorites_screen.dart`
(128 líneas)

Pantalla que muestra la lista de libros marcados como favoritos.

**Componentes**:

- `AppBar` con título "Mis Favoritos"
- `ListView.builder` de favoritos
- Cada `ListTile` muestra cover (via `FutureBuilder`), nombre y autor

**Interacciones**:

- Tap en favorito → (actualmente solo muestra datos, sin navegación)
- Pull-to-refresh no implementado

**Carga**: Cada favorito consulta su libro via `BookRepository.getBookById()`
usando `FutureBuilder`, lo que puede causar múltiples llamadas a la BD.

### 3.8 AppDrawer — Menú Lateral

**Archivo**: `lib/features/app/presentation/widgets/app_drawer.dart`
(162 líneas)

El drawer acepta `isScan` y `isAdmin` como parámetros.

**Para usuario regular** (`isScan: false`, `isAdmin: false`):

```text
┌─────────────────────────┐
│  Avatar + Nombre        │
│  Email                  │
├─────────────────────────┤
│  🏠 Inicio              │  ← cierra el drawer (ya está en MainScreen)
│  👤 Editar Perfil       │
│  ❤ Mis Favoritos        │
├─────────────────────────┤
│  🚪 Cerrar Sesión       │
└─────────────────────────┘
```

**No tiene** acceso a:

- "Panel Admin" (solo visible si `isAdmin = true`)
- "Panel Scan" (solo visible si `isScan = true`)
- "Etiquetas" (solo visible si `isScan = true`)

**Routing del drawer**:

| Item | Icono | Destino |
| ---- | ---- | ------- |
| Inicio | `Icons.home` | Cierra drawer (permanece en `MainScreen`) |
| Editar Perfil | `Icons.person` | `ProfileScreen` |
| Mis Favoritos | `Icons.favorite` | `FavoritesScreen` |
| Cerrar Sesión | `Icons.logout` | Dialog de confirmación → `LogoutRequested` |

### 3.9 Rutas Navegables

**Archivo**: `lib/core/app/app.dart` (76 líneas)

```dart
routes: {
  '/label-management': (_) => const LabelManagementScreen(),
  '/admin': (_) => const AdminDashScreen(),
}
```

**Nota**: Las rutas `/label-management` y `/admin` están registradas pero
son inaccesibles para el usuario regular — no hay forma de llegar a ellas
desde la UI.

---

## 4. Experiencia de Navegación (Home)

### 4.1 Carousel de Libros Destacados

**Archivo**:
`lib/features/app/presentation/widgets/carousel_appbar_sliver.dart`
(116 líneas)

El `SliverAppBarHome` muestra un carousel automático de libros:

- **Widget**: `CarouselSlider.builder` con `autoPlay: true`
- **Altura**: 240.0px
- **ViewPortFraction**: 1.0 (pantalla completa)
- **Contenido por slide**: cover (con `CachedNetworkImage`), gradiente
  superpuesto, nombre del libro, autor, badges de labels
- **Tap**: navega a `BookScreen` con transición de 1 segundo

### 4.2 Chips de Géneros

Se renderizan como `Chip` dentro de un `ListView` horizontal de 60px de
altura. Cada chip muestra el nombre del género.

**Al tocar un chip**:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => GenreScreen(
      genre: item.name,
      books: listBook,
      coverUrlService: getIt<CoverUrlService>(),
    ),
  ),
);
```

Se pasa la lista completa de libros y el `CoverUrlService` para que
`GenreScreen` filtre localmente.

### 4.3 Infinite Scroll (Paginación)

**Archivo**: `lib/features/app/presentation/screens/main_screen.dart`,
líneas 40-48

```dart
void _onScroll() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 200) {
    final bookState = context.read<BookBloc>().state;
    if (bookState is BookLoaded && bookState.hasMore) {
      _currentPage++;
      context.read<BookBloc>().add(LoadMoreBooks(_currentPage));
    }
  }
}
```

**Comportamiento**:

- Se detecta cuando el usuario está a 200px del final de la lista
- Se incrementa `_currentPage` y se dispara `LoadMoreBooks`
- `BookBloc` usa `onlyVisible: true` y `pageSize: 50`
- `hasMore` se determina si la respuesta tiene `>= 50` elementos
- Se muestra `CircularProgressIndicator` al final mientras carga

### 4.4 Book Cards en el Carousel

Cada slide del carousel muestra:

| Elemento | Fuente | Widget |
| -------- | ------ | ------ |
| Cover | `book.cover` → `CoverUrlService` | `CachedNetworkImage` |
| Nombre | `book.name` | `Text` con `labelLarge` |
| Autor | `book.author` | `Text` con `labelSmall` |
| Labels | `book.listLabel` | `LabelBadge` widgets |

### 4.5 States del BookBloc en Home

| Estado | Widget mostrado |
| ------ | --------------- |
| `BookLoading` / `GenreLoading` | `CircularProgressIndicator` centrado |
| `BookError` | Mensaje de error + botón "Reintentar" |
| `GenreError` | Mensaje de error + botón "Reintentar" |
| `BookLoaded` + `GenreLoaded` | Carousel + chips + infinite scroll |
| Lista vacía | `EmptyState` ("No hay libros disponibles") |

---

## 5. Detalle de Libro

### 5.1 BookScreen

**Archivo**: `lib/features/books/presentation/screens/book_screen.dart`
(92 líneas)

Usa `SingleTickerProviderStateMixin` para el `TabController` con 2
pestañas: "Info" y "Took".

**Componentes clave**:

- `SliverAppBarBook`: cover con efecto blur, nombre y autor
- `SliverPersistentHeaderBook`: headers de tabs sticky
- `DetailView`: pestaña de información
- `TookView`: pestaña de tomos

**Auto-hide del AppBar**:

```dart
_scrollController.addListener(() {
  setState(() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      isVisible = false;
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      isVisible = true;
    }
  });
});
```

### 5.2 BookWithRelations

**Archivo**: `lib/shared/domain/entities/book_with_relations.dart`
(109 líneas)

Extiende `BookEntity` agregando listas de entidades hidratadas:

```dart
class BookWithRelations extends BookEntity {
  final List<GenreEntity> listGenre;
  final List<TookEntity> listTook;
  final List<LabelEntity> listLabel;
}
```

**Campos heredados de BookEntity**:

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `id` | `int` | ID de Supabase |
| `createdAt` | `DateTime` | Fecha de creación |
| `cover` | `String` | Filename en Storage o URL externa |
| `name` | `String` | Nombre del libro |
| `short` | `String` | Nombre corto |
| `alternative` | `String` | Nombre alternativo |
| `description` | `String` | Descripción |
| `authorId` | `int` | FK al autor |
| `author` | `String` | Nombre del autor |
| `country` | `String` | País de origen |
| `state` | `String` | Emisión/Finalizado/Pausado/Abandonado |
| `type` | `String` | Web/Ligera |
| `release` | `String` | Fecha de lanzamiento |
| `tookCount` | `int` | Cantidad de tomos |
| `chapterCount` | `int` | Cantidad de capítulos |
| `source` | `String` | Fuente de la novela |
| `link` | `String` | Enlace externo |
| `isFavorite` | `bool` | Si es favorito del usuario actual |
| `isVisible` | `bool` | Si es visible para usuarios |
| `createdBy` | `String?` | UUID del scan que lo creó |

### 5.3 Detalle View (Pestaña Info)

**Archivo**: `lib/features/books/presentation/views/detail/detail_view.dart`
(150 líneas)

Muestra información completa del libro:

| Sección | Contenido |
| ------- | --------- |
| Descripción | Texto descriptivo + `FavoriteButton` |
| Publicado / Tipo | `CardInfoDetail` |
| País / Estado | `CardInfoDetail` |
| Tomos / Capítulos | `CardInfoDetail` |
| Géneros | `Wrap` de `Chip` con nombre de género |
| Fuente / Enlace | `CardInfoDetail` + link clickeable |

**FavoriteButton** se muestra al lado del título "Descripción".

### 5.4 Took View (Pestaña Tomos)

**Archivo**: `lib/features/tooks/presentation/views/took_view.dart`
(80 líneas)

Lista de tomos del libro:

- `ListView.builder` con `Card` + `ListTile` por cada tomo
- Muestra: número del tomo, título, cantidad de capítulos
- Tap → navega a `TookScreen` con el tomo seleccionado

### 5.5 Tracking de Vistas

```dart
Future.delayed(const Duration(seconds: 2), () {
  if (mounted) {
    GetIt.instance<TrackBookView>()(widget.book.id);
  }
});
```

Después de 2 segundos en `BookScreen`, se registra una vista del libro.
Usa `TrackBookView` → `BookRepository.trackBookView()`.

**Nota**: Solo funciona si el usuario tiene el rol que permita INSERT en
`book_views`. Para usuarios regulares, la política RLS de `book_views`
requiere `is_admin()`, por lo que **el tracking no funciona para usuarios
regulares** — la inserción falla silenciosamente.

---

## 6. Lector de Capítulos

### 6.1 ChapterScreen

**Archivo**: `lib/features/chapters/presentation/screens/chapter_screen.dart`
(167 líneas)

Pantalla de lectura inmersiva con swiping entre capítulos.

**Inicialización**:

```dart
SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
context.read<ChapterBloc>().add(
  LoadChapterContent(
    initialIndex: widget.i,
    chapters: widget.chapters.map(ChapterRef.fromEntity).toList(),
  ),
);
```

**Comportamiento**:

- Entra en modo inmersivo (oculta barra de estado y navegación)
- Carga todos los contenidos de capítulos en paralelo
- `PageView.builder` permite swipe izquierda/derecha
- Cada página muestra: número de capítulo, título, contenido
- Al salir, restaura `SystemUiMode.edgeToEdge`

### 6.2 ChapterBloc

**Archivo**: `lib/features/chapters/presentation/bloc/chapter_bloc.dart`
(53 líneas)

**1 caso de uso inyectado**:

| Caso de uso | Tipo | Descripción |
| ----------- | ---- | ----------- |
| `GetChapterContent` | Lectura | Descarga de Storage o retorna inline |

**1 evento**:

| Evento | Acción | Estado resultante |
| ------ | ------ | ----------------- |
| `LoadChapterContent` | Descarga en paralelo | `ChapterLoaded` |

**3 estados**:

| Estado | Datos |
| ------ | ----- |
| `ChapterInitial` | — |
| `ChapterLoading` | — |
| `ChapterLoaded` | `chapters: List<ChapterEntity>`, `initialIndex: int` |
| `ChapterError` | `message: String` |

### 6.3 Carga de Contenido (Paralela)

```dart
final contentResults = await Future.wait(
  event.chapters.map((ch) => getChapterContent(ch.content)),
);
```

**Flujo de descarga** en `ChapterRepositoryImpl.downloadContent()`:

1. Verifica si `content` es un path de Storage o contenido inline
2. Si es inline (no contiene `/` ni termina en `.txt`/`.json`), lo
   retorna directamente
3. Verifica `ChapterCache.read(path)` — si está en cache, retorna
4. Si no está en cache, descarga de Supabase Storage
5. Guarda en `ChapterCache.save(path, bytes)` para futuras lecturas

### 6.4 ChapterCache

**Archivo**: `lib/core/supabase/chapter_cache.dart` (42 líneas)

Cache local de capítulos para lectura offline:

```dart
class ChapterCache {
  static Future<bool> has(String filename) async { ... }
  static Future<String?> read(String filename) async { ... }
  static Future<void> save(String filename, List<int> bytes) async { ... }
}
```

- **Ubicación**: `{appDir}/chapters_cache/`
- **Formato**: archivos raw bytes (decodificados a UTF-8 al leer)
- **Estrategia**:写入后永不过期 — no hay TTL ni invalidación

### 6.5 ChapterRef

**Archivo**: `lib/features/chapters/domain/chapter_ref.dart` (34 líneas)

Referencia ligera para eventos del BLoC — evita pasar `ChapterEntity`
completo por el event bus:

```dart
class ChapterRef extends Equatable {
  final int id;
  final String content;  // URL de Storage o contenido inline
  final String number;
  final String title;
  final int tookId;
}
```

---

## 7. Gestión de Favoritos

### 7.1 FavoriteBloc

**Archivo**: `lib/features/favorites/presentation/bloc/favorite_bloc.dart`
(65 líneas)

**3 eventos**:

| Evento | Campos | Acción |
| ------ | ------ | ------ |
| `ToggleFavorite` | `userId`, `bookId` | Agrega/quita de favoritos |
| `LoadFavorites` | `userId` | Carga todos los favoritos del usuario |
| `CheckFavoriteStatus` | `userId`, `bookId` | Verifica si libro es favorito |

**5 estados**:

| Estado | Datos |
| ------ | ----- |
| `FavoriteInitial` | — |
| `FavoriteLoading` | — |
| `FavoriteLoaded` | `favorites: List<FavoriteEntity>` |
| `FavoriteStatusChecked` | `isFavorite: bool` |
| `FavoriteToggled` | `isFavorite: bool` |
| `FavoriteError` | `message: String` |

### 7.2 FavoriteEntity

**Archivo**: `lib/features/favorites/domain/favorite_entity.dart` (16
líneas)

```dart
class FavoriteEntity extends Equatable {
  final String userId;    // UUID del usuario
  final int bookId;       // ID del libro
  final DateTime createdAt;
}
```

### 7.3 FavoriteRepository

**Archivo**: `lib/features/favorites/domain/favorite_repository.dart`
(8 líneas)

```dart
abstract class FavoriteRepository {
  Future<Result<bool>> toggleFavorite(String userId, int bookId);
  Future<Result<List<FavoriteEntity>>> getFavorites(String userId);
  Future<Result<bool>> isFavorite(String userId, int bookId);
}
```

### 7.4 FavoriteButton Widget

**Archivo**:
`lib/features/favorites/presentation/widgets/favorite_button.dart`
(75 líneas)

Widget reutilizable que muestra un ícono de corazón:

- **Estado**: `Icons.favorite` (rojo) o `Icons.favorite_border`
- **Inicialización**: dispara `CheckFavoriteStatus` al montar
- **Tap**: dispara `ToggleFavorite` → actualiza estado visual
- **Uso**: se encuentra en `DetailView` (pestaña Info de `BookScreen`)

### 7.5 FavoritesScreen

**Archivo**:
`lib/features/favorites/presentation/screens/favorites_screen.dart`
(128 líneas)

Lista de libros favoritos del usuario:

- Carga favoritos al `initState` via `LoadFavorites(userId)`
- Cada favorito consulta su `BookWithRelations` via `FutureBuilder`
- Muestra: cover (via `CircleAvatar`), nombre, autor
- Estado vacío: "No tienes favoritos aún"

**Nota de performance**: Cada `ListTile` hace una consulta independiente
a `BookRepository.getBookById()`. Con muchos favoritos, esto genera
múltiples round-trips a la BD.

---

## 8. Gestión de Perfil

### 8.1 ProfileScreen

**Archivo**:
`lib/features/profiles/presentation/screens/profile_screen.dart`
(180 líneas)

**Común a todos los roles** — admin, scan y user usan la misma pantalla.

**Secciones**:

1. **Avatar**: preview con opción de cambiar (galería)
2. **Email**: solo lectura
3. **Formulario**: display name + bio
4. **Contraseña**: formulario de cambio
5. **Cerrar sesión**: botón con confirmación

### 8.2 ProfileBloc

**Archivo**:
`lib/features/profiles/presentation/bloc/profile_bloc.dart` (113 líneas)

**4 casos de uso inyectados**:

| Caso de uso | Tipo | Descripción |
| ----------- | ---- | ----------- |
| `GetProfile` | Lectura | Carga perfil propio |
| `UpdateProfile` | Escritura | Actualiza display name, bio, avatar |
| `UploadAvatar` | Escritura | Sube avatar a Supabase Storage |
| `ChangePassword` | Escritura | Cambia contraseña via Supabase Auth |

**4 eventos**:

| Evento | Campos | Acción |
| ------ | ------ | ------ |
| `LoadProfile` | — | Carga perfil del usuario actual |
| `UpdateProfile` | `displayName?`, `bio?` | Actualiza perfil |
| `PickAvatar` | `filePath` | Selecciona imagen para avatar |
| `ChangePassword` | `newPassword` | Cambia contraseña |

**5 estados**:

| Estado | Datos |
| ------ | ----- |
| `ProfileInitial` | — |
| `ProfileLoading` | — |
| `ProfileLoaded` | `user`, `pendingAvatarPath?`, `message?` |
| `ProfileSaving` | `user` |
| `ProfileError` | `message`, `user?` |

### 8.3 Flujo de Cambio de Avatar

```text
User tap avatar → ImagePicker.pickImage(source: gallery)
  → ProfileBloc.add(PickAvatar(filePath))
    → ProfileLoaded(user, pendingAvatarPath: filePath)
      → Preview del nuevo avatar en AvatarSection
        → User tap "Guardar" → ProfileBloc.add(UpdateProfile(...))
          → uploadAvatar(pendingAvatarPath) → Supabase Storage 'avatars/'
          → updateProfile(displayName, bio, avatarUrl)
          → ProfileLoaded(user, message: 'Perfil actualizado')
```

### 8.4 Flujo de Cambio de Contraseña

```text
User completa formulario → ProfileBloc.add(ChangePassword(newPassword))
  → ProfileSaving(user)
    → changePassword(newPassword) → Supabase Auth
    → ProfileLoaded(user, message: 'Contraseña actualizada')
```

### 8.5 Limitaciones del Perfil

El usuario regular **NO puede**:

- ❌ Cambiar su propio rol
- ❌ Editar el perfil de otro usuario
- ❌ Ver su rol en la pantalla de perfil
- ❌ Eliminar su cuenta

---

## 9. Interacciones con Supabase (RLS)

### 9.1 Resumen de Políticas Activas para User

#### Tabla `profiles`

| Política | Operación | Condición |
| -------- | --------- | --------- |
| "Users can read own profile" | SELECT | `auth.uid() = id` |
| "Users can insert own profile" | INSERT | `auth.uid() = id` |
| "Users can update own profile" | UPDATE | `auth.uid() = id` |

**User puede**: Leer, insertar y actualizar SOLO su propio perfil.

#### Tabla `books`

| Política | Operación | Condición |
| -------- | --------- | --------- |
| "Users can read visible" | SELECT | `is_visible AND NOT is_scan()` |

**User puede**: Solo leer libros donde `is_visible = true`.
**User NO puede**: INSERT, UPDATE, DELETE en libros.

#### Tabla `chapters`

| Política | Operación | Condición |
| -------- | --------- | --------- |
| "Enable read for all users" | SELECT | `true` |

**User puede**: Leer capítulos.
**User NO puede**: INSERT, UPDATE, DELETE.

#### Tabla `tooks`

| Política | Operación | Condición |
| -------- | --------- | --------- |
| "Enable read for all users" | SELECT | `true` |

**User puede**: Leer tomos.
**User NO puede**: INSERT, UPDATE, DELETE.

#### Tabla `genres`

| Política | Operación | Condición |
| -------- | --------- | --------- |
| "Enable read for all users" | SELECT | `true` |

**User puede**: Leer géneros.
**User NO puede**: INSERT, UPDATE, DELETE.

#### Tabla `labels`

| Política | Operación | Condición |
| -------- | --------- | --------- |
| "Enable read for all users" | SELECT | `true` |

**User puede**: Leer etiquetas.
**User NO puede**: INSERT, UPDATE, DELETE.

#### Tabla `books_genres`

| Política | Operación | Condición |
| -------- | --------- | --------- |
| "Enable read for all users" | SELECT | `true` |

**User puede**: Leer relaciones libro-género.
**User NO puede**: INSERT, UPDATE, DELETE.

#### Tabla `books_labels`

| Política | Operación | Condición |
| -------- | --------- | --------- |
| "Enable read for all users" | SELECT | `true` |

**User puede**: Leer relaciones libro-etiqueta.
**User NO puede**: INSERT, DELETE.

#### Tabla `authors`

| Política | Operación | Condición |
| -------- | --------- | --------- |
| "Enable read for all users" | SELECT | `true` |

**User puede**: Leer autores.
**User NO puede**: INSERT, UPDATE, DELETE.

#### Tabla `book_views`

| Política | Operación | Condición |
| -------- | --------- | --------- |
| "Admin can insert book views" | INSERT | `is_admin()` |
| "Admin can read book views" | SELECT | `is_admin()` |

**User NO tiene acceso** a la tabla de analytics.

### 9.2 Storage (Supabase Storage)

| Bucket | Operación | User puede |
| ------ | --------- | ---------- |
| `covers` | SELECT | ✅ (public read) |
| `covers` | INSERT | ✅ (authenticated) |
| `covers` | UPDATE | ✅ (authenticated) |
| `covers` | DELETE | ✅ (authenticated) |
| `chapters` | SELECT | ✅ (public read) |
| `chapters` | INSERT | ✅ (authenticated) |
| `chapters` | UPDATE | ✅ (authenticated) |
| `chapters` | DELETE | ✅ (authenticated) |
| `avatars` | SELECT | ✅ (public read) |
| `avatars` | INSERT | ✅ (authenticated, own folder) |
| `avatars` | UPDATE | ✅ (authenticated, own folder) |

**⚠️ Hallazgo de seguridad**: Los buckets `covers` y `chapters` permiten
INSERT/UPDATE/DELETE a **cualquier usuario autenticado**. Un usuario
regular podría subir archivos a estos buckets, aunque la app no expone UI
para ello.

### 9.3 Resumen de Acciones del User

**✅ PUEDE hacer**:

1. Ver libros visibles (`is_visible = true`)
2. Leer detalles de libros (info, géneros, tomos, capítulos)
3. Leer capítulos completos (descarga de Storage)
4. Gestionar favoritos propios (toggle, listar)
5. Editar su propio perfil (display name, bio, avatar)
6. Cambiar su contraseña
7. Filtrar libros por género

**❌ NO PUEDE hacer**:

1. Crear, editar o eliminar libros
2. Crear, editar o eliminar capítulos
3. Crear, editar o eliminar tomos
4. Crear, editar o eliminar géneros
5. Crear, editar o eliminar etiquetas
6. Ver libros ocultos
7. Ver la lista de todos los usuarios
8. Cambiar roles de usuarios
9. Ver analytics (book_views)
10. Subir covers (RLS lo permite pero no hay UI)
11. Acceder al panel admin o panel scan

---

## 10. BLoCs y Estado

### 10.1 Diagrama de BLoCs del User

```text
MainScreen (Home)
├── BookBloc (libros, onlyVisible: true)
│   ├── Eventos: LoadBooks, LoadMoreBooks, LoadBookById
│   ├── Estados: BookInitial, BookLoading, BookLoaded, BookDetailLoaded, BookError
│   └── Use Cases: GetBooks, GetBookById
│
├── GenreBloc (géneros)
│   ├── Eventos: LoadGenres
│   ├── Estados: GenreInitial, GenreLoading, GenreLoaded, GenreError
│   └── Use Cases: GetGenre
│
BookScreen (Detalle)
└── (recibe BookWithRelations como parámetro, no crea BLoC propio)

TookScreen (Capítulos)
└── (recibe TookEntity como parámetro)

ChapterScreen (Lector)
└── ChapterBloc
    ├── Eventos: LoadChapterContent
    ├── Estados: ChapterInitial, ChapterLoading, ChapterLoaded, ChapterError
    └── Use Cases: GetChapterContent

ProfileScreen (Perfil)
└── ProfileBloc
    ├── Eventos: LoadProfile, UpdateProfile, PickAvatar, ChangePassword
    ├── Estados: ProfileInitial, ProfileLoading, ProfileLoaded, ProfileSaving, ProfileError
    └── Use Cases: GetProfile, UpdateProfile, UploadAvatar, ChangePassword

FavoritesScreen (Favoritos)
└── FavoriteBloc
    ├── Eventos: ToggleFavorite, LoadFavorites, CheckFavoriteStatus
    ├── Estados: FavoriteInitial, FavoriteLoading, FavoriteLoaded,
    │           FavoriteStatusChecked, FavoriteToggled, FavoriteError
    └── Use Cases: (FavoriteRepository directamente)
```

### 10.2 BookBloc

**Archivo**: `lib/features/books/presentation/bloc/book_bloc.dart`
(88 líneas)

**Configuración especial** para user: se instancia con `onlyVisible: true`
en `MainScreen` (L59). Esto filtra solo libros visibles.

**Nota**: En el admin, `BookBloc` se instancia SIN `onlyVisible` (default
`false`), por lo que ve todos los libros.

**Page size**: 50 (`static const int pageSize = 50`)

### 10.3 GenreBloc

**Archivo**: `lib/features/genres/presentation/bloc/genre_bloc.dart`
(111 líneas)

El mismo `GenreBloc` se usa tanto en `MainScreen` (home) como en
`GenresTab` del admin. Para el usuario regular, solo se usa el evento
`LoadGenres`.

### 10.4 ChapterBloc

**Archivo**: `lib/features/chapters/presentation/bloc/chapter_bloc.dart`
(53 líneas)

BLoC ligero — solo 1 evento (`LoadChapterContent`). Carga todos los
contenidos en paralelo via `Future.wait`.

### 10.5 ProfileBloc

**Archivo**:
`lib/features/profiles/presentation/bloc/profile_bloc.dart` (113 líneas)

Maneja carga, edición de perfil, avatar y contraseña. No tiene lógica
específica para ningún rol — es el mismo para todos.

### 10.6 FavoriteBloc

**Archivo**: `lib/features/favorites/presentation/bloc/favorite_bloc.dart`
(65 líneas)

Maneja toggle, carga y verificación de estado de favoritos. Opera sobre
una tabla independiente que usa `userId` + `bookId`.

---

## 11. Casos de Uso (Domain Layer)

### 11.1 Books Domain

**Directorio**: `lib/features/books/domain/`

| Caso de uso | Archivo | Usado por user |
| ----------- | ------- | -------------- |
| `GetBooks` | `get_book.dart` | ✅ (BookBloc, `onlyVisible: true`) |
| `GetBookById` | `get_book_by_id.dart` | ✅ (BookBloc + FavoritesScreen) |
| `GetBooksByGenre` | `get_books_by_genre.dart` | ❌ (no usado en UI) |
| `GetBookLabels` | `get_book_labels.dart` | ❌ |
| `CreateBook` | `create_book.dart` | ❌ |
| `UpdateBook` | `update_book.dart` | ❌ |
| `DeleteBook` | `delete_book.dart` | ❌ |
| `UploadImage` | `upload_image.dart` | ❌ |
| `ToggleBookVisibility` | `toggle_book_visibility.dart` | ❌ |
| `TrackBookView` | `track_book_view.dart` | ✅ (falla por RLS) |

### 11.2 Chapters Domain

**Directorio**: `lib/features/chapters/domain/`

| Caso de uso | Archivo | Usado por user |
| ----------- | ------- | -------------- |
| `GetChapters` | `get_chapter.dart` | ❌ (capítulos vienen via join) |
| `GetChapterById` | `get_chapter_by_id.dart` | ❌ |
| `GetChapterContent` | `get_chapter_content.dart` | ✅ (ChapterBloc) |
| `CreateChapter` | `create_chapter.dart` | ❌ |
| `UpdateChapter` | `update_chapter.dart` | ❌ |
| `DeleteChapter` | `delete_chapter.dart` | ❌ |
| `UploadChapterContent` | `upload_chapter_content.dart` | ❌ |

### 11.3 Genres Domain

**Directorio**: `lib/features/genres/domain/`

| Caso de uso | Archivo | Usado por user |
| ----------- | ------- | -------------- |
| `GetGenre` | `get_genre.dart` | ✅ (GenreBloc en MainScreen) |
| `GetGenreById` | `get_genre_by_id.dart` | ❌ |
| `CreateGenre` | `create_genre.dart` | ❌ |
| `UpdateGenre` | `update_genre.dart` | ❌ |
| `DeleteGenre` | `delete_genre.dart` | ❌ |

### 11.4 Profiles Domain

**Directorio**: `lib/features/profiles/domain/`

| Caso de uso | Archivo | Usado por user |
| ----------- | ------- | -------------- |
| `GetProfile` | `get_profile.dart` | ✅ (ProfileBloc) |
| `UpdateProfile` | `update_profile.dart` | ✅ (ProfileBloc) |
| `UploadAvatar` | `upload_avatar.dart` | ✅ (ProfileBloc) |
| `ChangePassword` | `change_password.dart` | ✅ (ProfileBloc) |
| `GetAllProfiles` | `get_all_profiles.dart` | ❌ |
| `UpdateUserRole` | `update_user_role.dart` | ❌ |

### 11.5 Auth Domain

**Directorio**: `lib/features/auth/domain/use_cases/`

| Caso de uso | Archivo | Usado por user |
| ----------- | ------- | -------------- |
| `Login` | `login.dart` | ✅ (AuthBloc) |
| `Register` | `register.dart` | ✅ (AuthBloc) |
| `Logout` | `logout.dart` | ✅ (AuthBloc) |
| `GetCurrentUser` | `get_current_user.dart` | ✅ (AuthBloc) |
| `ListenAuthState` | `listen_auth_state.dart` | ✅ (AuthBloc) |

### 11.6 Took Domain

**Directorio**: `lib/features/tooks/domain/`

| Caso de uso | Archivo | Usado por user |
| ----------- | ------- | -------------- |
| `GetTooks` | `get_took.dart` | ❌ (tomos vienen via join) |
| `GetTookById` | `get_took_by_id.dart` | ❌ |
| `GetTooksByBook` | `get_tooks_by_book.dart` | ❌ |
| `CreateTook` | `create_took.dart` | ❌ |
| `UpdateTook` | `update_took.dart` | ❌ |
| `DeleteTook` | `delete_took.dart` | ❌ |

**Nota**: Los tomos y capítulos se cargan como parte del join de
`getBooks()` → `tooks(*, chapters(*))`, no vía casos de uso dedicados.

---

## 12. Restricciones vs Admin/Scan

### 12.1 Tabla Comparativa de Acciones

| Acción | User | Scan | Admin |
| --------------------------------------- | :--: | :--: | :---: |
| **VER libros visibles** | ✅ | ✅ | ✅ |
| **VER libros ocultos** | ❌ | ✅ | ✅ |
| **Crear libros** | ❌ | ✅ | ✅ |
| **Eliminar libros** | ❌ | ✅ | ✅ |
| **Toggle visibilidad** | ❌ | ✅ | ✅ |
| **Crear/editar/eliminar géneros** | ❌ | ❌ | ✅ |
| **Crear/editar/eliminar labels** | ❌ | ✅ | ✅ |
| **VER todos los usuarios** | ❌ | ✅ | ✅ |
| **Cambiar rol de usuarios** | ❌ | ❌ | ✅ |
| **Suspender usuarios** | ❌ | ❌ | ✅ |
| **VER analytics (book_views)** | ❌ | ❌ | ✅ |
| **INSERTar analytics** | ❌ | ❌ | ✅ |
| **Editar propio perfil** | ✅ | ✅ | ✅ |
| **Cambiar contraseña** | ✅ | ✅ | ✅ |
| **Gestionar favoritos** | ✅ | ❌ | ❌ |
| **Ver detalles de libro** | ✅ | ❌ | ✅ |
| **Leer capítulos** | ✅ | ❌ | ❌ |
| **Filtrar por género** | ✅ | ❌ | ❌ |

### 12.2 User vs Scan

| Capacidades | User | Scan |
| ----------- | ---- | ---- |
| Pantalla principal | MainScreen (lectura) | ScanMainScreen (gestión) |
| **Ver libros** | Solo visibles | Solo propios (`created_by`) |
| **Crear contenido** | ❌ | ✅ (libros, tomos, capítulos) |
| **Subir covers** | ❌ (RLS lo permite, sin UI) | ✅ |
| **Subir contenido** | ❌ (sin UI) | ✅ (.md, .txt) |
| **Toggle visibilidad** | ❌ | ✅ (propios) |
| **Ver géneros** | ✅ | ✅ |
| **Ver etiquetas** | ✅ | ✅ |
| **Gestionar favoritos** | ✅ | ❌ |

### 12.3 User vs Admin

| Capacidades | User | Admin |
| ----------- | ---- | ----- |
| Pantalla principal | MainScreen | AdminDashScreen |
| **Ver libros** | Solo visibles | Todos (visibles + ocultos) |
| **Crear/Eliminar libros** | ❌ | ✅ (todos) |
| **Crear/Eliminar géneros** | ❌ | ✅ |
| **Gestionar usuarios** | ❌ | ✅ |
| **Ver analíticas** | ❌ | ✅ (placeholder) |
| **Editar propio perfil** | ✅ | ✅ |
| **Acceso a /admin** | ❌ | ✅ |

### 12.4 Resumen

El usuario regular es el rol más limitado — solo puede **leer contenido**
y **gestionar su propio perfil y favoritos**. No tiene acceso a ninguna
operación de escritura sobre el contenido de la plataforma.

---

## 13. Inyección de Dependencias

### 13.1 Módulos Relevantes para User

#### injection_books.dart

```dart
getIt.registerLazySingleton<BookRepository>(
  () => BookRepositoryImpl(getIt<SupabaseClientProvider>()),
);
getIt.registerLazySingleton(() => GetBooks(getIt()));
getIt.registerLazySingleton(() => GetBookById(getIt()));
getIt.registerFactory(
  () => BookBloc(getBooks: getIt(), getBookById: getIt()),
);
```

**Nota**: `BookBloc` se registra como `registerFactory` — cada llamada
crea una instancia nueva. En `MainScreen`, se crea con `onlyVisible: true`.

#### injection_chapters.dart

```dart
getIt.registerLazySingleton<ChapterRepository>(
  () => ChapterRepositoryImpl(getIt<SupabaseClientProvider>()),
);
getIt.registerLazySingleton(() => GetChapterContent(getIt()));
getIt.registerFactory(
  () => ChapterBloc(getChapterContent: getIt()),
);
```

#### injection_favorites.dart

```dart
getIt.registerLazySingleton<FavoriteRepository>(
  () => FavoriteRepositoryImpl(getIt<SupabaseClientProvider>()),
);
getIt.registerFactory(
  () => FavoriteBloc(favoriteRepository: getIt()),
);
```

#### injection_profiles.dart

```dart
getIt.registerLazySingleton<ProfilesRepository>(
  () => ProfilesRepositoryImpl(getIt<SupabaseClientProvider>()),
);
getIt.registerLazySingleton(() => GetProfile(getIt()));
getIt.registerLazySingleton(() => UpdateProfile(getIt()));
getIt.registerLazySingleton(() => UploadAvatar(getIt()));
getIt.registerLazySingleton(() => ChangePassword(getIt()));
getIt.registerFactory(
  () => ProfileBloc(
    getProfile: getIt(),
    updateProfile: getIt(),
    uploadAvatar: getIt(),
    changePassword: getIt(),
  ),
);
```

**Nota**: `GetAllProfiles` y `UpdateUserRole` también se registran aquí
pero NO son usados por el usuario regular.

#### injection_genres.dart

```dart
getIt.registerLazySingleton<GenreRepository>(
  () => GenreRepositoryImpl(getIt<SupabaseClientProvider>()),
);
getIt.registerLazySingleton(() => GetGenre(getIt()));
getIt.registerFactory(
  () => GenreBloc(
    getGenre: getIt(),
    createGenre: getIt(),
    updateGenre: getIt(),
    deleteGenre: getIt(),
  ),
);
```

**Nota**: Aunque `GenreBloc` tiene casos de uso de escritura, el usuario
regular solo dispara `LoadGenres`.

### 13.2 injection.dart (Main)

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
  initScanDependencies();    // ← No usado por user
  initAdminDependencies();   // ← No usado por user
}
```

**Tipos de registro**:

| Tipo | Uso | Ejemplo |
| ---- | --- | ------- |
| `registerLazySingleton` | Repos, use cases | `GetBooks` |
| `registerFactory` | BLoCs (instancia nueva) | `BookBloc` |

---

## 14. Archivos Relacionados (Lista Completa)

### 14.1 Feature App (Home + Navegación)

```text
lib/features/app/presentation/screens/main_screen.dart          (240 líneas)
lib/features/app/presentation/widgets/app_drawer.dart           (162 líneas)
lib/features/app/presentation/widgets/carousel_appbar_sliver.dart (116 líneas)
```

### 14.2 Feature Books

```text
lib/features/books/presentation/screens/book_screen.dart        (92 líneas)
lib/features/books/presentation/screens/widgets/sliver_app_bar_book.dart (121 líneas)
lib/features/books/presentation/screens/widgets/sliver_persistent_header_book.dart
lib/features/books/presentation/views/detail/detail_view.dart   (150 líneas)
lib/features/books/presentation/views/detail/widgets/card_info_detail.dart
lib/features/books/presentation/views/took/took_view.dart       (80 líneas)
lib/features/books/presentation/bloc/book_bloc.dart             (88 líneas)
lib/features/books/presentation/bloc/book_event.dart            (30 líneas)
lib/features/books/presentation/bloc/book_state.dart            (39 líneas)
lib/features/books/domain/book_entity.dart                      (134 líneas)
lib/features/books/domain/book_repository.dart
lib/features/books/domain/get_book.dart
lib/features/books/domain/get_book_by_id.dart
lib/features/books/domain/track_book_view.dart                  (12 líneas)
lib/features/books/data/book_repository_impl.dart
```

### 14.3 Feature Chapters

```text
lib/features/chapters/presentation/screens/chapter_screen.dart  (167 líneas)
lib/features/chapters/presentation/bloc/chapter_bloc.dart       (53 líneas)
lib/features/chapters/presentation/bloc/chapter_event.dart      (19 líneas)
lib/features/chapters/presentation/bloc/chapter_state.dart      (30 líneas)
lib/features/chapters/domain/chapter_entity.dart                (52 líneas)
lib/features/chapters/domain/chapter_ref.dart                   (34 líneas)
lib/features/chapters/domain/chapter_repository.dart
lib/features/chapters/domain/get_chapter_content.dart           (12 líneas)
lib/features/chapters/data/chapter_repository_impl.dart         (125 líneas)
lib/features/chapters/data/chapter_model.dart
```

### 14.4 Feature Tooks

```text
lib/features/tooks/presentation/screens/took_screen.dart        (64 líneas)
lib/features/tooks/presentation/views/took_view.dart            (80 líneas)
lib/features/tooks/domain/took_entity.dart                      (62 líneas)
lib/features/tooks/data/took_model.dart
lib/features/tooks/data/took_repository_impl.dart
```

### 14.5 Feature Favorites

```text
lib/features/favorites/presentation/screens/favorites_screen.dart (128 líneas)
lib/features/favorites/presentation/widgets/favorite_button.dart (75 líneas)
lib/features/favorites/presentation/bloc/favorite_bloc.dart      (65 líneas)
lib/features/favorites/presentation/bloc/favorite_event.dart     (37 líneas)
lib/features/favorites/presentation/bloc/favorite_state.dart     (47 líneas)
lib/features/favorites/domain/favorite_entity.dart              (16 líneas)
lib/features/favorites/domain/favorite_repository.dart          (8 líneas)
lib/features/favorites/data/favorite_repository_impl.dart
```

### 14.6 Feature Profiles

```text
lib/features/profiles/presentation/screens/profile_screen.dart   (180 líneas)
lib/features/profiles/presentation/screens/widgets/avatar_section.dart
lib/features/profiles/presentation/screens/widgets/profile_edit_form.dart
lib/features/profiles/presentation/screens/widgets/password_change_form.dart
lib/features/profiles/presentation/screens/widgets/logout_section.dart
lib/features/profiles/presentation/bloc/profile_bloc.dart       (113 líneas)
lib/features/profiles/presentation/bloc/profile_event.dart      (40 líneas)
lib/features/profiles/presentation/bloc/profile_state.dart      (41 líneas)
lib/features/profiles/domain/user_entity.dart                   (53 líneas)
lib/features/profiles/domain/user_role.dart                     (18 líneas)
lib/features/profiles/domain/profiles_repository.dart
lib/features/profiles/domain/get_profile.dart
lib/features/profiles/domain/update_profile.dart
lib/features/profiles/domain/upload_avatar.dart
lib/features/profiles/domain/change_password.dart
lib/features/profiles/data/user_model.dart                      (40 líneas)
lib/features/profiles/data/profiles_repository_impl.dart
```

### 14.7 Feature Genres

```text
lib/features/genres/presentation/screens/genre_screen.dart       (109 líneas)
lib/features/genres/presentation/bloc/genre_bloc.dart           (111 líneas)
lib/features/genres/domain/genre_entity.dart                    (37 líneas)
lib/features/genres/domain/get_genre.dart
```

### 14.8 Feature Auth

```text
lib/features/auth/presentation/bloc/auth_bloc.dart              (115 líneas)
lib/features/auth/presentation/screens/login_screen.dart
lib/features/auth/presentation/screens/register_screen.dart
lib/features/auth/domain/use_cases/login.dart
lib/features/auth/domain/use_cases/register.dart
lib/features/auth/domain/use_cases/logout.dart
lib/features/auth/domain/use_cases/get_current_user.dart
lib/features/auth/domain/use_cases/listen_auth_state.dart
```

### 14.9 Core / Infraestructura

```text
lib/core/app/app.dart                                           (76 líneas)
lib/core/di/injection.dart                                      (38 líneas)
lib/core/di/injection_books.dart                                (63 líneas)
lib/core/di/injection_chapters.dart                             (48 líneas)
lib/core/di/injection_favorites.dart                            (21 líneas)
lib/core/di/injection_profiles.dart                             (50 líneas)
lib/core/di/injection_genres.dart                               (45 líneas)
lib/core/supabase/chapter_cache.dart                            (42 líneas)
lib/core/supabase/supabase_client.dart
lib/core/cover/cover_url_service.dart
lib/core/constants/storage_constants.dart
lib/core/errors/result.dart
lib/core/errors/failure.dart
lib/core/presentation/notification_service.dart
lib/core/presentation/notification_listener.dart
lib/core/presentation/widgets/title_widget.dart
lib/core/presentation/widgets/label_badge.dart
lib/shared/domain/entities/book_with_relations.dart              (109 líneas)
lib/shared/presentation/widgets/empty_state.dart
lib/shared/presentation/widgets/snackbar_helper.dart
```

### 14.10 Widgets Compartidos

```text
lib/core/presentation/widgets/title_widget.dart
lib/core/presentation/widgets/label_badge.dart
lib/shared/presentation/widgets/empty_state.dart
lib/shared/presentation/widgets/snackbar_helper.dart
```

---

## 15. Hallazgos y Recomendaciones

### 15.1 Seguridad

1. **Storage buckets sin ownership check**: Los buckets `covers` y
   `chapters` permiten INSERT/UPDATE/DELETE a cualquier usuario
   autenticado. Un usuario regular podría subir archivos a estos buckets
   vía la API de Supabase, aunque la app no lo permite.

2. **`TrackBookView` falla silenciosamente**: El caso de uso se ejecuta
   en `BookScreen` (L47), pero la política RLS de `book_views` requiere
   `is_admin()`. El INSERT falla y no se muestra error al usuario.

3. **Favoritos sin validación de existencia**: `toggleFavorite` inserta
   directamente en la tabla sin verificar si el libro existe. Si el libro
   fue eliminado, el favorito queda apuntando a un ID inexistente.

4. **No hay rate limiting**: El usuario puede hacer múltiples llamadas a
   `LoadMoreBooks` sin protección contra abuso.

### 15.2 UX

1. **FavoritesScreen sin navegación**: Al tocar un favorito, no se
   navega al `BookScreen`. El usuario solo ve la lista pero no puede
   acceder al libro desde ahí.

2. **Performance en FavoritesScreen**: Cada favorito hace una consulta
   independiente a `BookRepository.getBookById()` via `FutureBuilder`.
   Con muchos favoritos, esto causa múltiples round-trips visibles como
   "Cargando..." secuenciales.

3. **GenreScreen filtra localmente**: Se pasan todos los libros y se
   filtran por nombre de género. Con muchos libros, esto puede ser
   ineficiente. Un approach server-side sería más escalable.

4. **No hay pull-to-refresh** en `FavoritesScreen` ni en `GenreScreen`.

5. **No hay búsqueda de libros**: El usuario no puede buscar libros por
   nombre, autor u otros criterios.

### 15.3 Tech Debt

1. **`GenreBloc` se crea como instancia nueva en `MainScreen`** — pero
   también se crea en `GenresTab` del admin. El `GenreBloc` tiene casos
   de uso de escritura (`CreateGenre`, `UpdateGenre`, `DeleteGenre`) que
   el usuario regular no usa, pero se inyectan igualmente.

2. **`BookBloc` como `registerFactory`**: Se crea una instancia nueva en
   `MainScreen`, pero también se registra como factory en DI. La
   instancia de `MainScreen` pasa `onlyVisible: true` como parámetro
   extra.

3. **No hay tests unitarios** para los BLoCs del usuario regular.

4. **`ChapterCache` no tiene invalidación**: Los capítulos cacheados
   nunca se eliminan. Si un scan actualiza un capítulo, el usuario
   seguirá leyendo la versión cacheada.

5. **`ChapterRef` como workaround**: Se creó `ChapterRef` para evitar
   pasar `ChapterEntity` completo por el event bus. Es una mejora
   correcta pero indica acoplamiento entre la lista de capítulos y el
   BLoC de carga.

6. **Doble punto de entrada a MainScreen**: El usuario llega a
   `MainScreen` tanto por el routing automático (app.dart L61-62) como
   por el "Inicio" del drawer (que solo cierra el drawer, no navega).

---

*Documento generado como parte de la auditoría del rol de usuario regular
en el proyecto Noveles.*
