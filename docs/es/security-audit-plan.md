# Plan de Corrección — Auditoría de Seguridad

**Fecha:** 2026-07-27
**Auditoría:** 3 agentes (App Code, Supabase RLS, Auth Flows) + revisión manual
**Resultado:** 3 CRITICAL, 7 HIGH, 8 MEDIUM, 8 LOW, 5 INFO (31 findings total)

---

## Resumen por Fase

| Fase | Severidad | Tipo | Finding IDs | Commits estimados |
|------|-----------|------|-------------|-------------------|
| 1 | CRITICAL | Solo SQL | DB-001, DB-002, DB-003 | 1 migración |
| 2 | HIGH | Solo SQL | DB-004, DB-009, DB-010 | 1 migración |
| 3 | HIGH | Solo SQL | DB-005, DB-006, DB-007, DB-008, DB-014 | 1 migración |
| 4 | MEDIUM | SQL + Dart | DB-011, DB-012, DB-013, DB-015, APP-001, APP-002, APP-003 | 1 migración + 3 archivos Dart |
| 5 | LOW | SQL + Dart | DB-016, DB-017, DB-020, APP-004, APP-005, APP-006 | 1 migración + 3 archivos Dart |

**Importante:** Cada fase es un PR independiente. Las fases 1-3 son solo SQL (deploy a Supabase antes del código). Las fases 4-5 combinan SQL + Dart.

---

## FASE 1 — CRITICAL: Bloqueo de SECURITY DEFINER

**Problema:** Todas las funciones SECURITY DEFINER son invocables por el rol `anon` via REST API. `create_book_with_relations` y `update_book_with_relations` permiten a cualquier visitante crear/modificar libros, bypassing toda RLS.

**Por qué es CRITICAL:** Un bot o visitante puede inyectar datos, impersonar usuarios, y publicar contenido sin autenticación. Es la vulnerabilidad más grave posible.

### 1.1 Revoke anon EXECUTE en todas las funciones SECURITY DEFINER

**Migración:** `supabase/migrations/YYYYMMDD000000_security_critical_fix.sql`

```sql
-- 1. Revocar acceso anónimo a funciones sensibles
REVOKE EXECUTE ON FUNCTION
  public.create_book_with_relations(JSONB, INTEGER[], INTEGER[]),
  public.update_book_with_relations(JSONB, INTEGER[], INTEGER[]),
  public.get_analytics_overview(),
  public.get_views_trend(INTEGER),
  public.get_top_books(INTEGER),
  public.get_most_viewed_books(INTEGER),
  public.get_user_recent_views(UUID, INTEGER),
  public.handle_new_user()
FROM anon;

-- 2. Agregar role check en create_book_with_relations
CREATE OR REPLACE FUNCTION public.create_book_with_relations(
  p_book JSONB,
  p_genre_ids INTEGER[],
  p_label_ids INTEGER[]
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_book_id BIGINT;
BEGIN
  -- AUTH CHECK (nuevo)
  IF NOT is_admin_or_scan() THEN
    RAISE EXCEPTION 'Insufficient privileges: admin or scan role required';
  END IF;

  INSERT INTO books (
    created_at, cover, name, short, alternative, description,
    author_id, author, country, state, type, release,
    took_count, chapter_count, source, link,
    is_favorite, is_visible, created_by
  ) VALUES (
    (p_book->>'created_at')::TIMESTAMPTZ,
    p_book->>'cover',
    p_book->>'name',
    p_book->>'short',
    p_book->>'alternative',
    p_book->>'description',
    (p_book->>'author_id')::INTEGER,
    p_book->>'author',
    p_book->>'country',
    p_book->>'state',
    p_book->>'type',
    p_book->>'release',
    (p_book->>'took_count')::INTEGER,
    (p_book->>'chapter_count')::INTEGER,
    p_book->>'source',
    p_book->>'link',
    (p_book->>'is_favorite')::BOOLEAN,
    (p_book->>'is_visible')::BOOLEAN,
    auth.uid()  -- FORZAR uid del caller en vez de caller-supplied
  ) RETURNING id INTO v_book_id;

  -- Insertar genres
  IF p_genre_ids IS NOT NULL AND array_length(p_genre_ids, 1) > 0 THEN
    INSERT INTO books_genres (book_id, genre_id)
    SELECT v_book_id, unnest(p_genre_ids);
  END IF;

  -- Insertar labels
  IF p_label_ids IS NOT NULL AND array_length(p_label_ids, 1) > 0 THEN
    INSERT INTO books_labels (book_id, label_id)
    SELECT v_book_id, unnest(p_label_ids);
  END IF;

  RETURN v_book_id;
END;
$$;

-- 3. Agregar role check en update_book_with_relations
CREATE OR REPLACE FUNCTION public.update_book_with_relations(
  p_book JSONB,
  p_genre_ids INTEGER[],
  p_label_ids INTEGER[]
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_book_id BIGINT;
BEGIN
  v_book_id := (p_book->>'id')::BIGINT;

  -- AUTH CHECK (nuevo): admin puede todo, scan solo sus propios libros
  IF NOT (is_admin() OR (is_scan() AND EXISTS (
    SELECT 1 FROM books WHERE id = v_book_id AND created_by = auth.uid()
  ))) THEN
    RAISE EXCEPTION 'Insufficient privileges to update this book';
  END IF;

  UPDATE books SET
    cover = p_book->>'cover',
    name = p_book->>'name',
    short = p_book->>'short',
    alternative = p_book->>'alternative',
    description = p_book->>'description',
    author_id = (p_book->>'author_id')::INTEGER,
    country = p_book->>'country',
    state = p_book->>'state',
    type = p_book->>'type',
    release = p_book->>'release',
    took_count = (p_book->>'took_count')::INTEGER,
    chapter_count = (p_book->>'chapter_count')::INTEGER,
    source = p_book->>'source',
    link = p_book->>'link',
    is_favorite = (p_book->>'is_favorite')::BOOLEAN,
    is_visible = (p_book->>'is_visible')::BOOLEAN
  WHERE id = v_book_id;

  -- Reemplazar genres
  DELETE FROM books_genres WHERE book_id = v_book_id;
  IF p_genre_ids IS NOT NULL AND array_length(p_genre_ids, 1) > 0 THEN
    INSERT INTO books_genres (book_id, genre_id)
    SELECT v_book_id, unnest(p_genre_ids);
  END IF;

  -- Reemplazar labels
  DELETE FROM books_labels WHERE book_id = v_book_id;
  IF p_label_ids IS NOT NULL AND array_length(p_label_ids, 1) > 0 THEN
    INSERT INTO books_labels (book_id, label_id)
    SELECT v_book_id, unnest(p_label_ids);
  END IF;
END;
$$;
```

**Archivos Dart a modificar:** Ninguno. El client ya envía `created_by` pero el server ahora lo ignora (usa `auth.uid()`). No hay break change.

**Verificación:**
1. `supabase db reset` (local) o deploy a branch de desarrollo
2. Intentar llamar `create_book_with_relations` sin auth → debe fallar con "Insufficient privileges"
3. Login como scan, crear libro → debe funcionar, `created_by` = uid del scan
4. Login como admin, modificar libro de otro scan → debe funcionar
5. Login como scan, intentar modificar libro de otro scan → debe fallar

---

## FASE 2 — HIGH: Storage + Policies rotas

**Problema:** La policy permisiva de storage nunca fue eliminada (anula restricciones). `label_rules` tiene policies rotas. El rol `suspended` no tiene enforcement.

**Por qué es HIGH:** El storage de chapters es world-writable. Las operaciones sobre label_rules fallan con PostgreSQL error. Un usuario suspendido sigue funcionando normalmente.

### 2.1 Eliminar storage policy permisiva

**Migración:** `supabase/migrations/YYYYMMDD000001_security_storage_fix.sql`

```sql
-- Drop the overly permissive policy that negates owner restrictions
DROP POLICY IF EXISTS "Chapters authenticated all" ON storage.objects;
```

### 2.2 Fix label_rules policies

```sql
-- Todas las policies actuales llaman is_admin(auth.uid()) que NO EXISTE
-- Eliminar y recrear con is_admin() sin argumentos
DROP POLICY IF EXISTS "Admins can manage label_rules" ON label_rules;
DROP POLICY IF EXISTS "Admins can insert label_rules" ON label_rules;
DROP POLICY IF EXISTS "Admins can update label_rules" ON label_rules;
DROP POLICY IF EXISTS "Admins can delete label_rules" ON label_rules;
DROP POLICY IF EXISTS "Admins can read label_rules" ON label_rules;

-- Policy unificada para admin
CREATE POLICY "Admins can manage label_rules"
  ON label_rules FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());
```

### 2.3 Enforcement del rol suspended

```sql
-- Helper function
CREATE OR REPLACE FUNCTION public.is_suspended()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'suspended'
  );
$$;

-- RESTRICTIVE policies: niegan todo a suspended en tablas sensibles
-- PostgreSQL 15+ soporta AS RESTRICTIVE
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN SELECT unnest(ARRAY[
    'books', 'tooks', 'chapters', 'user_favorites',
    'chapter_reads', 'book_views'
  ])
  LOOP
    EXECUTE format(
      'CREATE POLICY "Deny suspended users" ON %I AS RESTRICTIVE
       FOR ALL TO public
       USING (NOT is_suspended())',
      tbl
    );
  END LOOP;
END;
$$;
```

**Archivos Dart a modificar:** Ninguno.

**Verificación:**
1. Login como usuario suspendido → no debe poder leer libros ni hacer ninguna operación
2. Login como admin → label_rules CRUD debe funcionar
3. Upload de chapter file → solo el owner puede modificar sus archivos

---

## FASE 3 — HIGH: Authorization gaps

**Problema:** IDOR en `get_user_recent_views`. Scan puede modificar autores/géneros de otros. `book_views` INSERT sin restricción de ownership.

**Por qué es HIGH:** Cualquier usuario puede leer el historial de lectura de cualquier otro (violación de privacidad). Scan puede borrar/autores creados por otros. Las vistas de libros pueden ser infladas.

### 3.1 Fix IDOR en get_user_recent_views

**Migración:** `supabase/migrations/YYYYMMDD000002_security_authz_fix.sql`

```sql
CREATE OR REPLACE FUNCTION public.get_user_recent_views(
  uid UUID DEFAULT auth.uid(),
  max_results INT DEFAULT 6
)
RETURNS TABLE(book_id BIGINT)
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = ''
AS $$
  SELECT b.id FROM book_views bv
  JOIN books b ON b.id = bv.book_id
  WHERE bv.user_id = uid
    AND (uid = auth.uid() OR is_admin())  -- Solo propio o admin
  ORDER BY bv.viewed_at DESC
  LIMIT max_results;
$$;
```

### 3.2 Restringir scan write en authors, genres, books_genres

```sql
-- Authors: eliminar policies de escritura de scan (admin-only)
DROP POLICY IF EXISTS "Enable insert for scan only" ON authors;
DROP POLICY IF EXISTS "Enable update for scan only" ON authors;
DROP POLICY IF EXISTS "Enable delete for scan only" ON authors;

-- Genres: eliminar policies de escritura de scan (admin-only)
DROP POLICY IF EXISTS "Enable insert for scan only" ON genres;
DROP POLICY IF EXISTS "Enable update for scan only" ON genres;
DROP POLICY IF EXISTS "Enable delete for scan only" ON genres;

-- Books_genres: eliminar policies de escritura de scan (admin-only)
DROP POLICY IF EXISTS "Enable insert for scan only" ON books_genres;
DROP POLICY IF EXISTS "Enable update for scan only" ON books_genres;
DROP POLICY IF EXISTS "Enable delete for scan only" ON books_genres;
```

### 3.3 Fix book_views INSERT policy

```sql
DROP POLICY IF EXISTS "Users can insert book views" ON book_views;

CREATE POLICY "Users can insert book views"
  ON book_views FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());
```

**Archivos Dart a modificar:** Ninguno.

**Verificación:**
1. Login como scan → no debe poder crear/modificar autores ni géneros
2. Login como user → `get_user_recent_views` solo retorna sus propias vistas
3. Login como admin → `get_user_recent_views(uid_de_otro)` debe funcionar
4. Intentar insertar book_views con user_id diferente → debe fallar

---

## FASE 4 — MEDIUM: Hardening BD + Flutter

**Problema:** Funciones sin search_path, analytics accesibles por cualquier user, email PII expuesto, uploads sin validación, client envía created_by.

**Por qué es MEDIUM:** Son debilidades de defensa en profundidad. No son explotables directamente pero amplían el surface de ataque.

### 4.1 search_path en todas las funciones

**Migración:** `supabase/migrations/YYYYMMDD000003_security_hardening.sql`

```sql
-- Fix is_user (única helper sin search_path)
CREATE OR REPLACE FUNCTION public.is_user()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = ''
AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'user');
$$;

-- Fix update_label_rules_updated_at
CREATE OR REPLACE FUNCTION public.update_label_rules_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;
```

### 4.2 Analytics admin-only

```sql
-- Revocar acceso de authenticated a funciones de analytics
REVOKE EXECUTE ON FUNCTION
  public.get_analytics_overview(),
  public.get_views_trend(INTEGER),
  public.get_top_books(INTEGER),
  public.get_most_viewed_books(INTEGER)
FROM authenticated;

-- Solo service_role puede ejecutar analytics
-- (Supabase usa service_role para admin panel, o crear una función wrapper)
```

**Nota:** Si el admin panel usa el client anon key + RLS para analytics, necesitamos un approach diferente: agregar role check dentro de cada función en vez de revoke. Evaluar en implementación.

### 4.3 Restringir email PII

```sql
DROP POLICY IF EXISTS "Scan can read all profiles" ON profiles;

-- Scan solo puede ver su propio perfil completo
CREATE POLICY "Scan can read own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (is_scan() AND id = auth.uid());
```

### 4.4 App: Quitar created_by del client

**Archivo:** `lib/features/books/data/book_repository_impl.dart`

```dart
// LÍNEA 83 — ELIMINAR created_by del bookJson
// ANTES:
final bookJson = {
  ...
  'created_by': _supabase.client.auth.currentUser?.id,  // ELIMINAR
};

// DESPUÉS:
final bookJson = {
  ...  // sin created_by — el server usa auth.uid()
};
```

### 4.5 App: Validación de avatar upload

**Archivo:** `lib/features/profiles/data/profiles_repository_impl.dart`

```dart
// LÍNEA 56-70 — Agregar validación antes del upload
static const int _maxAvatarSize = 5 * 1024 * 1024; // 5MB
static const _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

@override
Future<Result<String>> uploadAvatar(String filePath) async {
  try {
    final user = _supabase.client.auth.currentUser;
    if (user == null) return Err(ProfileFailure('No hay sesión activa'));

    // Validar extensión
    final ext = filePath.split('.').last.toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      return Err(ProfileFailure('Formato no permitido. Usa: JPG, PNG, o WebP'));
    }

    // Validar tamaño
    final file = File(filePath);
    final fileSize = await file.length();
    if (fileSize > _maxAvatarSize) {
      return Err(ProfileFailure('El archivo es demasiado grande. Máximo: 5MB'));
    }

    final path = '${user.id}/avatar.$ext';
    await _supabase.client.storage
        .from('avatars')
        .upload(path, file, fileOptions: const FileOptions(upsert: true));
    final url = _supabase.client.storage.from('avatars').getPublicUrl(path);
    return Ok('$url?v=${DateTime.now().millisecondsSinceEpoch}');
  } catch (e) {
    return Err(ProfileFailure('Error al subir avatar', cause: e));
  }
}
```

### 4.6 App: Validación de chapter upload

**Archivo:** `lib/features/chapters/data/chapter_repository_impl.dart`

```dart
// LÍNEA 95-106 — Agregar validación
static const int _maxChapterSize = 10 * 1024 * 1024; // 10MB
static const _allowedExtensions = ['txt', 'html'];

@override
Future<Result<String>> uploadContent(String filePath) async {
  try {
    final ext = filePath.split('.').last.toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      return Err(ChapterFailure('Formato no permitido. Usa: TXT o HTML'));
    }

    final file = File(filePath);
    final fileSize = await file.length();
    if (fileSize > _maxChapterSize) {
      return Err(ChapterFailure('El archivo es demasiado grande. Máximo: 10MB'));
    }

    final userId = _supabase.client.auth.currentUser?.id;
    if (userId == null) return Err(ChapterFailure('No hay sesión activa'));

    final filename = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _supabase.client.storage
        .from(StorageConstants.chaptersBucket)
        .upload(filename, file);
    final url = _supabase.client.storage
        .from(StorageConstants.chaptersBucket)
        .getPublicUrl(filename);
    return Ok(url);
  } catch (e) {
    return Err(ChapterFailure('Error al subir contenido', cause: e));
  }
}
```

**Verificación:**
1. `dart analyze lib/` → 0 errores
2. `flutter test` → todos pasan
3. Subir avatar .gif → debe rechazar
4. Subir chapter .exe → debe rechazar
5. Crear libro desde Dart → `created_by` en DB debe ser el uid del usuario, no del client

---

## FASE 5 — LOW: Defense-in-depth

**Problema:** Avatars bucket sin restricciones, chapter_reads sin DELETE, pg_net sin uso, validación de email débil, password sin complejidad, error messages con leak de info.

**Por qué es LOW:** Issues reales pero de bajo impacto inmediato. Completan el Hardening.

### 5.1 Configurar avatars bucket

**Migración:** `supabase/migrations/YYYYMMDD000004_security_low_fix.sql`

```sql
UPDATE storage.buckets
SET allowed_mime_types = ARRAY['image/png', 'image/jpeg', 'image/webp'],
    file_size_limit = 5242880  -- 5MB
WHERE id = 'avatars';
```

### 5.2 DELETE policy en chapter_reads

```sql
CREATE POLICY "Users can delete own chapter reads"
  ON chapter_reads FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());
```

### 5.3 Eliminar pg_net

```sql
DROP EXTENSION IF EXISTS pg_net;
```

### 5.4 App: Email validation

**Archivo:** `lib/features/auth/presentation/screens/login_screen.dart` + `register_screen.dart`

```dart
// Reemplazar validación débil:
// ANTES:
if (!value.contains('@')) return 'Correo inválido';

// DESPUÉS:
final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
if (!emailRegex.hasMatch(value)) return 'Correo inválido';
```

### 5.5 App: Password validation

**Archivo:** `lib/features/auth/presentation/screens/register_screen.dart`

```dart
// Agregar complejidad:
validator: (value) {
  if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
  if (value.length < 8) return 'Mínimo 8 caracteres';  //-era 6
  if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Debe incluir una mayúscula';
  if (!RegExp(r'[0-9]').hasMatch(value)) return 'Debe incluir un número';
  return null;
},
```

### 5.6 App: Fix error message leak

**Archivo:** `lib/features/chapters/data/chapter_repository_impl.dart`

```dart
// LÍNEA 105 — Ocultar detail del error
// ANTES:
return Err(ChapterFailure('Error al subir contenido: $e', cause: e));

// DESPUÉS:
return Err(ChapterFailure('Error al subir contenido', cause: e));
```

**Verificación:**
1. `dart analyze lib/` → 0 errores
2. `flutter test` → todos pasan
3. Subir avatar de 10MB → debe rechazar
4. Registrar con email "invalido" → debe rechazar
5. Registrar con password "12345" → debe rechazar

---

## Comandos de Verificación Globales

Después de CADA fase:
```bash
dart analyze lib/
flutter test
```

Después de completar TODAS las fases:
```bash
dart analyze lib/ --fatal-infos
flutter test --coverage
```

Verificación de seguridad post-deploy:
```bash
# Verificar que anon no puede ejecutar funciones
curl -X POST YOUR_SUPABASE_URL/rest/v1/rpc/create_book_with_relations \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"p_book": {}, "p_genre_ids": [], "p_label_ids": []}'
# Debe retornar 403 o error de permisos
```

---

## Orden de Ejecución

1. **Fase 1** (CRITICAL) — deploy SQL a Supabase
2. **Fase 2** (HIGH storage) — deploy SQL a Supabase
3. **Fase 3** (HIGH authz) — deploy SQL a Supabase
4. **Fase 4** (MEDIUM) — deploy SQL + merge Dart code
5. **Fase 5** (LOW) — deploy SQL + merge Dart code

**RESTRICCIÓN:** Las fases 1-3 son SQL puro — pueden y deben deployarse ANTES de cualquier cambio en Dart. Esto cierra las vulnerabilidades críticas de inmediato.

---

## Checklist de Progreso

- [x] Fase 1: SECURITY DEFINER lockdown (DB-001, DB-002, DB-003) — `20260727000000_security_critical_fix.sql`
- [x] Fase 2: Storage + label_rules + suspended (DB-004, DB-009, DB-010) — `20260727000001_security_storage_fix.sql`
- [x] Fase 3: IDOR + scan ownership + book_views (DB-005, DB-006, DB-007, DB-008, DB-014) — `20260727000002_security_authz_fix.sql`
- [x] Fase 4: Hardening (DB-011, DB-012, DB-013, DB-015, APP-001, APP-002, APP-003) — `20260727000003_security_hardening.sql` + 3 Dart files
- [x] Fase 5: Defense-in-depth (DB-016, DB-017, DB-020, APP-004, APP-005, APP-006) — `20260727000004_security_low_fix.sql` + 2 Dart files
- [ ] Verificación final: `dart analyze`, `flutter test`, test manual de permisos
