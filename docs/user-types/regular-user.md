# Usuario Regular (`role = 'user'`) — Auditoría Completa

> Fecha: 2026-07-19 | Proyecto: NovelEs Flutter + Supabase

---

## 1. Definición y Modelo

### 1.1 Entidad de Dominio: `UserEntity`

**Archivo:** `lib/features/profiles/domain/user_entity.dart` (50 líneas)

```dart
class UserEntity extends Equatable {
  final String id;       // UUID — FK a auth.users
  final String email;
  final String role;     // 'user' | 'admin' | 'scan'
  final String? displayName;
  final String? bio;
  final String? avatarUrl;

  // Getters de conveniencia:
  bool get isScan => role == 'scan';     // línea 20
  bool get isAdmin => role == 'admin';   // línea 21
}
```

**Observación crítica:** NO existe un getter `isUser`. El usuario regular se define por la AUSENCIA de `isAdmin` y `isScan`. Esto es un patrón defensivo débil — si se agrega un nuevo rol, se escapa de la lógica de routing.

### 1.2 Modelo de Datos: `UserModel`

**Archivo:** `lib/features/profiles/data/user_model.dart` (39 líneas)

```dart
factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: (json['email'] as String?) ?? '',
  role: (json['role'] as String?) ?? 'user',  // ← DEFAULT = 'user' (línea 16)
  displayName: json['display_name'] as String?,
  bio: json['bio'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);
```

**Nota:** El default de `role` en deserialización es `'user'` (línea 16). Si el JSON no trae `role`, se asume usuario regular.

### 1.3 Tabla Supabase: `profiles`

**Migración:** `20260515161849_profiles_and_auth.sql` (líneas 4-8)

```sql
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'scan', 'admin')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
-- Campos extendidos (20260515170000):
-- display_name TEXT, bio TEXT, avatar_url TEXT
```

### 1.4 Funciones Helper SQL

| Función | Archivo | Qué hace |
|---------|---------|----------|
| `is_admin()` | `20260520010000` línea 7 | `role = 'admin'` |
| `is_scan()` | `20260520000000` línea 8 | `role = 'scan'` |
| `is_admin_or_scan()` | `20260615000000` línea 10 | `role IN ('admin', 'scan')` |

---

## 2. Flujo de Autenticación

### 2.1 Registro (`Register` → `AuthBloc` → `AuthRepositoryImpl`)

**Pantalla:** `lib/features/auth/presentation/screens/register_screen.dart`
- Formulario: email + password + confirm password
- Mínimo 6 caracteres en password
- Emite `RegisterRequested(email, password)` al BLoC

**BLoC:** `lib/features/auth/presentation/bloc/auth_bloc.dart` (líneas 85-97)
- `_onRegister` → emite `AuthLoading` → llama `register()` use case → emite `AuthAuthenticated(user)`

**Repository:** `lib/features/auth/data/auth_repository_impl.dart` (líneas 44-69)
1. `auth.signUp(email, password)` → crea usuario en `auth.users`
2. `_getProfile(user.id)` → busca en tabla `profiles`
3. **Si NO existe perfil** (línea 127-151): lo crea automáticamente con `role: 'user'`
4. Retorna `UserModel.fromJson({id, email, ...profile})`

### 2.2 Login (`Login` → `AuthBloc` → `AuthRepositoryImpl`)

**Pantalla:** `lib/features/auth/presentation/screens/login_screen.dart`
- Formulario: email + password
- Emite `LoginRequested(email, password)`

**Repository:** `lib/features/auth/data/auth_repository_impl.dart` (líneas 17-42)
1. `auth.signInWithPassword(email, password)`
2. `_getProfile(user.id)` → misma lógica: busca o crea perfil con `role: 'user'`
3. Retorna `UserEntity` con `role = 'user'`

### 2.3 Auto-creación de Perfil (Trigger SQL)

**Migración:** `20260515161849` (líneas 11-26)

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.profiles (id, role)
  VALUES (NEW.id, 'user');
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

**Flujo dual:** Hay DOS mecanismos de auto-creación:
1. **Trigger SQL** — dispara al insertar en `auth.users`
2. **`_getProfile()` en Dart** — fallback si el trigger falló o el perfil no existe

### 2.4 Sesión y Estado

**Use Cases:**
| Use Case | Archivo | Qué hace |
|----------|---------|----------|
| `GetCurrentUser` | `lib/features/auth/domain/use_cases/get_current_user.dart` | Verifica sesión activa, retorna `UserEntity?` |
| `ListenAuthState` | `lib/features/auth/domain/use_cases/listen_auth_state.dart` | Stream de eventos `AuthEvent` |

**Estados del BLoC** (`lib/features/auth/presentation/bloc/auth_state.dart`):
- `AuthInitial` → `AuthLoading` → `AuthAuthenticated(user)` | `AuthUnauthenticated` | `AuthError(message)`

### 2.5 Routing por Rol (Punto Crítico)

**Archivo:** `lib/core/app/app.dart` (líneas 54-62)

```dart
if (authState is AuthAuthenticated) {
  if (authState.user.isAdmin) {        // línea 55
    return const AdminDashScreen();
  }
  if (authState.user.isScan) {          // línea 58
    return const ScanMainScreen();
  }
  return const MainScreen();            // línea 61 ← USUARIO REGULAR
}
return const LoginScreen();             // línea 63 ← No autenticado
```

**El usuario regular llega SIEMPRE a `MainScreen`.** No hay verificación explícita de `role == 'user'`, solo se descarta `isAdmin` e `isScan`.

---

## 3. Pantallas y Navegación

### 3.1 Flujo de Pantallas del Usuario Regular

```
LoginScreen/RegisterScreen
    ↓ (auth exitoso)
MainScreen ← HOME DEL USUARIO REGULAR
    ├── Carousel de libros (SliverAppBarHome)
    ├── Chips de géneros horizontales
    ├── Drawer (AppDrawer)
    │   ├── Header: avatar, nombre, email
    │   ├── "Inicio" (cierra drawer)
    │   ├── "Editar Perfil" → ProfileScreen
    │   └── "Cerrar Sesión" (con confirmación)
    │
    ↓ (tap en libro)
BookScreen
    ├── Tab "Info" → DetailView (descripción, metadata, géneros)
    └── Tab "Took" → TookView (lista de tomos)
        ↓ (tap en tomo)
TookScreen
    └── Lista de capítulos
        ↓ (tap en capítulo)
ChapterScreen
    └── Lector inmersivo con PageView
```

### 3.2 `MainScreen` — Home del Usuario Regular

**Archivo:** `lib/features/app/presentation/screens/main_screen.dart` (163 líneas)

**BLoCs creados:**
- `BookBloc(onlyVisible: true)` → carga SOLO libros visibles (línea 30)
- `GenreBloc` → carga todos los géneros

**Componentes:**
1. **SliverAppBarHome** — Carousel automático de libros con cover, nombre, autor, labels
2. **Chips de género** — ListView horizontal que filtra libros por género
3. **AppDrawer** — Menú lateral (ver sección 3.3)

**Navegación desde MainScreen:**
- Tap en libro del carousel → `BookScreen` (con transición de 1 segundo)
- Tap en chip de género → `GenreScreen` (filtrado local de libros)
- Tap en menú → abre `AppDrawer`

### 3.3 `AppDrawer` — Menú Lateral

**Archivo:** `lib/features/app/presentation/widgets/app_drawer.dart` (129 líneas)

**Para usuario regular** (cuando `isAdmin = false` y `isScan = false`):

| Elemento | Visible | Acción |
|----------|---------|--------|
| Avatar + nombre + email | ✅ | Solo visual |
| "Inicio" (con icono Home) | ✅ | Cierra drawer (ya está en home) |
| "Editar Perfil" | ✅ | → `ProfileScreen` |
| Divider | ✅ | Separador visual |
| "Cerrar Sesión" | ✅ | Dialog de confirmación → `LogoutRequested` |
| "Panel Admin" | ❌ | Solo si `isAdmin = true` |

**Nota:** El drawer recibe `isScan` e `isAdmin` como parámetros constructor (línea 9-12), pero en `MainScreen` se instancia como `const AppDrawer()` SIN pasar valores (línea 38 de main_screen.dart). Ambos defaultean a `false`, lo cual es correcto para el usuario regular.

### 3.4 Pantallas NO Accesibles al Usuario Regular

| Pantalla | Requiere | Acceso user |
|----------|----------|-------------|
| `AdminDashScreen` | `role = 'admin'` | ❌ |
| `ScanMainScreen` | `role = 'scan'` | ❌ |
| `LabelManagementScreen` | Ruta `/label-management` (solo accessible vía admin) | ❌ en UI |

---

## 4. Experiencia de Lectura

### 4.1 `BookScreen` — Detalle del Libro

**Archivo:** `lib/features/books/presentation/screens/book_screen.dart` (84 líneas)

**Componentes:**
- `SliverAppBarBook` — Cover con efecto blur, nombre, autor
- `SliverPersistentHeaderBook` — Tabs "Info" y "Took"
- `DetailView` — Pestaña de información
- `TookView` — Pestaña de tomos

**Tabs:**
1. **"Info"** → `DetailView` (descripción, publicado, tipo, país, estado, tomos, capítulos, géneros como chips)
2. **"Took"** → `TookView` (lista de tomos con cantidad de capítulos)

### 4.2 `DetailView` — Información del Libro

**Archivo:** `lib/features/books/presentation/views/detail/detail_view.dart` (99 líneas)

**Muestra:**
- Descripción completa
- CardInfoDetail: Publicado / Tipo de Novela
- CardInfoDetail: País / Estado
- CardInfoDetail: Tomos / Capítulos (números)
- Chips de géneros (tap sin acción — `onTap: () {}`)

**Campos de `BookEntity` que NO se muestran al usuario regular:**
- `source` — URL fuente del libro (NO visible)
- `link` — Link externo del libro (NO visible)
- `isFavorite` — Campo existe en la DB pero NO hay UI para interactuar
- `isVisible` — Campo administrativo
- `alternative` — Nombre alternativo (NO visible en detail)
- `short` — Nombre corto (NO visible en detail)
- `createdBy` — ID del creador (NO visible)

### 4.3 `TookView` — Lista de Tomos

**Archivo:** `lib/features/tooks/presentation/views/took_view.dart` (80 líneas)

Muestra cada tomo como un `Card` con `ListTile`:
- Subtitle: título del tomo
- Title: número del tomo
- Trailing: "Capítulos" + cantidad

### 4.4 `TookScreen` — Capítulos de un Tomo

**Archivo:** `lib/features/tooks/presentation/screens/took_screen.dart` (64 líneas)

- SliverAppBar con número del tomo
- SliverList de capítulos
- Cada capítulo muestra título y número
- Al tocar: navega a `ChapterScreen` con `ChapterBloc` inyectado

### 4.5 `ChapterScreen` — Lector Inmersivo

**Archivo:** `lib/features/chapters/presentation/screens/chapter_screen.dart` (186 líneas)

**Funcionalidades:**
- **Modo inmersivo** — `SystemUiMode.immersive` al entrar, `edgeToEdge` al salir
- **PageView** con `BouncingScrollPhysics` — swipe entre capítulos
- **Estadísticas** — caracteres, palabras, frases, párrafos (calculados por `TextStats`)
- **Personalización** — `textSize`, `selectedFont`, `selectedStyle`, `selectedWeight`
- **Scroll controller** — oculta/muestra toolbar según dirección de scroll

**Nota:** Las variables de estilo (`selectedFont`, `selectedStyle`, etc.) están declaradas pero NO tienen UI para cambiarlas actualmente (son defaults: Arial, normal, normal, 14.0).

### 4.6 Carga de Contenido de Capítulos

**BLoC:** `lib/features/chapters/presentation/bloc/chapter_bloc.dart` (53 líneas)

1. Recibe `List<ChapterRef>` + `initialIndex`
2. Descarga contenido de CADA capítulo en paralelo (`Future.wait`)
3. Resuelve contenido desde Supabase Storage (bucket `chapters`)
4. Retorna `ChapterLoaded(chapters, initialIndex)`

**Repository:** `lib/features/chapters/data/chapter_repository_impl.dart` (123 líneas)

`downloadContent(path)` (líneas 110-122):
1. Si el path NO es storage path (no contiene `/`, ni termina en `.txt`/`.json`), retorna el string directo
2. Si es storage path, busca en cache local (`ChapterCache`)
3. Si no está en cache, descarga de Supabase Storage
4. Cachea para futuras lecturas

---

## 5. Gestión de Perfil

### 5.1 `ProfileScreen`

**Archivo:** `lib/features/profiles/presentation/screens/profile_screen.dart` (189 líneas)

**BLoC:** `ProfileBloc` con 4 eventos:
- `LoadProfile` → carga perfil desde Supabase
- `UpdateProfile(displayName, bio)` → actualiza campos
- `PickAvatar(filePath)` → selecciona imagen
- `ChangePassword(newPassword)` → cambia contraseña

**Secciones de la pantalla:**
1. **AvatarSection** — CircleAvatar grande (50px radio) + botón "Cambiar foto"
2. **Email** — Solo visual, no editable
3. **ProfileEditForm** — Campos: Nombre (`displayName`), Biografía (`bio`), botón "Guardar cambios"
4. **Divider**
5. **PasswordChangeForm** — Nueva contraseña + confirmar, mínimo 6 caracteres
6. **LogoutSection** — Botón de cerrar sesión con dialog de confirmación

### 5.2 Permisos de Perfil en Supabase

| Operación | Política RLS | Usuario Regular |
|-----------|-------------|-----------------|
| SELECT propio | "Users can read own profile" (`auth.uid() = id`) | ✅ Puede |
| SELECT todos | "Admin can read all profiles" (`is_admin()`) | ❌ No puede |
| INSERT propio | "Users can insert own profile" (`auth.uid() = id`) | ✅ Puede (fallback auto-creación) |
| UPDATE propio | "Users can update own profile" (`auth.uid() = id`) | ✅ Puede |
| UPDATE admin | "Admin can update profiles" (`is_admin()`) | ❌ No puede |
| DELETE | No hay política de DELETE | ❌ No puede |

### 5.3 Upload de Avatar

**Repository:** `lib/features/profiles/data/profiles_repository_impl.dart` (líneas 56-70)

1. Sube a bucket `avatars` con path `{userId}/avatar.{ext}`
2. `FileOptions(upsert: true)` — sobreescribe avatar anterior
3. Retorna URL pública con cache-busting: `?v={timestamp}`

**Storage RLS** (migración `20260515170000`):
- Read: público (`Avatars public read`)
- Write: solo propio (`auth.role() = 'authenticated' AND folder = uid`)

---

## 6. Funcionalidades Disponibles

### 6.1 Resumen Completo

| Funcionalidad | Disponible | Dónde |
|---------------|-----------|-------|
| Registrarse | ✅ | `RegisterScreen` |
| Iniciar sesión | ✅ | `LoginScreen` |
| Ver catálogo de libros | ✅ | `MainScreen` (solo visibles) |
| Ver carousel de libros | ✅ | `SliverAppBarHome` |
| Filtrar por género | ✅ | Chips en `MainScreen` → `GenreScreen` |
| Ver detalle de libro | ✅ | `BookScreen` tab "Info" |
| Ver tomos de un libro | ✅ | `BookScreen` tab "Took" |
| Ver capítulos de un tomo | ✅ | `TookScreen` |
| Leer capítulos | ✅ | `ChapterScreen` (inmersivo) |
| Editar perfil | ✅ | `ProfileScreen` |
| Cambiar avatar | ✅ | `ProfileScreen` → `ImagePicker` |
| Cambiar contraseña | ✅ | `ProfileScreen` |
| Cerrar sesión | ✅ | Drawer / ProfileScreen |
| Ver labels de libros | ✅ | Visualizados en carousel y book detail |

### 6.2 Funcionalidades NO Disponibles

| Funcionalidad | Bloqueada por | Dónde se ve |
|---------------|---------------|-------------|
| Crear/editar/eliminar libros | RLS + UI solo admin | `AdminDashScreen` |
| Crear/editar/eliminar tomos | RLS + UI solo admin | `AdminDashScreen` |
| Crear/editar/eliminar capítulos | RLS + UI solo admin | `AdminDashScreen` |
| Crear/editar/eliminar géneros | RLS + UI solo admin | `AdminDashScreen` |
| Gestionar labels | RLS + UI solo admin | `LabelManagementScreen` |
| Ver panel admin | Routing (`app.dart` línea 55) | Solo `isAdmin` |
| Ver panel scan | Routing (`app.dart` línea 58) | Solo `isScan` |
| Toggle visibilidad de libros | Solo admin | Admin UI |
| Marcar/desmarcar favoritos | **No existe UI** | Campo `isFavorite` sin uso |
| Ver `source` / `link` de libros | No se renderiza | `DetailView` no los muestra |
| Crear book views (analytics) | Solo insert permitido | `book_views` table |

---

## 7. Restricciones y Acceso

### 7.1 Routing — Exclusión del Admin/Scan

**Archivo:** `lib/core/app/app.dart` (líneas 54-62)

```dart
if (authState.user.isAdmin) return AdminDashScreen();   // Excluido
if (authState.user.isScan)  return ScanMainScreen();    // Excluido
return MainScreen();                                     // ← Usuario regular
```

### 7.2 BookBloc — Filtro `onlyVisible`

**Archivo:** `lib/features/app/presentation/screens/main_screen.dart` (línea 30)

```dart
BookBloc(onlyVisible: true)
```

El `BookBloc` con `onlyVisible: true` pasa este flag a `getBooks()`, que lo traduce a:
```dart
query = query.eq('is_visible', true);  // book_repository_impl.dart línea 29
```

El usuario regular SOLO ve libros donde `is_visible = TRUE`.

### 7.3 Todos los Lugares con Checks de Rol

| Archivo | Línea | Check | Impacto para user |
|---------|-------|-------|-------------------|
| `app.dart` | 55 | `authState.user.isAdmin` | Define home screen |
| `app.dart` | 58 | `authState.user.isScan` | Define home screen |
| `app_drawer.dart` | 58 | `if (isAdmin)` | Muestra "Panel Admin" |
| `app_drawer.dart` | 67 | `if (!isAdmin)` | Muestra "Inicio" / "Panel Scan" |
| `user_entity.dart` | 20 | `role == 'scan'` | Getter `isScan` |
| `user_entity.dart` | 21 | `role == 'admin'` | Getter `isAdmin` |

**Nota:** NO hay checks de rol en ningún BLoC de lectura (books, chapters, genres). Los BLoCs son agnósticos al rol — la restricción viene de:
1. **RLS en Supabase** — el usuario solo puede SELECT donde las políticas lo permiten
2. **`onlyVisible` flag** — filtro client-side en `MainScreen`

### 7.4 Tablas con RLS Afectando al Usuario Regular

| Tabla | SELECT | INSERT | UPDATE | DELETE |
|-------|--------|--------|--------|--------|
| `profiles` | ✅ propio | ✅ propio | ✅ propio | ❌ |
| `books` | ✅ solo `is_visible = true` | ❌ solo admin | ❌ solo admin | ❌ solo admin |
| `genres` | ✅ todos | ❌ solo admin | ❌ solo admin | ❌ solo admin |
| `tooks` | ✅ todos | ❌ solo admin (o scan own) | ❌ solo admin (o scan own) | ❌ solo admin (o scan own) |
| `chapters` | ✅ todos | ❌ solo admin (o scan own) | ❌ solo admin (o scan own) | ❌ solo admin (o scan own) |
| `books_genres` | ✅ todos | ❌ solo admin | ❌ solo admin | ❌ solo admin |
| `labels` | ✅ todos | ❌ scan/admin | ❌ scan/admin | ❌ scan/admin |
| `books_labels` | ✅ todos | ❌ scan/admin | — | ❌ scan/admin |
| `authors` | ✅ todos | ❌ solo admin | ❌ solo admin | ❌ solo admin |
| `book_views` | ❌ solo admin | ✅ cualquier auth | — | — |

---

## 8. Interacciones con Supabase

### 8.1 Tablas que el Usuario Regular Lee

1. **`profiles`** — Su propio perfil (SELECT WHERE id = auth.uid())
2. **`books`** — Libros con `is_visible = true` (JOIN con authors, books_genres, genres, books_labels, labels, tooks, chapters)
3. **`genres`** — Todos los géneros
4. **`tooks`** — Todos los tomos (vía JOIN desde books)
5. **`chapters`** — Todos los capítulos (vía JOIN desde tooks)
6. **`books_genres`** — Relaciones libro-género
7. **`labels`** — Todas las labels
8. **`books_labels`** — Relaciones libro-label
9. **`authors`** — Todos los autores

### 8.2 Queries del BookRepository

**`getBooks(onlyVisible: true)`** — La query principal (líneas 25-35):
```sql
SELECT *, authors(*), books_genres(genre_id, genres(*)),
       books_labels(*, labels(*)), tooks(*, chapters(*))
FROM books
WHERE is_visible = true
ORDER BY id
LIMIT 50 OFFSET 0
```

### 8.3 Storage Buckets Accesibles

| Bucket | Read | Write | Para user regular |
|--------|------|-------|-------------------|
| `covers` | ✅ público | ❌ solo authenticated | Lee covers de libros |
| `chapters` | ✅ público | ❌ solo authenticated | Lee contenido de capítulos |
| `avatars` | ✅ público | ✅ solo propio | Lee/escribe su avatar |

### 8.4 Funciones SQL del Helper

```sql
-- is_admin() — usado en RLS de admin
CREATE FUNCTION public.is_admin() RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin');
$$;

-- is_scan() — usado en RLS de scan
CREATE FUNCTION public.is_scan() RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'scan');
$$;

-- is_admin_or_scan() — combinado
CREATE FUNCTION public.is_admin_or_scan() RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'scan'));
$$;
```

---

## 9. BLoCs y Estado

### 9.1 BLoCs que el Usuario Regular Utiliza

| BLoC | Archivo | Eventos consumidos | Estado producido |
|------|---------|-------------------|------------------|
| `AuthBloc` | `auth/presentation/bloc/auth_bloc.dart` | `CheckAuthSession`, `LoginRequested`, `RegisterRequested`, `LogoutRequested` | `AuthAuthenticated(user)` |
| `BookBloc` | `books/presentation/bloc/book_bloc.dart` | `LoadBooks`, `LoadBookById` | `BookLoaded(books)`, `BookDetailLoaded(book)` |
| `GenreBloc` | `genres/presentation/bloc/genre_bloc.dart` | `LoadGenres` | `GenreLoaded(genres)` |
| `ChapterBloc` | `chapters/presentation/bloc/chapter_bloc.dart` | `LoadChapterContent` | `ChapterLoaded(chapters, initialIndex)` |
| `ProfileBloc` | `profiles/presentation/bloc/profile_bloc.dart` | `LoadProfile`, `UpdateProfile`, `PickAvatar`, `ChangePassword` | `ProfileLoaded(user)`, `ProfileSaving(user)` |

### 9.2 BLoCs Disponibles pero NO Usados por Usuario Regular

| BLoC | Usado por | Acceso user |
|------|-----------|-------------|
| `LabelBloc` | `LabelManagementScreen` (admin route) | ❌ |
| `ThemeBloc` | `App` (global) | ✅ (cambia tema) |

### 9.3 Ciclo de Vida del AuthBloc

```
App() → AuthBloc() → add(CheckAuthSession())
  ↓
_onCheckSession → getCurrentUser() → emite AuthAuthenticated(user)
  ↓
app.dart BlocBuilder → isAdmin? AdminDash : isScan? Scan : MainScreen
```

### 9.4 Patrón de BLoC Base

Todos los BLoCs siguen el mismo patrón:
1. Estado inicial → `emit(Loading)`
2. Ejecutar use case
3. Switch sobre `Result<T>` (`Ok` / `Err`)
4. Emitir estado final con datos o error

---

## 10. Archivos Relacionados (lista completa)

### Dominio
| Archivo | Descripción |
|---------|-------------|
| `lib/features/profiles/domain/user_entity.dart` | Entidad de usuario con roles |
| `lib/features/books/domain/book_entity.dart` | Entidad de libro con isFavorite, isVisible |
| `lib/features/chapters/domain/chapter_entity.dart` | Entidad de capítulo |
| `lib/features/tooks/domain/took_entity.dart` | Entidad de tomo |
| `lib/features/genres/domain/genre_entity.dart` | Entidad de género |
| `lib/features/labels/domain/label_entity.dart` | Entidad de label |
| `lib/shared/domain/entities/book_with_relations.dart` | Libro con relaciones hidratadas |
| `lib/features/auth/domain/repositories/auth_repository.dart` | Interfaz del repositorio de auth |
| `lib/features/auth/domain/entities/auth_event.dart` | Enum de eventos de auth |

### Data
| Archivo | Descripción |
|---------|-------------|
| `lib/features/profiles/data/user_model.dart` | Modelo con fromJson/toJson, default role='user' |
| `lib/features/profiles/data/profiles_repository_impl.dart` | CRUD de perfil en Supabase |
| `lib/features/books/data/book_model.dart` | Modelo de libro con JOINs |
| `lib/features/books/data/book_repository_impl.dart` | Repository con getBooks, onlyVisible |
| `lib/features/chapters/data/chapter_repository_impl.dart` | Repository con uploadContent, downloadContent |
| `lib/features/tooks/data/took_model.dart` | Modelo con chapters hidratados |
| `lib/features/auth/data/auth_repository_impl.dart` | Login, register, _getProfile (auto-crea perfil) |

### Presentation — Screens
| Archivo | Descripción |
|---------|-------------|
| `lib/core/app/app.dart` | Router principal por rol |
| `lib/features/app/presentation/screens/main_screen.dart` | HOME del usuario regular |
| `lib/features/app/presentation/widgets/app_drawer.dart` | Drawer con menú |
| `lib/features/app/presentation/widgets/carousel_appbar_sliver.dart` | Carousel de libros |
| `lib/features/books/presentation/screens/book_screen.dart` | Detalle de libro (tabs Info/Took) |
| `lib/features/books/presentation/views/detail/detail_view.dart` | Vista de info del libro |
| `lib/features/books/presentation/views/detail/widgets/card_info_detail.dart` | Card de metadata |
| `lib/features/books/presentation/screens/widgets/sliver_app_bar_book.dart` | Cover con blur |
| `lib/features/tooks/presentation/screens/took_screen.dart` | Lista de capítulos del tomo |
| `lib/features/tooks/presentation/views/took_view.dart` | Lista de tomos del libro |
| `lib/features/chapters/presentation/screens/chapter_screen.dart` | Lector inmersivo |
| `lib/features/genres/presentation/screens/genre_screen.dart` | Grid de libros por género |
| `lib/features/labels/presentation/screens/label_management_screen.dart` | CRUD de labels (admin) |
| `lib/features/profiles/presentation/screens/profile_screen.dart` | Edición de perfil |
| `lib/features/profiles/presentation/screens/widgets/avatar_section.dart` | Widget de avatar |
| `lib/features/profiles/presentation/screens/widgets/profile_edit_form.dart` | Form de nombre/bio |
| `lib/features/profiles/presentation/screens/widgets/password_change_form.dart` | Form de contraseña |
| `lib/features/profiles/presentation/screens/widgets/logout_section.dart` | Botón de logout |
| `lib/features/auth/presentation/screens/login_screen.dart` | Pantalla de login |
| `lib/features/auth/presentation/screens/register_screen.dart` | Pantalla de registro |

### Presentation — BLoCs
| Archivo | Descripción |
|---------|-------------|
| `lib/features/auth/presentation/bloc/auth_bloc.dart` | BLoC de autenticación |
| `lib/features/auth/presentation/bloc/auth_event.dart` | Eventos de auth |
| `lib/features/auth/presentation/bloc/auth_state.dart` | Estados de auth |
| `lib/features/books/presentation/bloc/book_bloc.dart` | BLoC de libros |
| `lib/features/books/presentation/bloc/book_event.dart` | Eventos de libros |
| `lib/features/books/presentation/bloc/book_state.dart` | Estados de libros |
| `lib/features/chapters/presentation/bloc/chapter_bloc.dart` | BLoC de capítulos |
| `lib/features/chapters/presentation/bloc/chapter_event.dart` | Eventos de capítulos |
| `lib/features/chapters/presentation/bloc/chapter_state.dart` | Estados de capítulos |
| `lib/features/genres/presentation/bloc/genre_bloc.dart` | BLoC de géneros |
| `lib/features/labels/presentation/bloc/label_bloc.dart` | BLoC de labels |
| `lib/features/profiles/presentation/bloc/profile_bloc.dart` | BLoC de perfil |
| `lib/features/profiles/presentation/bloc/profile_event.dart` | Eventos de perfil |
| `lib/features/profiles/presentation/bloc/profile_state.dart` | Estados de perfil |

### Infraestructura
| Archivo | Descripción |
|---------|-------------|
| `lib/core/di/injection.dart` | Inyección de dependencias (GetIt) |
| `lib/core/cover/cover_url_service.dart` | Servicio de URLs de covers |
| `lib/core/supabase/supabase_client.dart` | Provider de cliente Supabase |
| `lib/core/supabase/chapter_cache.dart` | Cache local de capítulos |

### Migraciones SQL (RLS)
| Archivo | Relevancia para user |
|---------|---------------------|
| `20260514220000_initial_schema.sql` | Tablas base |
| `20260515161849_profiles_and_auth.sql` | Profiles, trigger auto-create, RLS books/admin |
| `20260515170000_profiles_extended.sql` | display_name, bio, avatar_url, storage RLS |
| `20260519000000_fix_tooks_chapters_rls.sql` | SELECT público para tooks/chapters |
| `20260520000000_rename_admin_to_scan.sql` | Roles, is_scan(), reescritura de policies |
| `20260520010000_add_admin_role.sql` | is_admin(), is_visible, 3 SELECT policies en books |
| `20260520020000_labels.sql` | Tabla labels, RLS: read=all, write=scan/admin |
| `20260521000000_fix_scan_rls_own_books.sql` | Scan solo ve/edita libros propios |
| `20260522000000_audit_fixes.sql` | RLS genres/books_genres, is_admin write policies |
| `20260524000000_audit_fixes_v2.sql` | scan own books, book_views user_id |
| `20260524100000_profiles_rls_insert_update.sql` | Users INSERT propio, admin UPDATE |
| `20260524110000_fix_books_rls_scan_visibility.sql` | Users solo ven is_visible=true |
| `20260615000000_audit_fixes_v4.sql` | is_admin_or_scan(), type fixes, indexes |
| `20260616000001_fix_storage_rls_and_security_definer.sql` | Storage RLS covers/chapters |
| `20260617153406_fix_chapters_storage_rls.sql` | Authenticated upload chapters |

---

## Hallazgos y Recomendaciones

### 🔴 Issues Críticos

1. **`isFavorite` es un campo muerto** — Existe en `BookEntity` (línea 23), se serializa/deserializa, se escribe en DB, pero NO hay ninguna UI para que el usuario lo togglear ni filtre por él. El campo está desperdiciado.

2. **`source` y `link` son invisibles** — `BookEntity` tiene estos campos (líneas 21-22), se cargan de Supabase, pero `DetailView` no los muestra. Si la app pretende dirigiros a contenido externo, esto está roto.

3. **Falta `isUser` getter** — `UserEntity` tiene `isAdmin` e `isScan` pero no `isUser`. El routing depende de la ausencia de ambos, lo cual es frágil.

### 🟡 Issues Medios

4. **Sin paginación real** — `getBooks` tiene `page`/`pageSize` pero `MainScreen` siempre llama `LoadBooks()` sin parámetros (usa defaults page=1, pageSize=50). No hay scroll infinito.

5. **Variables de estilo sin UI** — `ChapterScreen` declara `selectedFont`, `selectedStyle`, `selectedWeight`, `textSize` pero no hay widgets para cambiarlos. Son dead code de features futuras.

6. **Drawer no pasa `isScan`/`isAdmin`** — `MainScreen` instancia `AppDrawer()` sin argumentos. Funciona porque defaultean a `false`, pero si se necesita pasar el rol real, hay que cambiar `MainScreen`.

7. **Sin feature de favoritos** — No existe `FavoritesBloc`, `favorites_repository`, ni pantalla de favoritos. El campo `isFavorite` es la única evidencia de que se planeó.

### 🟢 Correcto

8. **RLS bien estructurado** — Las políticas cubren SELECT/INSERT/UPDATE/DELETE por tabla y rol. El usuario regular tiene acceso de solo lectura a contenido y escritura solo a su perfil.

9. **Auto-creación de perfil robusta** — Trigger SQL + fallback Dart aseguran que siempre exista un perfil con `role='user'`.

10. **Cache de capítulos** — `ChapterCache` evita re-descargar contenido ya leído, mejorando la experiencia offline.
