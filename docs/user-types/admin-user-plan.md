# Plan de Mejoras — Administrador (`role = 'admin'`)

> **Generado**: 2026-07-20 | **Basado en**: Auditoría de 903 líneas (`docs/user-types/admin-user.md`)
> **Proyecto**: Noveles (Flutter + Supabase)
> **Roles en sistema**: `user` | `scan` | `admin`

---

## Resumen Ejecutivo

El rol de administrador en Noveles tiene una **base sólida en capa de datos** (RLS policies completas, funciones `is_admin()` SECURITY DEFINER, tabla `book_views` preparada) pero una **implementación de UI/BLoC significativamente incompleta**. El tab de Usuarios es solo lectura (sin capacidad de cambio de rol, eliminación, ni búsqueda), el tab de Analytics es un placeholder que dice "Próximamente", y el admin no puede crear libros (solo toggle visibilidad y eliminar). La gestión de géneros es la única funcionalidad CRUD completa.

Las prioridades inmediatas son: (1) completar la gestión de usuarios con escritura real, (2) implementar analytics sobre la tabla `book_views` que ya existe, y (3) agregar creación de libros al admin. El plan total estima ~15-20 días de trabajo distribuido en 5 fases.

---

## Tabla de Prioridades

| # | Item | Prioridad | Esfuerzo | Dependencias | Estado |
|---|------|-----------|----------|--------------|--------|
| 1 | Validación de RLS policies admin | P0 | S | — | ⬜ |
| 2 | Protección contra auto-democión de rol | P0 | S | — | ⬜ |
| 3 | Rate limiting en operaciones destructivas | P0 | S | — | ⬜ |
| 4 | Cambio de rol de usuarios (promote/demote) | P1 | M | #2 | ⬜ |
| 5 | Eliminación/suspensión de usuarios | P1 | M | #4 | ⬜ |
| 6 | Búsqueda de usuarios | P1 | S | — | ⬜ |
| 7 | Paginación en getAllProfiles() | P1 | M | — | ⬜ |
| 8 | Creación de libros desde admin | P1 | L | — | ⬜ |
| 9 | Implementar Analytics tab (book_views) | P1 | L | — | ⬜ |
| 10 | Tracking de vistas de libros | P1 | M | #9 | ⬜ |
| 11 | Dashboard de métricas | P2 | M | #9 | ⬜ |
| 12 | Enum de roles (reemplazar strings) | P2 | M | — | ⬜ |
| 13 | Bulk operations (libros) | P2 | M | #8 | ⬜ |
| 14 | Genre ordering/priority | P2 | S | — | ⬜ |
| 15 | Confirmation dialogs mejorados | P3 | S | — | ⬜ |
| 16 | Loading states y error handling | P3 | S | — | ⬜ |
| 17 | Tests unitarios para BLoCs admin | P3 | L | — | ⬜ |
| 18 | Tests de integración admin flows | P3 | L | #4,#5,#8 | ⬜ |

---

## Fase 1: Seguridad y Acceso (P0 — 2-4 horas)

### 1.1 Validación de RLS Policies para Admin

**Esfuerzo**: S (1-2 horas)
**Archivos afectados**: Solo migraciones SQL (verificación)

**Qué verificar**:
1. La función `is_admin()` en `20260520010000_add_admin_role.sql` usa `SECURITY DEFINER` ✅
2. Todas las tablas con políticas admin usan `is_admin()` correctamente
3. No hay bypass posible via `search_path` injection

**Tabla de verificación RLS**:

| Tabla | SELECT | INSERT | UPDATE | DELETE | Estado |
|-------|--------|--------|--------|--------|--------|
| `books` | `is_admin()` | `is_admin()` | `is_admin()` | `is_admin()` | ✅ |
| `profiles` | `is_admin()` | — (own only) | `is_admin()` | — | ⚠️ Sin DELETE |
| `genres` | `true` | `is_admin()` | `is_admin()` | `is_admin()` | ✅ |
| `tooks` | `true` | `is_admin()` | `is_admin()` | `is_admin()` | ✅ |
| `chapters` | `true` | `is_admin()` | `is_admin()` | `is_admin()` | ✅ |
| `authors` | `true` | `is_admin()` | `is_admin()` | `is_admin()` | ✅ |
| `book_views` | `is_admin()` | `is_admin()` | — | — | ✅ |

**Acción**: Ejecutar `supabase_get_advisors(type: "security")` para detectar políticas faltantes o débiles.

**Acceptance criteria**:
- [ ] Todas las tablas admin-tienen RLS habilitado
- [ ] `is_admin()` es SECURITY DEFINER
- [ ] No hay políticas con `true` en INSERT/UPDATE/DELETE para tablas sensibles
- [ ] Auditoría de Supabase advisors sin issues de seguridad

---

### 1.2 Protección contra Auto-democión de Rol

**Esfuerzo**: S (1-2 horas)
**Archivos afectados**:
- `lib/features/admin/presentation/bloc/admin_users_bloc.dart`
- `lib/features/admin/presentation/bloc/admin_users_event.dart`
- `lib/features/admin/presentation/screens/users_tab.dart`

**Problema actual**: La RLS policy `"Admin can update profiles"` (`20260524100000`) permite al admin actualizar CUALQUIER campo de CUALQUIER profile, incluyendo su propio `role`. Un admin podría accidentalmente cambiarse a `user` y perder acceso al panel.

**Solución**: Validación en capa de aplicación ANTES de enviar a Supabase.

```dart
// En admin_users_bloc.dart, nuevo evento ChangeUserRole:
Future<void> _onChangeRole(ChangeUserRole event, Emitter<AdminUsersState> emit) async {
  // PREVENCIÓN: No permitir que el admin se cambie su propio rol
  if (event.targetUserId == _currentUserId) {
    emit(AdminUsersError('No puedes cambiar tu propio rol'));
    return;
  }
  // ... proceeding with role change
}
```

**Acceptance criteria**:
- [ ] Admin no puede cambiar su propio rol via UI
- [ ] SnackBar de error claro si se intenta
- [ ] Test unitario verifica que `ChangeUserRole` con `targetUserId == currentUserId` falla

---

### 1.3 Rate Limiting en Operaciones Destructivas

**Esfuerzo**: S (1-2 horas)
**Archivos afectados**:
- `lib/features/admin/presentation/bloc/admin_bloc.dart`
- `lib/features/admin/presentation/bloc/admin_users_bloc.dart`

**Problema actual**: No hay protección contra eliminación masiva de libros o usuarios. Un admin podría mantener presionado el botón de eliminar.

**Solución**: Debounce simple en el BLoC + cooldown entre operaciones destructivas.

```dart
// Patrón de cooldown en AdminBloc:
DateTime? _lastDeleteTime;
static const _deleteCooldown = Duration(seconds: 2);

Future<void> _onDeleteBook(DeleteAdminBook event, Emitter<AdminState> emit) async {
  if (_lastDeleteTime != null && 
      DateTime.now().difference(_lastDeleteTime!) < _deleteCooldown) {
    emit(AdminError('Espera un momento antes de eliminar otro libro'));
    return;
  }
  _lastDeleteTime = DateTime.now();
  // ... proceeding with deletion
}
```

**Acceptance criteria**:
- [ ] Cooldown de 2 segundos entre eliminaciones
- [ ] Mensaje de error si se intenta demasiado rápido
- [ ] Applies tanto a libros como a usuarios

---

## Fase 2: Gestión de Usuarios (P1 — 3-5 días)

### 2.1 Cambio de Rol de Usuarios (Promote/Demote)

**Esfuerzo**: M (medio día)
**Archivos afectados**:
- `lib/features/admin/presentation/bloc/admin_users_event.dart` — agregar `ChangeUserRole`
- `lib/features/admin/presentation/bloc/admin_users_bloc.dart` — handler
- `lib/features/admin/presentation/bloc/admin_users_state.dart` — agregar estado con mensaje
- `lib/features/profiles/domain/profiles_repository.dart` — agregar `updateUserRole()`
- `lib/features/profiles/data/profiles_repository_impl.dart` — implementar
- `lib/features/admin/presentation/screens/users_tab.dart` — UI de dropdown/dialog
- `lib/core/di/injection_profiles.dart` — registrar nuevo use case

**Nuevos eventos**:
```dart
class ChangeUserRole extends AdminUsersEvent {
  final String targetUserId;
  final String newRole; // 'user', 'scan', 'admin'
  const ChangeUserRole({required this.targetUserId, required this.newRole});
}
```

**Nuevos use cases**:
```dart
// lib/features/profiles/domain/update_user_role.dart
class UpdateUserRole {
  final ProfilesRepository repository;
  Future<Result<UserEntity>> call(String userId, String newRole) async {
    return repository.updateUserRole(userId: userId, role: newRole);
  }
}
```

**Nueva función en ProfilesRepositoryImpl**:
```dart
Future<Result<UserEntity>> updateUserRole({
  required String userId,
  required String role,
}) async {
  try {
    final response = await _supabase.client
        .from('profiles')
        .update({'role': role})
        .eq('id', userId)
        .select()
        .single();
    return Ok(UserModel.fromJson(response));
  } catch (e) {
    return Err(ProfileFailure('Error al cambiar rol', cause: e));
  }
}
```

**UI — Opción recomendada**: `PopupMenuButton` en cada `ListTile` de usuario con opciones:
- "Cambiar a Admin" (si no es admin)
- "Cambiar a Scan" (si no es scan)
- "Cambiar a User" (si no es user)

**Validación RLS**: La policy `"Admin can update profiles"` ya permite UPDATE en profiles. No necesita migración SQL.

**Acceptance criteria**:
- [ ] Admin puede cambiar rol de cualquier usuario excepto sí mismo
- [ ] Roles disponibles: `user`, `scan`, `admin`
- [ ] SnackBar de confirmación: "Rol de {email} cambiado a {role}"
- [ ] La lista se actualiza optimísticamente después del cambio
- [ ] Error handling si la BD rechaza el cambio

---

### 2.2 Eliminación y Suspensión de Usuarios

**Esfuerzo**: M (medio día)
**Archivos afectados**:
- `lib/features/admin/presentation/bloc/admin_users_event.dart` — agregar `DeleteUser`, `SuspendUser`
- `lib/features/admin/presentation/bloc/admin_users_bloc.dart` — handlers
- `lib/features/profiles/domain/profiles_repository.dart` — agregar métodos
- `lib/features/profiles/data/profiles_repository_impl.dart` — implementar
- `lib/features/admin/presentation/screens/users_tab.dart` — UI con dialogs

**Nuevos eventos**:
```dart
class DeleteUser extends AdminUsersEvent {
  final String targetUserId;
  const DeleteUser({required this.targetUserId});
}

class SuspendUser extends AdminUsersEvent {
  final String targetUserId;
  final bool suspend; // true = suspender, false = reactivar
  const SuspendUser({required this.targetUserId, required this.suspend});
}
```

**Consideración de Suspensión**: La tabla `profiles` NO tiene campo `is_suspended` o `is_active`. Dos opciones:

**Opción A (Recomendada)**: Agregar campo `is_suspended BOOLEAN DEFAULT false` via migración:
```sql
-- Migración: add_user_suspension.sql
ALTER TABLE profiles ADD COLUMN is_suspended BOOLEAN NOT NULL DEFAULT false;
```
Y actualizar `is_admin()` para que usuarios suspendidos no puedan autenticarse? NO — la suspensión es a nivel de app, no de auth. El usuario sigue autenticado pero la app bloquea acceso.

**Opción B (Simplificada)**: Usar un role especial `suspended`:
```sql
-- Actualizar CHECK constraint:
ALTER TABLE profiles DROP CONSTRAINT profiles_role_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check 
  CHECK (role IN ('user', 'scan', 'admin', 'suspended'));
```

**Recomendación**: Opción B — más simple, no requiere nueva columna, y el BLoC puede filtrar usuarios suspendidos.

**Eliminación real**: Usar `auth.admin.deleteUser()` de Supabase Admin API. Esto requiere que la app tenga acceso a la service_role key, o crear una Edge Function.

**⚠️ Decisión de diseño**: ¿Eliminar usuarios desde la app Flutter directamente?

- **Si NO (recomendado)**: La eliminación de usuarios solo se hace desde Supabase Dashboard. La UI del admin solo ofrece "Suspender".
- **Si SÍ**: Crear Edge Function `admin-delete-user` que use service_role para eliminar de `auth.users`.

**Acceptance criteria**:
- [ ] Admin puede suspender/reactivar usuarios
- [ ] Usuarios suspendidos no aparecen en la lista (o aparecen con badge "Suspendido")
- [ ] Eliminación de usuarios requiere confirmación con doble verificación (escribir email)
- [ ] Admin no puede eliminarse a sí mismo
- [ ] Si se implementa eliminación: usa Edge Function con service_role

---

### 2.3 Búsqueda de Usuarios

**Esfuerzo**: S (1-2 horas)
**Archivos afectados**:
- `lib/features/admin/presentation/screens/users_tab.dart`

**Implementación**: `TextField` con `onChanged` que filtra la lista local (ya cargada).

```dart
// En users_tab.dart, agregar arriba del ListView:
TextField(
  decoration: InputDecoration(
    hintText: 'Buscar por nombre o email...',
    prefixIcon: Icon(Icons.search),
    border: OutlineInputBorder(),
  ),
  onChanged: (query) {
    setState(() => _searchQuery = query.toLowerCase());
  },
),
// Filtrado:
final filteredUsers = users.where((u) =>
  u.email.toLowerCase().contains(_searchQuery) ||
  (u.displayName?.toLowerCase().contains(_searchQuery) ?? false)
).toList();
```

**Acceptance criteria**:
- [ ] Barra de búsqueda visible en el tab de Usuarios
- [ ] Filtra en tiempo real por nombre o email
- [ ] Muestra "No se encontraron resultados" cuando el filtro no matchea
- [ ] Búsqueda case-insensitive

---

### 2.4 Paginación en getAllProfiles()

**Esfuerzo**: M (medio día)
**Archivos afectados**:
- `lib/features/profiles/data/profiles_repository_impl.dart` — modificar `getAllProfiles()`
- `lib/features/profiles/domain/profiles_repository.dart` — cambiar interfaz
- `lib/features/profiles/domain/get_all_profiles.dart` — actualizar use case
- `lib/features/admin/presentation/bloc/admin_users_bloc.dart` — manejar paginación

**Problema actual** (línea 77 de `profiles_repository_impl.dart`):
```dart
.select('*').order('email').limit(100);
```
Hardcoded a 100 usuarios. Sin paginación.

**Solución**: Usar cursor-based pagination de Supabase:

```dart
// Nuevo firmas:
Future<Result<List<UserEntity>>> getAllProfiles({
  int limit = 50,
  String? afterEmail, // cursor para paginación
}) async {
  var query = _supabase.client
      .from('profiles')
      .select('*')
      .order('email');
  
  if (afterEmail != null) {
    query = query.gt('email', afterEmail);
  }
  
  final response = await query.limit(limit + 1); // +1 para detectar si hay más
  final hasMore = response.length > limit;
  final profiles = response
      .take(limit)
      .map((json) => UserModel.fromJson(json))
      .toList();
  return Ok(profiles);
}
```

**UI**: `ListView.builder` con `ScrollController` que carga más cuando se acerca al final (infinite scroll).

**Acceptance criteria**:
- [ ] Carga inicial de 50 usuarios
- [ ] Scroll infinito carga más cuando se llega al final
- [ ] Loading indicator al cargar más
- [ ] No hay límite hardcoded de 100

---

## Fase 3: Analytics y Dashboard (P1-P2 — 3-5 días)

### 3.1 Implementar Analytics Tab

**Esfuerzo**: L (1-2 días)
**Archivos afectados**:
- `lib/features/admin/presentation/screens/analytics_tab.dart` — reemplazar placeholder
- `lib/features/admin/presentation/bloc/admin_analytics_bloc.dart` — NUEVO
- `lib/features/admin/presentation/bloc/admin_analytics_event.dart` — NUEVO
- `lib/features/admin/presentation/bloc/admin_analytics_state.dart` — NUEVO
- `lib/features/admin/domain/analytics_repository.dart` — NUEVO
- `lib/features/admin/data/analytics_repository_impl.dart` — NUEVO
- `lib/core/di/injection_admin.dart` — registrar nuevas dependencias
- `lib/features/admin/presentation/screens/admin_dash_screen.dart` — proveer BLoC

**La tabla `book_views` ya existe** con estos índices optimizados:
- `idx_book_views_book_id`
- `idx_book_views_viewed_at`
- `idx_book_views_book_viewed_at` (compuesto)

**RLS ya configurado**:
- INSERT: Solo admin (`is_admin()`)
- SELECT: Solo admin (`is_admin()`)

**Nuevos BLoC y Use Cases**:
```dart
// admin_analytics_event.dart
class LoadAnalyticsOverview extends AdminAnalyticsEvent {}
class LoadBookViewsTrend extends AdminAnalyticsEvent {
  final int days; // 7, 30, 90
}
class LoadTopBooks extends AdminAnalyticsEvent {
  final int limit;
}

// admin_analytics_state.dart
class AnalyticsOverview {
  final int totalViews;
  final int totalBooks;
  final int viewsToday;
  final double avgViewsPerBook;
}
```

**Queries SQL necesarias** (via Edge Function o RPC):

```sql
-- Views por día (últimos N días)
CREATE OR REPLACE FUNCTION get_views_trend(days_back INT DEFAULT 30)
RETURNS TABLE(view_date DATE, view_count BIGINT)
LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT DATE(viewed_at) as view_date, COUNT(*) as view_count
  FROM book_views
  WHERE viewed_at >= NOW() - (days_back || ' days')::INTERVAL
  GROUP BY DATE(viewed_at)
  ORDER BY view_date;
$$;

-- Top libros por vistas
CREATE OR REPLACE FUNCTION get_top_books(limit_count INT DEFAULT 10)
RETURNS TABLE(book_id BIGINT, book_name TEXT, view_count BIGINT)
LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT bv.book_id, b.name as book_name, COUNT(*) as view_count
  FROM book_views bv
  JOIN books b ON b.id = bv.book_id
  GROUP BY bv.book_id, b.name
  ORDER BY view_count DESC
  LIMIT limit_count;
$$;
```

**Acceptance criteria**:
- [ ] Analytics tab muestra métricas reales (no placeholder)
- [ ] Total de vistas, vistas hoy, top libros
- [ ] Gráfico de tendencia de vistas (puede ser simple con CustomPainter o fl_chart)
- [ ] Datos cargan desde `book_views` via RPC functions
- [ ] Loading states y error handling

---

### 3.2 Tracking de Vistas de Libros

**Esfuerzo**: M (medio día)
**Archivos afectados**:
- `lib/features/books/presentation/screens/book_detail_screen.dart` — registrar vista al abrir
- `lib/features/books/domain/track_book_view.dart` — NUEVO use case
- `lib/features/books/data/book_repository_impl.dart` — implementar

**Problema**: La tabla `book_views` existe pero ningún código inserta datos.

**Solución**: Registrar vista cuando el usuario abre un libro (con debounce para no contar múltiples taps).

```dart
// En book_detail_screen.dart, initState:
@override
void initState() {
  super.initState();
  // Track view con debounce
  _trackView();
}

void _trackView() async {
  // Esperar 2 segundos antes de registrar (usuario realmente leyó)
  await Future.delayed(const Duration(seconds: 2));
  if (mounted) {
    context.read<BookBloc>().add(TrackBookView(widget.bookId));
  }
}
```

```dart
// Nuevo use case:
class TrackBookView {
  final BookRepository repository;
  Future<Result<void>> call(int bookId) async {
    return repository.trackBookView(bookId);
  }
}
```

```dart
// En BookRepositoryImpl:
Future<Result<void>> trackBookView(int bookId) async {
  try {
    await _supabase.client.from('book_views').insert({
      'book_id': bookId,
      'viewed_at': DateTime.now().toUtc().toIso8601String(),
    });
    return const Ok(null);
  } catch (e) {
    return Err(BookFailure('Error tracking view', cause: e));
  }
}
```

**Acceptance criteria**:
- [ ] Al abrir un libro, se registra una vista después de 2 segundos
- [ ] No se registran vistas duplicadas en la misma sesión
- [ ] El tracking no afecta el rendimiento de la pantalla del libro
- [ ] Errores de tracking no impactan la experiencia del usuario

---

### 3.3 Dashboard de Métricas

**Esfuerzo**: M (medio día)
**Archivos afectados**:
- `lib/features/admin/presentation/screens/admin_dash_screen.dart` — agregar overview card
- `lib/features/admin/presentation/widgets/dashboard_metrics_card.dart` — NUEVO widget

**Métricas a mostrar en el dashboard principal** (antes de los tabs):
- Total de libros (visibles vs ocultos)
- Total de usuarios (por rol)
- Vistas hoy
- Último libro agregado

**Acceptance criteria**:
- [ ] Dashboard muestra métricas de resumen antes de los tabs
- [ ] Datos se cargan al montar el screen
- [ ] Pull-to-refresh actualiza métricas
- [ ] Métricas son non-clickable (solo informativas)

---

## Fase 4: Features Adicionales (P2 — 3-5 días)

### 4.1 Creación de Libros desde Admin

**Esfuerzo**: L (1-2 días)
**Archivos afectados**:
- `lib/features/admin/presentation/screens/books_tab.dart` — agregar FAB
- `lib/features/admin/presentation/screens/create_book_screen.dart` — NUEVO
- `lib/features/admin/presentation/bloc/admin_event.dart` — agregar `CreateAdminBook`
- `lib/features/admin/presentation/bloc/admin_bloc.dart` — handler
- `lib/features/books/domain/create_book.dart` — NUEVO use case
- `lib/features/books/data/book_repository_impl.dart` — implementar
- `lib/core/di/injection_books.dart` — registrar

**Decisión de diseño**: El admin actualmente NO puede crear libros — solo scan puede. Pero la RLS ya lo permite (`INSERT books: is_admin()`).

**UI**: FAB en `BooksTab` que abre `CreateBookScreen` con:
- Campo nombre
- Campo autor (buscar existente o crear nuevo)
- Selección de géneros (multi-select)
- Upload de portada
- Botón "Crear" → `CreateAdminBook`

**Acceptance criteria**:
- [ ] FAB visible en el tab de Libros
- [ ] Formulario de creación con todos los campos necesarios
- [ ] El libro se crea con `is_visible = false` por defecto
- [ ] Después de crear, el admin puede hacer toggle para publicar
- [ ] La lista se actualiza optimísticamente

---

### 4.2 Enum de Roles (Reemplazar Strings)

**Esfuerzo**: M (medio día)
**Archivos afectados**:
- `lib/features/profiles/domain/user_entity.dart` — cambiar `String role` a `UserRole role`
- NUEVO: `lib/features/profiles/domain/user_role.dart` — definir enum
- `lib/features/profiles/data/user_model.dart` — actualizar serialización
- Todos los archivos que usan `role == 'admin'`, `role == 'scan'`, etc.

**Nuevo enum**:
```dart
enum UserRole {
  user('user'),
  scan('scan'),
  admin('admin');

  final String value;
  const UserRole(this.value);
  
  factory UserRole.fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.user,
    );
  }
}
```

**Impacto**: Cambio en `UserEntity.role` de `String` a `UserRole`. Actualizar todos los `role == 'admin'` a `role == UserRole.admin`. Propagación media — toca ~15 archivos.

**Acceptance criteria**:
- [ ] `UserRole` enum definido con `user`, `scan`, `admin`
- [ ] `UserEntity.role` es tipo `UserRole` en vez de `String`
- [ ] `isAdmin` y `isScan` usan el enum internamente
- [ ] Serialización funciona correctamente (fromJson/toJson)
- [ ] Todos los archivos actualizados compilan sin errores

---

### 4.3 Bulk Operations (Libros)

**Esfuerzo**: M (medio día)
**Archivos afectados**:
- `lib/features/admin/presentation/screens/books_tab.dart` — modo selección
- `lib/features/admin/presentation/bloc/admin_event.dart` — agregar `BulkToggleVisibility`, `BulkDelete`

**Implementación**: Long-press para entrar en modo selección, checkboxes en cada libro, action bar arriba con opciones:
- "Publicar seleccionados"
- "Ocultar seleccionados"
- "Eliminar seleccionados"

**Acceptance criteria**:
- [ ] Long-press activa modo selección
- [ ] Checkbox visible en cada libro en modo selección
- [ ] Action bar muestra contadores y acciones
- [ ] Confirmación antes de bulk delete
- [ ] Las operaciones se ejecutan en batch (no una por una)

---

### 4.4 Genre Ordering/Priority

**Esfuerzo**: S (1-2 horas)
**Archivos afectados**:
- Migración SQL: agregar campo `sort_order INT DEFAULT 0` a `genres`
- `lib/features/genres/domain/genre_entity.dart` — agregar `sortOrder`
- `lib/features/genres/data/genre_model.dart` — serializar
- `lib/features/admin/presentation/screens/genres_tab.dart` — UI de reorden

**Implementación**: Agregar `sort_order` a la tabla `genres` y usar `ReorderableListView` en el tab.

**Acceptance criteria**:
- [ ] Campo `sort_order` agregado a `genres`
- [ ] Géneros se muestran en orden personalizado
- [ ] Admin puede reordenar con drag-and-drop
- [ ] El orden se persiste en la BD

---

## Fase 5: Polish (P3 — 2-4 días)

### 5.1 Confirmation Dialogs Mejorados

**Esfuerzo**: S (1-2 horas)
**Archivos afectados**:
- `lib/features/admin/presentation/screens/books_tab.dart` — delete dialog
- `lib/features/admin/presentation/screens/users_tab.dart` — role change dialog
- NUEVO: `lib/shared/presentation/widgets/confirmation_dialog.dart`

**Problema actual**: El dialog de confirmación de eliminación de libros (línea 201-225 de `books_tab.dart`) es básico — solo dice "¿Estás seguro?".

**Mejoras**:
- Para eliminación de libros: mostrar nombre del libro, información de cascade (capítulos, labels que se eliminarán)
- Para cambio de rol: mostrar usuario actual y nuevo rol
- Para eliminación de usuarios: requerir escribir el email para confirmar
- Usar `AlertDialog` con acciones estilizadas (rojo para destructivas)

**Acceptance criteria**:
- [ ] Todos los dialogs destructivos muestran contexto claro
- [ ] Eliminación de usuario requiere escribir email
- [ ] Eliminación de libro muestra info de cascade
- [ ] Consistencia visual en todos los dialogs

---

### 5.2 Loading States y Error Handling

**Esfuerzo**: S (1-2 horas)
**Archivos afectados**:
- Todos los screens del admin

**Mejoras**:
- Skeleton loading en vez de CircularProgressIndicator genérico
- Empty states con ilustración y acción sugerida
- Error states con retry button y mensaje descriptivo
- SnackBar consistente (ya parcialmente implementado)

**Acceptance criteria**:
- [ ] Skeleton loading en todos los tabs
- [ ] Empty states con ilustración y CTA
- [ ] Error states con retry
- [ ] SnackBar messages consistentes

---

### 5.3 Tests Unitarios para BLoCs Admin

**Esfuerzo**: L (1-2 días)
**Archivos afectados**:
- NUEVO: `test/features/admin/presentation/bloc/admin_bloc_test.dart`
- NUEVO: `test/features/admin/presentation/bloc/admin_users_bloc_test.dart`

**Tests a cubrir**:

```dart
// admin_bloc_test.dart
group('AdminBloc', () {
  test('LoadAdminBooks emits AdminLoaded with books', () {});
  test('LoadAdminBooks emits AdminError on failure', () {});
  test('ToggleBookVisibility updates book in state', () {});
  test('ToggleBookVisibility emits error on failure', () {});
  test('DeleteAdminBook removes book from state', () {});
  test('DeleteAdminBook emits error on failure', () {});
  test('Delete cooldown prevents rapid deletions', () {});
});

// admin_users_bloc_test.dart
group('AdminUsersBloc', () {
  test('LoadAdminUsers emits AdminUsersLoaded', () {});
  test('LoadAdminUsers emits AdminUsersError on failure', () {});
  test('ChangeUserRole updates user role in state', () {});
  test('ChangeUserRole prevents self-demotion', () {});
  test('DeleteUser removes user from state', () {});
  test('SuspendUser marks user as suspended', () {});
});
```

**Acceptance criteria**:
- [ ] Coverage > 80% para ambos BLoCs
- [ ] Tests pasan en CI
- [ ] Happy path y error path cubiertos
- [ ] Edge cases: self-demotion, rapid deletion, network error

---

### 5.4 Tests de Integración para Admin Flows

**Esfuerzo**: L (1-2 días)
**Archivos afectados**:
- NUEVO: `test/features/admin/presentation/screens/admin_dash_screen_test.dart`
- NUEVO: `test/features/admin/presentation/screens/users_tab_test.dart`

**Flujos a testear**:
1. Login como admin → llega a `AdminDashScreen`
2. Cambiar tab de Libros a Géneros a Usuarios a Analytics
3. Cambiar rol de un usuario
4. Crear un libro desde admin
5. Toggle visibilidad de un libro
6. Eliminar un libro (confirmación)

**Acceptance criteria**:
- [ ] Tests de widget para cada tab
- [ ] Tests de navegación entre tabs
- [ ] Tests de interacciones (tap, scroll, search)
- [ ] Mock de Supabase client

---

## Estimación Total

| Fase | Descripción | Esfuerzo | Días estimados |
|------|-------------|----------|----------------|
| **Fase 1** | Seguridad y Acceso | S+S+S | 0.5 días |
| **Fase 2** | Gestión de Usuarios | M+M+S+M | 3-4 días |
| **Fase 3** | Analytics y Dashboard | L+M+M | 3-4 días |
| **Fase 4** | Features Adicionales | L+M+M+S | 3-5 días |
| **Fase 5** | Polish | S+S+L+L | 3-4 días |
| **TOTAL** | | | **~12-18 días** |

**Ruta crítica**: Fase 1 → Fase 2 (seguridad antes de escritura) → Fase 3 (analytics independiente) → Fase 5 (tests después de features)

---

## Riesgos y Consideraciones

### Riesgos Técnicos

1. **Eliminación de usuarios**: Requiere service_role key de Supabase. Si se hace desde la app, se expone la key. **Mitigación**: Usar Edge Function con JWT verification.

2. **Performance de `getAllProfiles()`**: Con paginación, si hay miles de usuarios, el scroll infinito puede ser lento. **Mitigación**: Índice en `email` + cache local.

3. **RLS bypass potencial**: La policy `"Admin can update profiles"` permite cambiar el campo `role`. Si un admin malicioso usa Supabase client directamente (fuera de la app), puede asignarse permisos. **Mitigación**: Validación en Edge Functions para cambios de rol críticos.

4. **Enum propagation**: Cambiar `String role` a `UserRole role` toca ~15 archivos. **Mitigación**: Hacerlo como PR dedicado con tests antes de merge.

### Riesgos de UX

1. **Bulk operations**: El admin podría eliminar muchos libros accidentemente. **Mitigación**: Confirmación con conteo ("Vas a eliminar 15 libros. Esta acción no se puede deshacer.").

2. **Analytics performance**: Queries de agregación sobre `book_views` pueden ser lentas con muchos datos. **Mitigación**: Usar materialized views o cachear resultados.

3. **Role change cascade**: Cambiar un usuario de `admin` a `user` podría dejar al sistema sin admin. **Mitigación**: Validar que siempre hay al menos un admin activo.

### Decisiones Pendientes

1. **¿Admin puede crear libros?** — La RLS lo permite, pero la UI no. Se recomienda SÍ (Fase 4.1).
2. **¿Eliminar usuarios desde la app?** — Se recomienda NO, solo suspender. Eliminación desde Supabase Dashboard.
3. **¿Nuevo rol "editor"?** — La auditoría lo menciona pero no es urgente. Puede ser Fase 6.
4. **¿Gráficos en analytics?** — ¿Usar `fl_chart` o solo números? Se recomienda empezar con números y agregar gráficos después.

---

## Archivos Nuevos a Crear

| Archivo | Fase | Propósito |
|---------|------|-----------|
| `lib/features/admin/presentation/bloc/admin_analytics_bloc.dart` | 3 | BLoC de analytics |
| `lib/features/admin/presentation/bloc/admin_analytics_event.dart` | 3 | Eventos de analytics |
| `lib/features/admin/presentation/bloc/admin_analytics_state.dart` | 3 | Estados de analytics |
| `lib/features/admin/domain/analytics_repository.dart` | 3 | Interfaz de analytics |
| `lib/features/admin/data/analytics_repository_impl.dart` | 3 | Implementación de analytics |
| `lib/features/admin/presentation/widgets/dashboard_metrics_card.dart` | 3 | Widget de métricas |
| `lib/features/admin/presentation/screens/create_book_screen.dart` | 4 | Formulario de creación |
| `lib/features/profiles/domain/user_role.dart` | 4 | Enum de roles |
| `lib/features/profiles/domain/update_user_role.dart` | 2 | Use case de cambio de rol |
| `lib/features/books/domain/track_book_view.dart` | 3 | Use case de tracking |
| `lib/shared/presentation/widgets/confirmation_dialog.dart` | 5 | Dialog reutilizable |
| `test/features/admin/presentation/bloc/admin_bloc_test.dart` | 5 | Tests de AdminBloc |
| `test/features/admin/presentation/bloc/admin_users_bloc_test.dart` | 5 | Tests de AdminUsersBloc |

---

## Archivos Existentes a Modificar

| Archivo | Fase | Cambio |
|---------|------|--------|
| `lib/features/admin/presentation/screens/analytics_tab.dart` | 3 | Reemplazar placeholder con métricas reales |
| `lib/features/admin/presentation/screens/users_tab.dart` | 2 | Agregar búsqueda, acciones de rol, suspensión |
| `lib/features/admin/presentation/screens/books_tab.dart` | 4 | Agregar FAB para crear libro, bulk operations |
| `lib/features/admin/presentation/screens/admin_dash_screen.dart` | 3 | Proveedor de AnalyticsBloc, dashboard metrics |
| `lib/features/admin/presentation/bloc/admin_bloc.dart` | 1 | Cooldown, bulk events |
| `lib/features/admin/presentation/bloc/admin_event.dart` | 4 | CreateAdminBook, BulkToggle, BulkDelete |
| `lib/features/admin/presentation/bloc/admin_users_bloc.dart` | 2 | ChangeUserRole, DeleteUser, SuspendUser |
| `lib/features/admin/presentation/bloc/admin_users_event.dart` | 2 | Nuevos eventos |
| `lib/features/admin/presentation/bloc/admin_users_state.dart` | 2 | Estados con mensaje |
| `lib/features/profiles/data/profiles_repository_impl.dart` | 2 | updateUserRole(), paginación |
| `lib/features/profiles/domain/profiles_repository.dart` | 2 | updateUserRole() abstract |
| `lib/features/profiles/domain/user_entity.dart` | 4 | UserRole enum |
| `lib/features/profiles/data/user_model.dart` | 4 | Serialización de enum |
| `lib/core/di/injection_admin.dart` | 2,3 | Registrar nuevos BLoCs y use cases |
| `lib/core/di/injection_profiles.dart` | 2 | Registrar UpdateUserRole |
| `lib/core/di/injection_books.dart` | 4 | Registrar CreateBook, TrackBookView |

---

*Plan generado como parte de la fase de exploración SDD para la mejora del rol de administrador en Noveles.*
