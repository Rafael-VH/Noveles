# Plan Unificado de Implementación — Noveles

> Generado: 2026-07-20 | Fusión de 3 planes individuales (user/scan/admin)
> Proyecto: Noveles Flutter + Supabase
> Roles en sistema: `user` | `scan` | `admin`
> Esfuerzo total estimado: ~34-46 días (1 desarrollador) / ~18-24 días (2 en paralelo)

---

## Resumen Ejecutivo

Este plan unifica las mejoras propuestas para los tres roles del sistema — usuario regular, scan y administrador — en una secuencia de 7 fases que respetan dependencias, evitan conflictos entre ramas y priorizan la seguridad antes que las features. El resultado es un roadmap donde un desarrollador puede empezar por cualquier fase sin riesgo de romper trabajo hecho en otra.

Las vulnerabilidades de seguridad más críticas son: (1) RLS policies de `tooks` y `chapters` que no verifican ownership — cualquier scan puede modificar datos de otro scan; (2) Storage buckets sin control de acceso por carpeta de usuario; (3) Falta del getter `isUser` y la función SQL `is_user()` que hacen el routing frágil y bloquean features como favoritos. Estas se resuelven en las Fases 1 y 2 (P0).

A partir de allí, las fases 3-5 trabajan en paralelo sobre features específicas de cada rol: favoritos y lectura (regular), decomposición del ScanBloc y gestión de etiquetas (scan), gestión de usuarios y creación de libros (admin). La fase 6 implementa analytics sobre la tabla `book_views` que ya existe pero nadie llena. La fase 7 consolida todo con polish, empty states, tests y documentación.

La decisión de diseño más impactante pendiente es el campo `is_favorite` en la tabla `books` — es un booleano GLOBAL no vinculado a usuario. Para "favoritos personales" se necesita una tabla `user_favorites` nueva. Esta decisión se debe tomar ANTES de iniciar la Fase 3.

---

## Dependencias entre Roles

| Componente compartido | Regular | Scan | Admin | Notas |
|----------------------|---------|------|-------|-------|
| `UserEntity` / getters de rol | Agrega `isUser` | — | Agrega `UserRole` enum | `isUser` primero, enum después |
| `UserModel.fromJson` | Valida roles | — | Serializa enum | Validación primero, enum después |
| `app.dart` routing | Guard explícito con `isUser` | — | — | Requiere `isUser` getter |
| `AppDrawer` | Pasa valores reales | Agrega "Etiquetas" | — | Merge carefully |
| `BookRepositoryImpl` | Paginación | Storage cleanup, filename pattern | Crear libro, track views | Archivo más conflictivo — ordenar |
| `book_repository.dart` | — | Renombrar método | Agregar métodos | Interface compartida |
| `ChapterRepositoryImpl` | — | Filename pattern, storage cleanup | — | Solo scan |
| RLS policies (DB) | `is_user()` helper, favorites | Ownership checks (tooks, chapters, storage) | Validación de policies existentes | DB changes affect ALL |
| `GenreCubit` | — | Crea (compartido) | — | Nuevo, beneficia a todos |
| `profiles_repository_impl.dart` | — | — | `updateUserRole()`, paginación | Solo admin |

### Puntos de Conflicto Identificados

1. **`book_repository_impl.dart`** — Modificado por los 3 planes (paginación regular, storage scan, create/track admin). Resolución: implementar en orden de fase, cada cambio en commit separado.
2. **`app_drawer.dart`** — Modificado por regular (valores reales) y scan (entry de etiquetas). Resolución: un solo paso en Fase 3+4.
3. **`user_entity.dart`** — Modificado por regular (`isUser`) y admin (`UserRole` enum). Resolución: `isUser` en Fase 1, enum en Fase 7.
4. **Migraciones SQL** — Todas las fases generan migraciones. Resolución: naming convention `YYYYMMDDHHMMSS_descripcion.sql`, aplicar en orden cronológico.

---

## Fase 1: Fundamentos y Seguridad (P0) — ~3-5 días

**Objetivo**: Establecer la base compartida de integridad de datos, validación de roles y reglas de routing. Todo lo demás depende de esto.

**Dependencias previas**: Ninguna. Esta fase es el cimiento.

### 1.1 Agregar `isUser` getter a `UserEntity`

**Why**: `UserEntity` tiene `isScan` (L20) e `isAdmin` (L21) pero NO `isUser`. El routing en `app.dart` L54-62 llega al usuario regular solo por exclusión. Si mañana se agrega un rol nuevo, se escapa de la lógica. Este getter es prerequisite para 1.3 y para las RLS policies de favoritos.

**Qué hacer**:
```dart
// lib/features/profiles/domain/user_entity.dart — agregar después de L21
bool get isUser => role == 'user';
```

**Archivos afectados**:
- `lib/features/profiles/domain/user_entity.dart` — 1 línea

**Risk**: Nulo. Agrega un getter, no modifica existentes.

**Verification**:
- `UserEntity(role: 'user', ...).isUser == true`
- `UserEntity(role: 'admin', ...).isUser == false`
- `UserEntity(role: 'scan', ...).isUser == false`
- Tests existentes compilan y pasan

---

### 1.2 Validar `role` en `UserModel.fromJson`

**Why**: Actualmente `UserModel.fromJson` acepta CUALQUIER string como `role`. Si Supabase retorna `role: 'hacker'`, se deserializa sin error y el routing cae al fallback de `MainScreen` sin aviso.

**Qué hacer**:
```dart
// lib/features/profiles/data/user_model.dart — modificar la línea donde se lee role
role: _validateRole(json['role'] as String?),

// Agregar helper estático:
static String _validateRole(String? role) {
  const validRoles = {'user', 'admin', 'scan'};
  final r = role ?? 'user';
  if (!validRoles.contains(r)) return 'user'; // fallback seguro
  return r;
}
```

**Archivos afectados**:
- `lib/features/profiles/data/user_model.dart` — agregar validación + helper

**Risk**: Bajo. El fallback a `'user'` es seguro — usuarios con rol inválido pierden acceso a admin/scan pero mantienen acceso básico.

**Verification**:
- `UserModel.fromJson({'id': 'x', 'role': 'hacker'})` → `role == 'user'`
- `UserModel.fromJson({'id': 'x', 'role': null})` → `role == 'user'`
- Roles válidos pasan sin cambios

---

### 1.3 Guard de rol explícito en `app.dart`

**Why**: El routing actual (L54-62 de `app.dart`) usa exclusión por ausencia. Con `isUser` disponible, se puede hacer explícito y seguro. Cualquier rol nuevo que no sea admin/scan/user ahora redirige a login en vez de caer silenciosamente a `MainScreen`.

**Qué hacer**:
```dart
// lib/core/app/app.dart — líneas 54-62, reemplazar:
if (authState is AuthAuthenticated) {
  if (authState.user.isAdmin) return const AdminDashScreen();
  if (authState.user.isScan) return const ScanMainScreen();
  if (authState.user.isUser) return const MainScreen();
  // Rol desconocido → cerrar sesión forzosamente
  return const LoginScreen();
}
return const LoginScreen();
```

**Archivos afectados**:
- `lib/core/app/app.dart` — modificar bloque de routing (L54-62)

**Dependencias**: Requiere 1.1 (`isUser` getter).

**Risk**: Bajo. El comportamiento actual se preserva exactamente — solo se hace explícito lo que antes era implícito.

**Verification**:
- Login como `user` → `MainScreen`
- Login como `admin` → `AdminDashScreen`
- Login como `scan` → `ScanMainScreen`
- Login con rol inválido → `LoginScreen`

---

### 1.4 Agregar función SQL `is_user()` helper

**Why**: Existen `is_admin()`, `is_scan()` e `is_admin_or_scan()` como helpers SQL, pero NO `is_user()`. Se necesita para las futuras RLS policies de favoritos (Fase 3) y es good practice para consistencia.

**Qué hacer**:
```sql
-- Nueva migración: supabase/migrations/YYYYMMDDHHMMSS_add_is_user_helper.sql
CREATE OR REPLACE FUNCTION public.is_user()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'user');
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```

**Archivos afectados**:
- `supabase/migrations/YYYYMMDDHHMMSS_add_is_user_helper.sql` — nueva migración

**Risk**: Nulo. Función nueva, no existente.

**Verification**:
- `SELECT public.is_user()` retorna `true` para usuario con `role = 'user'`
- `SELECT public.is_user()` retorna `false` para admin/scan
- `supabase get_advisors(type: "security")` sin nuevos issues

---

### 1.5 Validación de RLS Policies para Admin

**Why**: Verificar que todas las policies de admin existentes son correctas ANTES de implementar features de escritura de admin. La tabla `profiles` no tiene DELETE policy (el admin no puede eliminar usuarios — esto es intencional pero debe documentarse).

**Qué hacer**:
1. Ejecutar `supabase_get_advisors(type: "security")` y `supabase_get_advisors(type: "performance")`
2. Verificar cada tabla de la auditoría del plan admin:

| Tabla | SELECT | INSERT | UPDATE | DELETE | Estado |
|-------|--------|--------|--------|--------|--------|
| `books` | `is_admin()` | `is_admin()` | `is_admin()` | `is_admin()` | ✅ Verificar |
| `profiles` | `is_admin()` | — (own only) | `is_admin()` | — | ⚠️ Sin DELETE |
| `genres` | `true` | `is_admin()` | `is_admin()` | `is_admin()` | ✅ Verificar |
| `tooks` | `true` | `is_admin()` | `is_admin()` | `is_admin()` | ✅ Verificar |
| `chapters` | `true` | `is_admin()` | `is_admin()` | `is_admin()` | ✅ Verificar |
| `authors` | `true` | `is_admin()` | `is_admin()` | `is_admin()` | ✅ Verificar |
| `book_views` | `is_admin()` | `is_admin()` | — | — | ✅ Verificar |

3. Documentar hallazgos en `docs/rls-audit.md`

**Archivos afectados**:
- `supabase/migrations/` — verificación, posibles fixes menores
- `docs/rls-audit.md` — documentación

**Risk**: Bajo. Solo verificación y documentación.

**Verification**:
- `supabase_get_advisors(type: "security")` sin issues de seguridad
- Todas las tablas tienen RLS habilitado
- `is_admin()` es SECURITY DEFINER
- No hay políticas con `true` en INSERT/UPDATE/DELETE para tablas sensibles

---

### 1.6 Protección contra auto-democión de rol

**Why**: La RLS policy `"Admin can update profiles"` permite al admin actualizar CUALQUIER campo de CUALQUIER profile, incluyendo su propio `role`. Un admin podría accidentalmente cambiarse a `user` y perder acceso al panel. Esta protección DEBE estar en la capa de aplicación ANTES de que se implemente el cambio de rol (Fase 5).

**Qué hacer**:
```dart
// lib/features/admin/presentation/bloc/admin_users_bloc.dart
// Nuevo evento ChangeUserRole con validación de self-demotion:

class ChangeUserRole extends AdminUsersEvent {
  final String targetUserId;
  final String newRole;
  const ChangeUserRole({required this.targetUserId, required this.newRole});
}

// En el handler:
Future<void> _onChangeRole(ChangeUserRole event, Emitter<AdminUsersState> emit) async {
  if (event.targetUserId == _currentUserId) {
    emit(AdminUsersError('No puedes cambiar tu propio rol'));
    return;
  }
  // ... proceeding with role change
}
```

**Archivos afectados**:
- `lib/features/admin/presentation/bloc/admin_users_bloc.dart` — agregar handler
- `lib/features/admin/presentation/bloc/admin_users_event.dart` — agregar `ChangeUserRole`
- `lib/features/admin/presentation/bloc/admin_users_state.dart` — agregar estado con mensaje

**Dependencias**: Ninguna directa, pero se prepara para Fase 5.

**Risk**: Bajo. Solo agrega validación defensiva.

**Verification**:
- Admin no puede cambiar su propio rol via UI
- SnackBar de error claro si se intenta
- Test unitario verifica que `ChangeUserRole` con `targetUserId == currentUserId` falla

---

### 1.7 Rate limiting en operaciones destructivas

**Why**: No hay protección contra eliminación masiva de libros o usuarios. Un admin podría mantener presionado el botón de eliminar.

**Qué hacer**:
```dart
// lib/features/admin/presentation/bloc/admin_bloc.dart
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

**Archivos afectados**:
- `lib/features/admin/presentation/bloc/admin_bloc.dart` — cooldown
- `lib/features/admin/presentation/bloc/admin_users_bloc.dart` — cooldown similar para usuarios

**Risk**: Nulo. Solo agrega protecciones.

**Verification**:
- Cooldown de 2 segundos entre eliminaciones
- Mensaje de error si se intenta demasiado rápido
- Aplica tanto a libros como a usuarios

---

## Fase 2: Seguridad Scan (P0) — ~2-3 días

**Objetivo**: Eliminar las vulnerabilidades que permiten a un scan modificar datos de otro scan. Esta fase es CRÍTICA y debe completarse antes de cualquier refactorización de código scan.

**Dependencias**: Fase 1 completada (is_user helper disponible).

**⚠️ NOTA**: Las migraciones SQL de esta fase afectan TODOS los roles. Un error aquí puede romper la app para todos los usuarios. Testear en entorno local ANTES de aplicar a producción.

### 2.1 RLS ownership check en `tooks`

**Why**: Las políticas INSERT/UPDATE/DELETE de `tooks` verifican solo `is_scan()` pero NO verifican `created_by = auth.uid()`. Cualquier scan puede modificar tomos de cualquier otro scan. **Vulnerabilidad activa.**

**Qué hacer**:
```sql
-- Nueva migración: supabase/migrations/YYYYMMDDHHMMSS_fix_tooks_rls_ownership.sql

-- 1. Eliminar políticas antiguas sin ownership
DROP POLICY IF EXISTS "Enable insert for scan only" ON public.tooks;
DROP POLICY IF EXISTS "Enable update for scan only" ON public.tooks;
DROP POLICY IF EXISTS "Enable delete for scan only" ON public.tooks;

-- 2. Crear nuevas políticas con ownership via join a books
CREATE POLICY "Scan can insert own tooks"
  ON public.tooks FOR INSERT
  WITH CHECK (
    is_scan() AND
    EXISTS (
      SELECT 1 FROM public.books
      WHERE books.id = tooks.book_id
      AND books.created_by = auth.uid()
    )
  );

CREATE POLICY "Scan can update own tooks"
  ON public.tooks FOR UPDATE
  USING (
    is_scan() AND
    EXISTS (
      SELECT 1 FROM public.books
      WHERE books.id = tooks.book_id
      AND books.created_by = auth.uid()
    )
  );

CREATE POLICY "Scan can delete own tooks"
  ON public.tooks FOR DELETE
  USING (
    is_scan() AND
    EXISTS (
      SELECT 1 FROM public.books
      WHERE books.id = tooks.book_id
      AND books.created_by = auth.uid()
    )
  );
```

**Nota**: `tooks` tiene FK a `books` via `book_id`, así que podemos verificar ownership del libro padre sin agregar `created_by` a la tabla `tooks`. Se requiere que `books.created_by` esté indexado.

**Archivos afectados**:
- `supabase/migrations/YYYYMMDDHHMMSS_fix_tooks_rls_ownership.sql` — nueva migración
- Verificar índice en `books.created_by`

**Risk**: MEDIO. Los JOINs en RLS policies agregan overhead. Verificar que las FK estén indexadas antes de aplicar. Si hay tablas grandes, medir performance.

**Verification**:
- Scan A NO puede INSERT/UPDATE/DELETE tooks de un libro creado por scan B
- Scan A SÍ puede INSERT/UPDATE/DELETE tooks de libros propios
- Admin sigue pudiendo modificar cualquier took
- `EXPLAIN ANALYZE` en una query de tooks no muestra seq scan

---

### 2.2 RLS ownership check en `chapters`

**Why**: Vulnerabilidad idéntica a tooks. Las políticas de `chapters` verifican solo `is_scan()` sin ownership. La cadena FK `chapters.took_id → tooks.id → tooks.book_id → books.created_by` permite verificar ownership.

**Qué hacer**:
```sql
-- Nueva migración: supabase/migrations/YYYYMMDDHHMMSS_fix_chapters_rls_ownership.sql

-- 1. Eliminar políticas antiguas
DROP POLICY IF EXISTS "Enable insert for scan only" ON public.chapters;
DROP POLICY IF EXISTS "Enable update for scan only" ON public.chapters;
DROP POLICY IF EXISTS "Enable delete for scan only" ON public.chapters;

-- 2. Ownership check via took → book → created_by
CREATE POLICY "Scan can insert own chapters"
  ON public.chapters FOR INSERT
  WITH CHECK (
    is_scan() AND
    EXISTS (
      SELECT 1 FROM public.tooks
      JOIN public.books ON books.id = tooks.book_id
      WHERE tooks.id = chapters.took_id AND books.created_by = auth.uid()
    )
  );

CREATE POLICY "Scan can update own chapters"
  ON public.chapters FOR UPDATE
  USING (
    is_scan() AND
    EXISTS (
      SELECT 1 FROM public.tooks
      JOIN public.books ON books.id = tooks.book_id
      WHERE tooks.id = chapters.took_id AND books.created_by = auth.uid()
    )
  );

CREATE POLICY "Scan can delete own chapters"
  ON public.chapters FOR DELETE
  USING (
    is_scan() AND
    EXISTS (
      SELECT 1 FROM public.tooks
      JOIN public.books ON books.id = tooks.book_id
      WHERE tooks.id = chapters.took_id AND books.created_by = auth.uid()
    )
  );
```

**Archivos afectados**:
- `supabase/migrations/YYYYMMDDHHMMSS_fix_chapters_rls_ownership.sql` — nueva migración
- Verificar índices en `tooks.book_id` y `chapters.took_id`

**Risk**: MEDIO. JOIN de 3 tablas en RLS policy. Más pesado que 2.1. Medir performance con datos reales.

**Verification**:
- Scan A NO puede INSERT/UPDATE/DELETE chapters de libros de scan B
- Scan A SÍ puede INSERT/UPDATE/DELETE chapters de libros propios
- Admin mantiene acceso total
- El `chapterCount` se actualiza correctamente tras operaciones

---

### 2.3 Storage ownership verification

**Why**: Los buckets `covers` y `chapters` de Supabase Storage permiten a cualquier usuario autenticado subir/modificar/eliminar archivos. Un scan malicioso puede eliminar covers de otros scans.

**Qué hacer — 2 partes**:

#### A. Migración SQL (Storage policies)
```sql
-- Nueva migración: supabase/migrations/YYYYMMDDHHMMSS_fix_storage_rls_ownership.sql

-- Covers bucket: restrict a uploads dentro de carpeta del usuario
DROP POLICY IF EXISTS "Covers authenticated insert" ON storage.objects;
DROP POLICY IF EXISTS "Covers authenticated update" ON storage.objects;
DROP POLICY IF EXISTS "Covers authenticated delete" ON storage.objects;

CREATE POLICY "Covers: authenticated insert own folder"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'covers' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Covers: authenticated update own folder"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'covers' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Covers: authenticated delete own folder"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'covers' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- Mismas políticas para chapters bucket
DROP POLICY IF EXISTS "Chapters authenticated insert" ON storage.objects;
DROP POLICY IF EXISTS "Chapters authenticated update" ON storage.objects;
DROP POLICY IF EXISTS "Chapters authenticated delete" ON storage.objects;

CREATE POLICY "Chapters: authenticated insert own folder"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'chapters' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Chapters: authenticated update own folder"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'chapters' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Chapters: authenticated delete own folder"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'chapters' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );
```

#### B. Cambios en código (filename pattern)
```dart
// lib/features/books/data/book_repository_impl.dart — L222
// ANTES:
final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';
// DESPUÉS:
final userId = _supabase.client.auth.currentUser?.id ?? 'unknown';
final filename = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

// lib/features/chapters/data/chapter_repository_impl.dart — L97
// ANTES:
final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';
// DESPUÉS:
final userId = _supabase.client.auth.currentUser?.id ?? 'unknown';
final filename = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
```

**Archivos afectados**:
- `supabase/migrations/YYYYMMDDHHMMSS_fix_storage_rls_ownership.sql`
- `lib/features/books/data/book_repository_impl.dart` — L222
- `lib/features/chapters/data/chapter_repository_impl.dart` — L97
- `lib/core/cover/cover_url_service.dart` — verificar que maneje paths con `/`

**Risk**: ALTO. Cambiar la estructura de carpetas afecta archivos existentes. Los covers y chapters existentes siguen en la raíz del bucket y DEBEN ser migrados.

**Mitigación**: Crear script Edge Function o SQL temporal que migre archivos existentes de `{timestamp}.{ext}` a `{user_id}/{timestamp}.{ext}`. Ejecutar ANTES de activar las nuevas policies, o mantener policies de fallback temporalmente.

**Verification**:
- Scan A NO puede subir/modificar/eliminar archivos en el folder de scan B
- Scan A SÍ puede subir/modificar/eliminar archivos en su propio folder
- Los covers existentes siguen siendo visibles después de la migración
- `CoverUrlService` genera URLs correctas con paths anidados

---

### 2.4 Storage cleanup de archivos huérfanos

**Why**: Cuando un scan elimina un libro/tomo, los archivos de cover y contenido NO se eliminan de Storage. No hay cascading delete configurado. Con el tiempo, Storage se llena de archivos huérfanos.

**Qué hacer**:
```dart
// lib/features/books/data/book_repository_impl.dart — modificar deleteBook()
@override
Future<Result<void>> deleteBook(int id) async {
  try {
    // 1. Obtener el libro para saber el cover y los tomos/capítulos
    final bookData = await _supabase.client
        .from('books')
        .select('cover, tooks(chapters(content), cover)')
        .eq('id', id)
        .maybeSingle();

    // 2. Eliminar archivos de storage de capítulos
    if (bookData != null) {
      for (final took in (bookData['tooks'] as List? ?? [])) {
        if (took['cover'] != null && (took['cover'] as String).isNotEmpty) {
          await _safeDeleteStorage('covers', took['cover'] as String);
        }
        for (final chapter in (took['chapters'] as List? ?? [])) {
          final content = chapter['content'] as String?;
          if (content != null && content.startsWith('http')) {
            await _safeDeleteStorageFromUrl('chapters', content);
          }
        }
      }
      // Eliminar cover del libro
      final cover = bookData['cover'] as String?;
      if (cover != null && cover.isNotEmpty) {
        await _safeDeleteStorage('covers', cover);
      }
    }

    // 3. Eliminar el libro (CASCADE elimina tooks, chapters, etc.)
    await _supabase.client.from('books').delete().eq('id', id);
    return const Ok(null);
  } catch (e) {
    return Err(BookFailure('Error al eliminar libro', cause: e));
  }
}

Future<void> _safeDeleteStorage(String bucket, String path) async {
  try {
    await _supabase.client.storage.from(bucket).remove([path]);
  } catch (_) {
    // Log pero no fallar — el archivo puede no existir
  }
}

Future<void> _safeDeleteStorageFromUrl(String bucket, String url) async {
  try {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    final bucketIndex = pathSegments.indexOf(bucket);
    if (bucketIndex != -1) {
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      await _safeDeleteStorage(bucket, filePath);
    }
  } catch (_) {}
}
```

**Archivos afectados**:
- `lib/features/books/data/book_repository_impl.dart` — modificar `deleteBook()`, agregar helpers

**Dependencias**: 2.3 (nuevo filename pattern debe estar activo primero).

**Risk**: MEDIO. La eliminación en cascada puede fallar parcialmente (Storage error pero DB OK). El catch garantiza que el registro DB siempre se elimina aunque fallen los archivos.

**Verification**:
- Eliminar un libro limpia sus covers de Storage
- Eliminar un libro limpia los archivos de contenido de sus capítulos
- Eliminar un tomo limpia su cover
- Un error de Storage no impide la eliminación del registro en DB

---

## Fase 3: Core UX Regular (P1) — ~5-7 días

**Objetivo**: Activar la funcionalidad de favoritos, mostrar enlaces externos, limpiar dead code, y mejorar la experiencia del usuario regular.

**Dependencias**: Fase 1 completa (isUser, is_user() SQL).

### 3.1 Decisión de diseño: is_favorite

**⚠️ BLOQUEANTE ANTES DE IMPLEMENTAR FAVORITOS**

El campo `is_favorite` en la tabla `books` es un booleano GLOBAL — no está vinculado a un usuario. Hay dos opciones:

| Opción | Pros | Cons | Complejidad |
|--------|------|------|-------------|
| **A: Tabla `user_favorites`** | Favoritos por usuario, escalable, RLS limpio | Nueva tabla, más queries | Alta |
| **B: Renombrar `is_favorite` → `is_featured`** | Simple, sirve como "recomendado" | No es favorito personal, es global | Baja |

**Recomendación**: Opción A si se quiere "favoritos" real. Opción B si el campo era para marcar libros destacados por admin.

---

### 3.2 Feature completa de Favoritos (si Opción A)

**Why**: `BookEntity.isFavorite` (L23) existe en la DB, se serializa, se carga de Supabase, pero no hay UI, no hay tabla de relación por usuario, y no hay BLoC. Es dead code que necesita ser activado.

#### A. Migración SQL
```sql
-- Nueva migración
CREATE TABLE user_favorites (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  book_id INT REFERENCES books(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, book_id)
);

ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own favorites"
  ON user_favorites FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own favorites"
  ON user_favorites FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own favorites"
  ON user_favorites FOR DELETE USING (auth.uid() = user_id);
```

#### B. Domain layer
```
lib/features/favorites/
├── domain/
│   ├── favorite_entity.dart       — FavoriteEntity(userId, bookId, createdAt)
│   └── favorite_repository.dart   — Interface: toggleFavorite, getFavorites, isFavorite
├── data/
│   └── favorite_repository_impl.dart — Supabase CRUD
├── presentation/
│   ├── bloc/
│   │   ├── favorite_bloc.dart
│   │   ├── favorite_event.dart    — ToggleFavorite, LoadFavorites
│   │   └── favorite_state.dart
│   └── screens/
│       └── favorites_screen.dart  — Lista de libros favoritos
└── presentation/widgets/
    └── favorite_button.dart       — IconButton corazón (toggle)
```

#### C. UI changes
1. `lib/features/books/presentation/views/detail/detail_view.dart` — agregar `FavoriteButton` en el header
2. `lib/features/app/presentation/widgets/app_drawer.dart` — agregar item "Mis Favoritos"
3. `lib/features/app/presentation/screens/main_screen.dart` — agregar botón de favoritos al carousel

#### D. DI
- `lib/core/di/injection.dart` — registrar `FavoriteRepository`, `FavoriteBloc`

**Archivos afectados**:
- 10+ archivos nuevos (feature `favorites/`)
- 3 archivos modificados (detail_view, app_drawer, main_screen)
- 1 migración SQL

**Risk**: MEDIO. Feature completa con múltiples capas. RLS de `user_favorites` debe ser correcto — un error expone favoritos de otros usuarios.

**Verification**:
- Tap en corazón en `DetailView` togglea favorito
- Corazón se llena si el libro es favorito del usuario actual
- Drawer tiene item "Mis Favoritos" que navega a pantalla de favoritos
- `FavoritesScreen` muestra solo libros marcados por el usuario actual
- RLS permite cada usuario ver solo sus favoritos
- Tests de BLoC y repository pasan

---

### 3.3 Mostrar `source` y `link` en `DetailView`

**Why**: `BookWithRelations` hereda `source` y `link` de `BookEntity` (L21-22), pero `DetailView` solo muestra descripción, metadata y géneros. Si la app quiere dirigir a contenido externo, esto está roto.

**Qué hacer**:
```dart
// lib/features/books/presentation/views/detail/detail_view.dart
// Después del Wrap de géneros (L92), agregar:

if (widget.books.link.isNotEmpty || widget.books.source.isNotEmpty) ...[
  const SizedBox(height: 16),
  TitleWidget(
    text: 'Enlaces',
    clContent: Theme.of(context).colorScheme.primary,
    clText: Theme.of(context).colorScheme.onSurface,
  ),
  Padding(
    padding: const EdgeInsets.all(10.0),
    child: Column(
      children: [
        if (widget.books.link.isNotEmpty)
          CardInfoDetail(
            title1: "Enlace Externo",
            text1: widget.books.link,
          ),
        if (widget.books.source.isNotEmpty)
          CardInfoDetail(
            title1: "Fuente",
            text1: widget.books.source,
          ),
      ],
    ),
  ),
],
```

**Nota**: Verificar si `CardInfoDetail` soporta `onTap`. Si no, crear wrapper con `InkWell` + `launchUrl`. Verificar `pubspec.yaml` para `url_launcher`.

**Archivos afectados**:
- `lib/features/books/presentation/views/detail/detail_view.dart` — agregar sección
- Posiblemente `lib/features/books/presentation/views/detail/widgets/card_info_detail.dart` — soporte onTap
- `pubspec.yaml` — agregar `url_launcher` si no existe

**Risk**: Bajo. Solo agrega UI condicional.

**Verification**:
- Si `link` no está vacío, se muestra como enlace clickeable
- Si `source` no está vacío, se muestra como enlace clickeable
- Si ambos están vacíos, la sección "Enlaces" no aparece
- Tap en enlace abre URL en navegador externo

---

### 3.4 Eliminar dead code en `ChapterScreen`

**Why**: `ChapterScreen` (186 líneas) tiene 4 variables declaradas sin UI (`textSize`, `selectedFont`, `selectedStyle`, `selectedWeight`), un `textEditingController` que nunca se usa en widgets, y `TextStats` que se calculan en CADA rebuild del PageView pero nunca se muestran.

**Qué hacer**: Eliminar dead code (Opción A del plan regular). Las variables se pueden recuperar del git history cuando se implemente la feature de personalización.

- Eliminar `textSize`, `selectedFont`, `selectedStyle`, `selectedWeight` (L32-35)
- Eliminar `textEditingController` (L37, L43)
- Eliminar cálculos de `TextStats` en `itemBuilder` (L116-119)
- El estilo queda hardcodeado en el `TextStyle` inline

**Archivos afectados**:
- `lib/features/chapters/presentation/screens/chapter_screen.dart` — eliminar dead code

**Risk**: Bajo. Solo elimina código no utilizado. Si se necesita personalización futuro, se recupera de git.

**Verification**:
- No hay variables sin usar en `_ChapterScreenState`
- `textEditingController` eliminado
- El lector funciona igual: mismo tamaño, misma fuente, misma experiencia
- No hay warnings de `unused_variable` en el archivo
- `flutter analyze` sin warnings en este archivo

---

### 3.5 Pasar `isScan`/`isAdmin` reales al `AppDrawer`

**Why**: `MainScreen` (L38) instancia `AppDrawer()` sin pasar `isScan` ni `isAdmin`. El drawer los tiene como parámetros default `false` (L12). Funciona para usuario regular, pero es frágil y oculta la dependencia.

**Qué hacer**:
```dart
// lib/features/app/presentation/screens/main_screen.dart — L38
drawer: AppDrawer(
  isScan: context.read<AuthBloc>().state is AuthAuthenticated
      ? (context.read<AuthBloc>().state as AuthAuthenticated).user.isScan
      : false,
  isAdmin: context.read<AuthBloc>().state is AuthAuthenticated
      ? (context.read<AuthBloc>().state as AuthAuthenticated).user.isAdmin
      : false,
),
```

**Mejor aún**: Extraer el usuario del AuthBloc state que ya está disponible en el `BlocBuilder<AuthBloc, AuthState>` del `app.dart`. Se puede usar `BlocProvider` o `context.watch`.

**Archivos afectados**:
- `lib/features/app/presentation/screens/main_screen.dart` — modificar L38

**Risk**: Nulo. Solo pasa valores reales en vez de defaults.

**Verification**:
- `AppDrawer` recibe los valores reales del rol del usuario
- El drawer del usuario regular muestra solo "Inicio" / "Editar Perfil" / "Cerrar Sesión"
- No hay duplicación de lógica de rol

---

## Fase 4: Scan UX (P1) — ~4-5 días

**Objetivo**: Decomponer el ScanBloc monolítico, crear infraestructura compartida (GenreCubit), habilitar gestión de etiquetas, y resolver el problema de IDs provisionales.

**Dependencias**: Fase 2 completa (ownership checks en DB antes de refactorizar código).

### 4.1 Decomposición ScanBloc → ScanBookBloc + ScanCoverBloc

**Why**: `ScanBloc` (187 líneas, 7 use cases, 6 eventos) tiene un TODO confirmando que necesita división. Acopla upload de covers, CRUD de libros, carga de géneros y toggling de visibilidad en una sola clase.

**Qué hacer**:

#### A. ScanBookBloc — CRUD + Visibilidad
```dart
// lib/features/scan/presentation/bloc/scan_book_bloc.dart
class ScanBookBloc extends Bloc<ScanBookEvent, ScanBookState> {
  final GetBooks getBooks;
  final CreateBook createBook;
  final UpdateBook updateBook;
  final DeleteBook deleteBook;
  final ToggleBookVisibility toggleBookVisibility;

  // Eventos: LoadScanBooks, SaveScanBook, DeleteScanBook, ToggleScanBookVisibility
  // Estados: ScanBookInitial, ScanBookLoading, ScanBookLoaded, ScanBookError
}
```

#### B. ScanCoverBloc — Upload de covers
```dart
// lib/features/scan/presentation/bloc/scan_cover_bloc.dart
class ScanCoverBloc extends Bloc<ScanCoverEvent, ScanCoverState> {
  final UploadCover uploadCover;

  // Evento: UploadScanCover
  // Estados: ScanCoverInitial, ScanCoverUploading, ScanCoverUploaded, ScanCoverError
}
```

#### C. GenreCubit — Carga de géneros compartido
```dart
// lib/features/genres/presentation/genre_cubit.dart
class GenreCubit extends Cubit<GenreState> {
  final GetGenre getGenres;
  GenreCubit({required this.getGenres}) : super(GenreInitial());

  Future<void> loadGenres() async {
    final result = await getGenres();
    switch (result) {
      case Ok(:final value): emit(GenreLoaded(value));
      case Err(:final error): emit(GenreError(error.message));
    }
  }
}
```

**Archivos afectados**:
- **Eliminar**: `scan_bloc.dart`, `scan_event.dart`, `scan_state.dart`
- **Crear**: `scan_book_bloc.dart`, `scan_book_event.dart`, `scan_book_state.dart`
- **Crear**: `scan_cover_bloc.dart`, `scan_cover_event.dart`, `scan_cover_state.dart`
- **Crear**: `lib/features/genres/presentation/genre_cubit.dart`
- **Modificar**: `lib/core/di/injection_scan.dart`
- **Modificar**: `lib/features/scan/presentation/screens/scan_main_screen.dart`
- **Modificar**: `lib/features/scan/presentation/screens/scan_book_edit_screen.dart`

**Risk**: ALTO. Cambia la arquitectura de los BLoCs. Requiere actualizar todas las screens que los consumen. Hacer en branch dedicado con tests antes de mergear.

**Verification**:
- `ScanBookBloc` maneja solo CRUD de libros y visibilidad
- `ScanCoverBloc` maneja solo upload de covers
- `GenreCubit` carga géneros de forma independiente
- `ScanBookEditScreen` usa `BlocProvider` separados
- No hay regresiones en el flujo crear → cover → género → guardar
- Todos los tests pasan (adaptados a los nuevos BLoCs)
- `injection_scan.dart` registra los nuevos BLoCs correctamente

---

### 4.2 Rename `UploadCover` → `UploadImage`

**Why**: El caso de uso `UploadCover` del dominio de `books` es reutilizado por `ScanTookBloc` para subir covers de tomos. El nombre es semánticamente incorrecto.

**Qué hacer**:
1. Renombrar `lib/features/books/domain/upload_cover.dart` → mover a dominio compartido o renombrar clase
2. `UploadCover` → `UploadImage`
3. `BookRepository.uploadCover()` → `uploadImage()`
4. Actualizar todas las referencias

**Archivos afectados**:
- `lib/features/books/domain/upload_cover.dart` → mover/renombrar
- `lib/features/books/domain/book_repository.dart`
- `lib/features/books/data/book_repository_impl.dart`
- `lib/features/scan/presentation/bloc/scan_cover_bloc.dart` (el nuevo)
- `lib/features/scan/presentation/bloc/scan_took_bloc.dart`
- `lib/core/di/injection.dart`
- `test/bloc/scan_bloc_test.dart` → reemplazar por tests de nuevos BLoCs
- `test/bloc/scan_took_bloc_test.dart` — actualizar mock

**Dependencias**: 4.1 (la decomposition debe ocurrir primero).

**Risk**: MEDIO. Rename masivo que puede romper imports. Hacer con IDE refactoring tools, no manualmente.

**Verification**:
- El caso de uso se llama `UploadImage` y vive en un dominio compartido
- Tanto `ScanCoverBloc` como `ScanTookBloc` usan `UploadImage`
- No hay imports rotos
- `flutter analyze` sin errors

---

### 4.3 UI de Label Management para scan

**Why**: El RLS permite a scan CRUD completo en `labels`, pero NO hay pantalla accesible desde el drawer del scan. La ruta `/label-management` existe en `app.dart` (L32) pero no es accesible.

**Qué hacer**:

1. Agregar entrada en `AppDrawer` para scan:
```dart
// lib/features/app/presentation/widgets/app_drawer.dart
if (isScan)
  ListTile(
    leading: const Icon(Icons.label),
    title: const Text('Etiquetas'),
    onTap: () {
      Navigator.pop(context);
      context.push('/label-management');
    },
  ),
```

2. Verificar que `LabelManagementScreen` funcione para scan (no tenga guards de admin).
3. Crear `ScanLabelBloc` o reutilizar el existente.

**Archivos afectados**:
- `lib/features/app/presentation/widgets/app_drawer.dart` — agregar ListTile
- Posiblemente: `lib/features/labels/presentation/`
- Crear: `lib/features/scan/presentation/bloc/scan_label_bloc.dart`
- `lib/core/di/injection_scan.dart`

**Risk**: Bajo. La ruta y la pantalla ya existen.

**Verification**:
- El scan puede crear, editar y eliminar etiquetas desde su panel
- La entrada aparece en el drawer del scan
- No hay acceso a funcionalidades de admin

---

### 4.4 Reemplazar provisional IDs por UUIDs

**Why**: `BookEntity.id`, `TookEntity.id` y `ChapterEntity.id` usan `DateTime.now().millisecondsSinceEpoch` como ID provisional antes del insert. Si dos operaciones ocurren en el mismo milisegundo, hay colisión.

**Qué hacer**: Cambiar el patrón para que la operación de guardado devuelva el ID real, eliminando la necesidad de ID provisional:

```dart
// BookRepository: cambiar return type
Future<Result<int>> createBook(BookEntity book);  // retorna el ID real

// En el BLoC/Screen:
final result = await createBook(book);
switch (result) {
  case Ok(:final value):
    final realId = value;
    // usar realId para crear tomos, etc.
  case Err(:final error):
    // manejar error
}
```

**Archivos afectados**:
- `lib/features/books/domain/create_book.dart` — cambiar return type
- `lib/features/books/data/book_repository_impl.dart` — `createBook()` retorna ID real
- `lib/features/scan/presentation/screens/scan_book_edit_screen.dart` L105
- `lib/features/scan/presentation/screens/scan_took_edit_screen.dart` L59
- `lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart` L144
- `lib/features/tooks/domain/create_took.dart`
- `lib/features/chapters/domain/create_chapter.dart`
- `lib/features/tooks/data/took_repository_impl.dart`
- `lib/features/chapters/data/chapter_repository_impl.dart`
- `lib/features/books/domain/book_entity.dart` — verificar tipo de `id`

**Risk**: MEDIO. Cambiar el tipo de `id` puede afectar serialization/deserialization y la UI que muestra IDs. Verificar TODAS las referencias a `BookEntity.id` antes de cambiar.

**Verification**:
- No hay más `DateTime.now().millisecondsSinceEpoch` en screens
- El ID real de la DB se usa para crear entidades hijas
- No hay regresiones en el flujo crear libro → agregar tomo → agregar capítulo
- Tests de BLoC actualizados para reflejar el cambio

---

## Fase 5: Admin Management (P1) — ~4-6 días

**Objetivo**: Completar la gestión de usuarios con escritura real (cambio de rol, suspensión), búsqueda, paginación, y mejorar la UX del panel.

**Dependencias**: Fase 1 completa (auto-democión protection, rate limiting).

### 5.1 Cambio de rol de usuarios (promote/demote)

**Why**: El tab de Usuarios es solo lectura. El admin puede VER usuarios pero no puede cambiar sus roles.

**Qué hacer**:

#### Nuevos eventos
```dart
// lib/features/admin/presentation/bloc/admin_users_event.dart
class ChangeUserRole extends AdminUsersEvent {
  final String targetUserId;
  final String newRole; // 'user', 'scan', 'admin'
  const ChangeUserRole({required this.targetUserId, required this.newRole});
}
```

#### Nuevos use cases
```dart
// lib/features/profiles/domain/update_user_role.dart
class UpdateUserRole {
  final ProfilesRepository repository;
  Future<Result<UserEntity>> call(String userId, String newRole) async {
    return repository.updateUserRole(userId: userId, role: newRole);
  }
}
```

#### Nueva función en ProfilesRepositoryImpl
```dart
// lib/features/profiles/data/profiles_repository_impl.dart
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

#### UI — PopupMenuButton en cada ListTile de usuario

**Archivos afectados**:
- `lib/features/admin/presentation/bloc/admin_users_event.dart`
- `lib/features/admin/presentation/bloc/admin_users_bloc.dart`
- `lib/features/admin/presentation/bloc/admin_users_state.dart`
- `lib/features/profiles/domain/profiles_repository.dart`
- `lib/features/profiles/data/profiles_repository_impl.dart`
- `lib/features/admin/presentation/screens/users_tab.dart`
- `lib/core/di/injection_profiles.dart`

**Risk**: MEDIO. Cambio de rol puede dejar al sistema sin admin. Mitigación: validar que siempre hay al menos un admin activo.

**Verification**:
- Admin puede cambiar rol de cualquier usuario excepto sí mismo
- Roles disponibles: `user`, `scan`, `admin`
- SnackBar de confirmación: "Rol de {email} cambiado a {role}"
- La lista se actualiza después del cambio
- No se puede cambiar el último admin a otro rol

---

### 5.2 Eliminación y suspensión de usuarios

**Why**: El admin no tiene forma de eliminar o suspender usuarios problemáticos.

**Qué hacer**:

#### Opción recomendada: Suspensión (no eliminación desde app)
```sql
-- Migración: agregar campo de suspensión
ALTER TABLE profiles ADD COLUMN is_suspended BOOLEAN NOT NULL DEFAULT false;
```

O usar un role especial `suspended`:
```sql
-- Actualizar CHECK constraint:
ALTER TABLE profiles DROP CONSTRAINT profiles_role_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('user', 'scan', 'admin', 'suspended'));
```

**Recomendación**: Opción del role `suspended` — más simple, no requiere nueva columna.

#### Eliminación real
Usar `auth.admin.deleteUser()` de Supabase Admin API. Requiere service_role key → crear Edge Function `admin-delete-user` con JWT verification.

**⚠️ Decisión pendiente**: ¿Eliminar usuarios desde la app Flutter directamente? Se recomienda NO — solo suspender. Eliminación desde Supabase Dashboard.

**Archivos afectados**:
- Migración SQL (profiles)
- `lib/features/admin/presentation/bloc/admin_users_event.dart`
- `lib/features/admin/presentation/bloc/admin_users_bloc.dart`
- `lib/features/admin/presentation/screens/users_tab.dart`
- Posiblemente: `supabase/functions/admin-delete-user/`

**Risk**: ALTO si se implementa eliminación desde la app (exposición de service_role key). BAJO si solo se implementa suspensión.

**Verification**:
- Admin puede suspender/reactivar usuarios
- Usuarios suspendidos aparecen con badge "Suspendido"
- Eliminación requiere confirmación con doble verificación (escribir email)
- Admin no puede eliminarse a sí mismo

---

### 5.3 Búsqueda de usuarios

**Why**: Con muchos usuarios, encontrar uno específico es difícil.

**Qué hacer**: `TextField` con `onChanged` que filtra la lista local:
```dart
// lib/features/admin/presentation/screens/users_tab.dart
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

**Archivos afectados**:
- `lib/features/admin/presentation/screens/users_tab.dart`

**Risk**: Nulo.

**Verification**:
- Barra de búsqueda visible
- Filtra en tiempo real por nombre o email
- "No se encontraron resultados" cuando no matchea
- Case-insensitive

---

### 5.4 Paginación en getAllProfiles()

**Why**: `profiles_repository_impl.dart` L77 usa `.limit(100)` hardcoded. Sin paginación.

**Qué hacer**: Cursor-based pagination con Supabase:
```dart
Future<Result<List<UserEntity>>> getAllProfiles({
  int limit = 50,
  String? afterEmail,
}) async {
  var query = _supabase.client
      .from('profiles')
      .select('*')
      .order('email');

  if (afterEmail != null) {
    query = query.gt('email', afterEmail);
  }

  final response = await query.limit(limit + 1);
  final hasMore = response.length > limit;
  final profiles = response
      .take(limit)
      .map((json) => UserModel.fromJson(json))
      .toList();
  return Ok(profiles);
}
```

**UI**: `ListView.builder` con `ScrollController` para infinite scroll.

**Archivos afectados**:
- `lib/features/profiles/data/profiles_repository_impl.dart`
- `lib/features/profiles/domain/profiles_repository.dart`
- `lib/features/profiles/domain/get_all_profiles.dart`
- `lib/features/admin/presentation/bloc/admin_users_bloc.dart`

**Risk**: BAJO. La paginación con cursor es el patrón estándar de Supabase.

**Verification**:
- Carga inicial de 50 usuarios
- Scroll infinito carga más
- Loading indicator al cargar más
- No hay límite hardcoded

---

## Fase 6: Analytics (P1-P2) — ~3-4 días

**Objetivo**: Implementar métricas reales sobre la tabla `book_views` que ya existe pero nadie llena.

**Dependencias**: Fase 1 completa. Independiente de Fases 3, 4, 5.

### 6.1 Tracking de vistas de libros

**Why**: La tabla `book_views` existe pero ningún código inserta datos.

**Qué hacer**:
```dart
// Nuevo use case:
// lib/features/books/domain/track_book_view.dart
class TrackBookView {
  final BookRepository repository;
  Future<Result<void>> call(int bookId) async {
    return repository.trackBookView(bookId);
  }
}

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

// En book_detail_screen.dart — initState:
void _trackView() async {
  await Future.delayed(const Duration(seconds: 2)); // debounce
  if (mounted) {
    context.read<BookBloc>().add(TrackBookView(widget.bookId));
  }
}
```

**Archivos afectados**:
- `lib/features/books/domain/track_book_view.dart` — NUEVO
- `lib/features/books/data/book_repository_impl.dart`
- `lib/features/books/presentation/screens/book_detail_screen.dart` — o DetailView
- `lib/core/di/injection_books.dart`

**Risk**: BAJO. INSERT simple con debounce.

**Verification**:
- Al abrir un libro, se registra una vista después de 2 segundos
- No se registran vistas duplicadas en la misma sesión
- El tracking no afecta el rendimiento
- Errores de tracking no impactan la experiencia

---

### 6.2 Analytics BLoC + Repository

**Why**: Reemplazar el placeholder "Próximamente" en AnalyticsTab.

**Qué hacer**:

#### SQL functions
```sql
-- Views por día
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

#### BLoC
```dart
// lib/features/admin/presentation/bloc/admin_analytics_bloc.dart
// Eventos: LoadAnalyticsOverview, LoadBookViewsTrend, LoadTopBooks
// Estados: AnalyticsOverview (totalViews, totalBooks, viewsToday, avgViewsPerBook)
```

#### Repository
```dart
// lib/features/admin/domain/analytics_repository.dart
// lib/features/admin/data/analytics_repository_impl.dart
```

**Archivos afectados**:
- `lib/features/admin/presentation/screens/analytics_tab.dart` — reemplazar placeholder
- `lib/features/admin/presentation/bloc/admin_analytics_bloc.dart` — NUEVO
- `lib/features/admin/presentation/bloc/admin_analytics_event.dart` — NUEVO
- `lib/features/admin/presentation/bloc/admin_analytics_state.dart` — NUEVO
- `lib/features/admin/domain/analytics_repository.dart` — NUEVO
- `lib/features/admin/data/analytics_repository_impl.dart` — NUEVO
- `lib/core/di/injection_admin.dart`
- `lib/features/admin/presentation/screens/admin_dash_screen.dart`
- Nueva migración SQL (functions)

**Risk**: BAJO para queries simples. MEDIO para la UI de gráficos (evaluar `fl_chart` vs solo números).

**Verification**:
- Analytics tab muestra métricas reales (no placeholder)
- Total de vistas, vistas hoy, top libros
- Gráfico de tendencia de vistas
- Loading states y error handling

---

### 6.3 Dashboard de métricas

**Why**: Mostrar overview de métricas antes de los tabs de admin.

**Qué hacer**:
- Widget `DashboardMetricsCard` en `AdminDashScreen`
- Métricas: total de libros (visibles vs ocultos), total de usuarios (por rol), vistas hoy, último libro agregado

**Archivos afectados**:
- `lib/features/admin/presentation/screens/admin_dash_screen.dart`
- `lib/features/admin/presentation/widgets/dashboard_metrics_card.dart` — NUEVO

**Risk**: BAJO.

**Verification**:
- Dashboard muestra métricas de resumen
- Datos cargan al montar
- Pull-to-refresh actualiza

---

## Fase 7: Polish y Tests (P2-P3) — ~5-7 días

**Objetivo**: Empty states, paginación, loading states, form validation, confirmation dialogs, y test coverage completa.

**Dependencias**: Fases 3-6 completadas.

### 7.1 Empty states para home y búsqueda vacía

**Why**: Si no hay libros o la búsqueda no retorna resultados, `MainScreen` muestra un `CustomScrollView` vacío sin feedback.

**Qué hacer**:
```dart
// lib/features/app/presentation/screens/main_screen.dart
if (listBook.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.library_books_outlined, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text('No hay libros disponibles'),
        Text('Intenta más tarde o contacta al administrador'),
      ],
    ),
  );
}
```

**Archivos afectados**:
- `lib/features/app/presentation/screens/main_screen.dart`
- `lib/features/genres/presentation/screens/genre_screen.dart`

---

### 7.2 Paginación / Scroll infinito en home

**Why**: `BookRepository.getBooks()` soporta `page` y `pageSize` pero `MainScreen` siempre usa defaults. No hay scroll infinito.

**Qué hacer**:
1. Modificar `BookBloc` para soportar `LoadMoreBooks(page)` event
2. Agregar `ScrollController` en `MainScreen`
3. Mostrar `CircularProgressIndicator` al final de la lista
4. Cuando no hay más libros, dejar de mostrar el indicador

**Archivos afectados**:
- `lib/features/books/presentation/bloc/book_bloc.dart`
- `lib/features/books/presentation/bloc/book_event.dart`
- `lib/features/books/presentation/bloc/book_state.dart`
- `lib/features/app/presentation/screens/main_screen.dart`

**Risk**: MEDIO. RLS puede filtrar filas después del range (verificar con `COUNT` query).

---

### 7.3 Filtros de género interactivos en DetailView

**Why**: En `DetailView` (L80), los chips de género tienen `onTap: () {}` — un callback vacío.

**Archivos afectados**:
- `lib/features/books/presentation/views/detail/detail_view.dart`
- Posiblemente `lib/features/genres/presentation/screens/genre_screen.dart`

---

### 7.4 Estadísticas de lectura persistentes

**Why**: `ChapterScreen` calcula stats pero nunca las muestra.

**Archivos afectados**:
- `lib/features/chapters/presentation/screens/chapter_screen.dart`
- Nuevo widget `lib/features/chapters/presentation/widgets/reading_stats.dart`

---

### 7.5 Loading states y error handling consistente (scan + admin)

**Why**: Las screens no muestran loading indicators consistentes durante operaciones de escritura. El `SaveScanBook` usa un `Completer` con timeout de 10 segundos.

**Qué hacer**:
- Agregar `isLoading` flag a cada screen que observe el BLoC state
- Usar `BlocBuilder` con estados de loading explícitos
- Eliminar patrón `Completer` con timeout
- SnackBar consistente (verde para éxito, rojo para error)

**Archivos afectados**:
- `lib/features/scan/presentation/screens/scan_book_edit_screen.dart`
- `lib/features/scan/presentation/screens/scan_took_edit_screen.dart`
- `lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart`
- `lib/features/scan/presentation/screens/scan_main_screen.dart`
- Todos los screens del admin

---

### 7.6 Upload progress indicators (scan)

**Archivos afectados**:
- `lib/features/scan/presentation/bloc/scan_cover_bloc.dart`
- `lib/features/scan/presentation/screens/widgets/cover_picker.dart`
- `lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart`

---

### 7.7 Form validation feedback (scan)

**Archivos afectados**:
- `lib/features/scan/presentation/screens/scan_book_edit_screen.dart`
- `lib/features/scan/presentation/screens/scan_took_edit_screen.dart`
- `lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart`

---

### 7.8 Confirmation dialogs mejorados (admin)

**Archivos afectados**:
- `lib/features/admin/presentation/screens/books_tab.dart`
- `lib/features/admin/presentation/screens/users_tab.dart`
- `lib/shared/presentation/widgets/confirmation_dialog.dart` — NUEVO

---

### 7.9 Genre ordering/priority (admin)

**Archivos afectados**:
- Migración SQL: `sort_order INT DEFAULT 0` en `genres`
- `lib/features/genres/domain/genre_entity.dart`
- `lib/features/genres/data/genre_model.dart`
- `lib/features/admin/presentation/screens/genres_tab.dart`

---

### 7.10 Bulk operations (admin)

**Archivos afectados**:
- `lib/features/admin/presentation/screens/books_tab.dart`
- `lib/features/admin/presentation/bloc/admin_event.dart`

---

### 7.11 UserRole enum (cross-cutting)

**Why**: Reemplazar `String role` por `UserRole` enum para type safety. TOCA ~15 archivos.

**⚠️ Hacer como PR DEDICADO con tests antes de merge.**

**Archivos afectados**:
- `lib/features/profiles/domain/user_role.dart` — NUEVO
- `lib/features/profiles/domain/user_entity.dart`
- `lib/features/profiles/data/user_model.dart`
- Todos los archivos que usan `role == 'admin'`, `role == 'scan'`, etc.

---

### 7.12 Optimistic locking para concurrent edits (scan)

**Archivos afectados**:
- Nueva migración SQL (updated_at + triggers)
- `lib/features/books/domain/book_entity.dart`
- `lib/features/books/data/book_repository_impl.dart`
- `lib/features/tooks/data/took_repository_impl.dart`
- `lib/features/chapters/data/chapter_repository_impl.dart`

---

### 7.13 Tests unitarios para BLoCs

```
test/
├── bloc/
│   ├── auth_bloc_regular_user_test.dart
│   ├── favorites_bloc_test.dart          — Si se implementa 3.2
│   ├── scan_book_bloc_test.dart
│   ├── scan_cover_bloc_test.dart
│   ├── admin_bloc_test.dart
│   └── admin_users_bloc_test.dart
├── entities/
│   └── user_entity_test.dart
├── presentation/
│   ├── main_screen_test.dart
│   ├── detail_view_test.dart
│   ├── scan_book_edit_screen_test.dart
│   └── admin_dash_screen_test.dart
└── integration/
    ├── regular_user_flow_test.dart
    └── scan_rls_test.dart
```

---

### 7.14 Documentación

- `docs/scan-module.md` — arquitectura, flujos, RLS del módulo scan
- Actualizar README con estructura de BLoCs post-decomposition

---

## Grafo de Dependencias

```
                    ┌─────────────────────────────┐
                    │  FASE 1: Foundation &        │
                    │  Security (P0)               │
                    │  isUser, role validation,    │
                    │  routing guard, is_user() SQL│
                    │  admin RLS audit, self-      │
                    │  demotion, rate limiting      │
                    └──────────┬──────────────────┘
                               │
              ┌────────────────┼────────────────────────────┐
              │                │                            │
              ▼                ▼                            ▼
┌─────────────────────┐ ┌──────────────────┐  ┌─────────────────────────┐
│ FASE 2: Scan        │ │ FASE 6: Analytics │  │ FASE 7: Polish & Tests  │
│ Security (P0)       │ │ (P1-P2)           │  │ (P2-P3)                 │
│ RLS ownership       │ │ View tracking,    │  │ Empty states, paginat., │
│ tooks/chapters,     │ │ Analytics BLoC,   │  │ loading, validation,    │
│ storage ownership,  │ │ Dashboard metrics │  │ dialogs, docs, tests    │
│ cleanup             │ │                   │  │                         │
└────────┬────────────┘ └──────────────────┘  └─────────────────────────┘
         │                                              ▲
    ┌────┴──────────────────────────┐                   │
    │                               │                   │
    ▼                               ▼                   │
┌─────────────────────┐  ┌──────────────────────┐      │
│ FASE 3: Regular     │  │ FASE 4: Scan UX      │      │
│ Core (P1)           │  │ (P1)                 │      │
│ Favorites, source/  │  │ ScanBloc decomposition│     │
│ link, dead code,    │  │ UploadImage, labels, │      │
│ drawer values       │  │ GenreCubit, UUIDs    │      │
└─────────────────────┘  └──────────────────────┘      │
                                                        │
┌──────────────────────────────────────┐                │
│ FASE 5: Admin Management (P1)       │                │
│ Role changes, suspension, search,   │                │
│ pagination, book creation           │────────────────┘
└──────────────────────────────────────┘
```

### Dependencias explícitas:

```
Fase 1 ──→ Fase 2 (is_user SQL para context)
Fase 1 ──→ Fase 3 (isUser getter para favorites RLS)
Fase 1 ──→ Fase 5 (self-demotion, rate limiting)
Fase 1 ──→ Fase 6 (analytics functions)
Fase 2 ──→ Fase 4 (ownership checks antes de refactor scan)
Fase 3 ──→ Fase 7 (favorites tests)
Fase 4 ──→ Fase 7 (scan bloc tests)
Fase 5 ──→ Fase 7 (admin tests)
Fase 6 ──→ Fase 7 (analytics tests)
```

### Independencias (paralelizable):

```
Fase 3 ↔ Fase 4 ↔ Fase 5 ↔ Fase 6
(Todas son independientes entre sí una vez completadas Fases 1 y 2)
```

---

## Riesgos y Mitigaciones

| # | Riesgo | Severidad | Probabilidad | Mitigación |
|---|--------|-----------|-------------|------------|
| 1 | **RLS ownership via JOINs afecta performance** | ALTA | MEDIA | Verificar índices en `books.created_by`, `tooks.book_id`, `chapters.took_id`. Ejecutar `EXPLAIN ANALYZE` antes y después. |
| 2 | **Migración de Storage estructura de carpetas** | ALTA | ALTA | Crear Edge Function de migración temporal. Mantener policies de fallback hasta confirmar que todos los archivos existentes están migrados. |
| 3 | **ScanBloc decomposition rompe screens** | ALTA | MEDIA | Hacer en branch dedicado. Actualizar tests antes de mergear. Mantener los BLoCs viejos como deprecated temporalmente si es necesario. |
| 4 | **UserRole enum toca ~15 archivos** | MEDIA | ALTA | Hacer como PR dedicado. Usar IDE refactoring, no manual. Tests antes de merge. |
| 5 | **BookRepositoryImpl modificado por 3 planes** | ALTA | ALTA | Cada cambio en commit separado. Merge en orden de fase. Code review cuidadoso. |
| 6 | **Eliminación de usuarios expone service_role key** | CRÍTICA | BAJA | NO implementar eliminación desde la app. Usar solo suspensión. Eliminación desde Supabase Dashboard. |
| 7 | **`is_favorite` global vs personal** | MEDIA | ALTA | DECIDIR antes de Fase 3. Si es global → renombrar a `is_featured`. Si es personal → tabla `user_favorites`. |
| 8 | **RLS policy change rompe queries existentes** | ALTA | BAJA | Testear TODOS los flujos de cada rol después de cada migración RLS. Tener scripts de rollback listos. |
| 9 | **Analytics queries lentas con muchos datos** | MEDIA | MEDIA | Usar índices existentes. Considerar materialized views si `book_views` crece mucho. Cachear resultados. |
| 10 | **Pagination + RLS: menos items de los esperados** | MEDIA | ALTA | Usar COUNT query o ajustar range para compensar filas filtradas por RLS. |

---

## Estimación por Rol

| Rol | Fases que lo afectan | Días estimados (1 dev) | Días estimados (2 devs) |
|-----|---------------------|----------------------|------------------------|
| **Todos** | Fase 1, 7 | 8-12 | 5-7 |
| **Regular** | Fase 3 | 5-7 | 3-4 |
| **Scan** | Fase 2, 4 | 6-8 | 4-5 |
| **Admin** | Fase 5, 6 | 7-10 | 5-7 |
| **TOTAL** | — | **~34-46** | **~18-24** |

### Desglose por fase:

| Fase | Días (1 dev) | Días (2 devs) | Rol principal | Paralelizable con |
|------|-------------|---------------|---------------|-------------------|
| 1 | 3-5 | 2-3 | Todos | Ninguna |
| 2 | 2-3 | 1-2 | Scan | Fase 6 |
| 3 | 5-7 | 3-4 | Regular | Fases 4, 5, 6 |
| 4 | 4-5 | 2-3 | Scan | Fases 3, 5, 6 |
| 5 | 4-6 | 2-3 | Admin | Fases 3, 4, 6 |
| 6 | 3-4 | 2-3 | Admin | Fases 3, 4, 5 |
| 7 | 5-7 | 3-4 | Todos | — (al final) |

### Ruta crítica:

```
Fase 1 (3-5d) → Fase 2 (2-3d) → Fase 4 (4-5d) → Fase 7 (5-7d) = 14-20d
```

---

## Decisiones Resueltas (2026-07-20)

| # | Decisión | Resolución |
|---|----------|------------|
| 1 | **¿`is_favorite` es personal o global?** | **A** — tabla `user_favorites` personal por usuario |
| 2 | **¿Eliminar usuarios desde la app?** | **NO** — solo suspender, no eliminar |
| 3 | **¿Admin puede crear libros?** | **NO** — admin solo administra, no crea contenido |
| 4 | **¿Gráficos en analytics?** | **Números primero**, gráficos en futuro |
| 5 | **¿Nuevo rol "editor"?** | **Después** — no es urgente |
| 6 | **¿`url_launcher` en pubspec?** | **Agregar** — dependencia estándar y liviana |

---

## Checklist de Implementación

Antes de CADA fase, verificar:

- [ ] Las migraciones SQL de fases anteriores están aplicadas
- [ ] `flutter analyze` no muestra errores
- [ ] Todos los tests existentes pasan
- [ ] La app compila y ejecuta correctamente
- [ ] Se creó un branch dedicado para la fase
- [ ] Se documentaron los cambios en el changelog

Después de CADA fase:

- [ ] Todos los items de la fase completados
- [ ] Tests nuevos escritos y pasando
- [ ] `flutter analyze` sin nuevos warnings
- [ ] La app funciona correctamente para TODOS los roles
- [ ] Los archivos conflictivos (`book_repository_impl.dart`, etc.) están mergeados sin conflictos
- [ ] PR creado y code-reviewed

---

*Plan unificado generado el 2026-07-20. Fusión de planes de regular-user (14 items), scan-user (15 items) y admin (18 items) en 7 fases con 47 items totales.*
