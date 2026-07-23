# Políticas RLS

> Total: 65 políticas en 12 tablas.
> Todas las políticas usan modo PERMISSIVE.
> Funciones auxiliares: `is_admin()`, `is_scan()`, `is_user()`,
> `is_admin_or_scan()`.

## Funciones Auxiliares de Rol

```sql
-- Usadas en condiciones RLS
is_admin()      -- devuelve true si el usuario actual tiene role = 'admin'
is_scan()       -- devuelve true si el usuario actual tiene role = 'scan'
is_user()       -- devuelve true si el usuario actual tiene role = 'user'
is_admin_or_scan() -- devuelve true si es admin O scan
```text

---

## profiles (6 políticas)

| Operación | Nombre de Política | Rol | Condición |
| --------- | ------------------ | --- | --------- |
| SELECT | Admin puede leer todos los perfiles | public | `is_admin()` |
| SELECT | Scan puede leer todos los perfiles | public | `is_scan()` |
| SELECT | Usuarios pueden leer su propio perfil | public | `auth.uid() = id` |
| INSERT | Usuarios insertan su propio perfil | public | `auth.uid() = id` |
| UPDATE | Admin puede actualizar perfiles | public | `is_admin()` |
| UPDATE | Usuarios actualizan su propio perfil | public | `auth.uid() = id` |

**Notas**: Scan puede leer todos los perfiles (necesario para mostrar autores).
Los usuarios no pueden eliminar perfiles.

---

## books (8 políticas)

| Operación | Nombre de Política | Rol | Condición |
| --------- | ------------------ | --- | --------- |
| SELECT | Admin puede leer todos los libros | public | `is_admin()` |
| SELECT | Scan: leer sus libros | public | is_scan() AND created_by = au... |
| SELECT | Users: leer libros visibles | public | is_visible = true AND NO... |
| INSERT | Insert solo para admin | public | `is_admin()` |
| INSERT | Insert solo para scan | public | is_scan() AND created_by ... |
| UPDATE | Update solo para admin | public | `is_admin()` |
| UPDATE | Update solo para scan | public | is_scan() AND created_by ... |
| DELETE | Delete solo para admin | public | `is_admin()` |
| DELETE | Delete solo para scan | public | is_scan() AND created_by ... |

**Notas**: Scan solo puede CRUD sobre sus propios libros. Los usuarios solo ven
libros visibles.

---

## authors (7 políticas)

| Operación | Nombre de Política | Rol | Condición |
| --------- | ------------------ | --- | --------- |
| SELECT | Habilitar lectura para todos los usuarios | public | `true` |
| INSERT | Habilitar insert solo para admin | public | `is_admin()` |
| INSERT | Habilitar insert solo para scan | public | `is_scan()` |
| UPDATE | Habilitar update solo para admin | public | `is_admin()` |
| UPDATE | Habilitar update solo para scan | public | `is_scan()` |
| DELETE | Habilitar delete solo para admin | public | `is_admin()` |
| DELETE | Habilitar delete solo para scan | public | `is_scan()` |

**Notas**: Los autores son recursos compartidos — tanto admin como scan pueden
crear/editar.

---

## genres (7 políticas)

| Operación | Nombre de Política | Rol | Condición |
| --------- | ------------------ | --- | --------- |
| SELECT | Habilitar lectura para todos los usuarios | public | `true` |
| INSERT | Habilitar insert solo para admin | public | `is_admin()` |
| INSERT | Habilitar insert solo para scan | public | `is_scan()` |
| UPDATE | Habilitar update solo para admin | public | `is_admin()` |
| UPDATE | Habilitar update solo para scan | public | `is_scan()` |
| DELETE | Habilitar delete solo para admin | public | `is_admin()` |
| DELETE | Habilitar delete solo para scan | public | `is_scan()` |

**Notas**: Los géneros son recursos compartidos — tanto admin como scan pueden
crear/editar.

---

## labels (4 políticas)

| Operación | Nombre de Política | Rol | Condición |
| --------- | ------------------ | --- | --------- |
| SELECT | Lectura para todos los usuarios | public | `true` |
| INSERT | Insert para scan y admin | public | is_scan() OR is_admin() |
| UPDATE | Update para scan y admin | public | is_scan() OR is_admin() |
| DELETE | Delete para scan y admin | public | is_scan() OR is_admin() |

**Notas**: Las etiquetas son compartidas — scan y admin pueden gestionarlas.

---

## books_genres (7 políticas)

| Operación | Nombre de Política | Rol | Condición |
| --------- | ------------------ | --- | --------- |
| SELECT | Habilitar lectura para todos los usuarios | public | `true` |
| INSERT | Habilitar insert solo para admin | public | `is_admin()` |
| INSERT | Habilitar insert solo para scan | public | `is_scan()` |
| UPDATE | Habilitar update solo para admin | public | `is_admin()` |
| UPDATE | Habilitar update solo para scan | public | `is_scan()` |
| DELETE | Habilitar delete solo para admin | public | `is_admin()` |
| DELETE | Habilitar delete solo para scan | public | `is_scan()` |

**Notas**: Tabla de unión — sigue las mismas reglas que genres.

---

## books_labels (3 políticas)

| Operación | Nombre de Política | Rol | Condición |
| --------- | ------------------ | --- | --------- |
| SELECT | Lectura para todos los usuarios | public | `true` |
| INSERT | Insert para scan y admin | public | is_scan() OR is_admin() |
| DELETE | Delete para scan y admin | public | is_scan() OR is_admin() |

**Notas**: Tabla de unión — scan y admin pueden gestionar etiquetas en libros.

---

## tooks (8 políticas)

| Operación | Nombre de Política | Rol | Condición |
| --------- | ------------------ | --- | --------- |
| SELECT | Lectura para todos los usuarios | public | `true` |
| INSERT | Insert solo para admin | public | `is_admin()` |
| INSERT | Insert solo para scan | public | is_scan() AND created_by ... |
| UPDATE | Update solo para admin | public | `is_admin()` |
| UPDATE | Update solo para scan | public | is_scan() AND created_by ... |
| DELETE | Delete solo para admin | public | `is_admin()` |
| DELETE | Delete solo para scan | public | is_scan() AND created_by ... |

**Notas**: Scan solo puede CRUD sobre sus propios tomos.

---

## chapters (8 políticas)

| Operación | Nombre de Política | Rol | Condición |
| --------- | ------------------ | --- | --------- |
| SELECT | Lectura para todos los usuarios | public | `true` |
| INSERT | Insert solo para admin | public | `is_admin()` |
| INSERT | Insert solo para scan | public | is_scan() AND created_by ... |
| UPDATE | Update solo para admin | public | `is_admin()` |
| UPDATE | Update solo para scan | public | is_scan() AND created_by ... |
| DELETE | Delete solo para admin | public | `is_admin()` |
| DELETE | Delete solo para scan | public | is_scan() AND created_by ... |

**Notas**: Scan solo puede CRUD sobre sus propios capítulos.

---

## book_views (2 políticas)

| Operación | Nombre de Política | Rol | Condición |
| --------- | ------------------ | --- | --------- |
| SELECT | Admin puede leer vistas de libros | authenticated | `is_admin()` |
| INSERT | Usuarios pueden insertar vistas de libros | authenticated | `true` |

**Notas**: Cualquier usuario autenticado puede registrar vistas. Solo admin
puede leer analytics.

---

## user_favorites (3 políticas)

| Operación | Nombre de Política | Rol | Condición |
| --------- | ------------------ | --- | --------- |
| SELECT | Users: leer sus favoritos | public | `auth.uid() = user_id` |
| INSERT | Users: insertar sus favoritos | public | `auth.uid() = user_id` |
| DELETE | Users: eliminar sus favoritos | public | `auth.uid() = user_id` |

**Notas**: Cada usuario solo puede ver/gestionar sus propios favoritos. Sin
anulación de admin.

---

## label_rules (2 políticas)

| Operación | Nombre de Política | Rol | Condición |
| --------- | ------------------ | --- | --------- |
| ALL | Admins pueden gestionar label_rules | authenticated | `is_admin()` |
| SELECT | Todos pueden leer label_rules | authenticated | `true` |

**Notas**: CRUD solo para admin. Todos los usuarios autenticados pueden leer las
reglas (la app necesita mostrarlas). Sin acceso de escritura para scan ni
usuario regular.

---

## Políticas de Storage

### Bucket covers

| Operación | Política | Condición |
| --------- | -------- | --------- |
| INSERT | Covers: insert en carpeta propia | bucket_id = 'covers' A... |
| UPDATE | Covers: update en carpeta propia | Igual que INSERT |
| DELETE | Covers: delete en carpeta propia | Igual que INSERT |

### Bucket chapters

| Operación | Política | Condición |
| --------- | -------- | --------- |
| INSERT | Chapters: insert en carpeta propia | bucket_id = 'chapter... |
| UPDATE | Chapters: update en carpeta propia | Igual que INSERT |
| DELETE | Chapters: delete en carpeta propia | Igual que INSERT |

**Notas**: Storage restringido al prefijo `{user_id}/`. Acceso de lectura
pública habilitado en ambos buckets.

---

## Observaciones de Seguridad

### ✅ Seguro

- RLS habilitado en TODAS las tablas
- Las funciones SECURITY DEFINER previenen elusión de RLS
- Propiedad de contenido verificada (`created_by = auth.uid()`)
- Favoritos completamente aislados por usuario
- Storage restringido a carpetas de usuario

### ⚠️ Monitorear

- `book_views` INSERT no tiene límite de tasa (cualquier usuario autenticado)
- `profiles` SELECT para scan muestra todos los usuarios (intencional para
  mostrar autores)
- Los buckets de Storage son públicos (las URLs son legibles por cualquiera)
