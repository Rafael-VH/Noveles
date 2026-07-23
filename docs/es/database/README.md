# Auditoría de Base de Datos Supabase

> Fecha de auditoría: 2026-07-23
> Migraciones aplicadas: 35 (última: `20260722000000_chapter_reads`)

## Resumen

| Métrica | Valor |
| ------- | ----- |
| Tablas | 13 (todas con RLS habilitado) |
| Funciones SQL | 11 (todas SECURITY DEFINER) |
| Buckets de Storage | 3 |
| Políticas RLS Totales | 63 |

## Enlaces Rápidos

- [Tablas y Esquema](tables.md) — columnas, tipos, mapeo de código, políticas
  requeridas
- [Políticas RLS](rls-policies.md) — las 63 políticas con condiciones
- [Funciones SQL](sql-functions.md) — 9 funciones SECURITY DEFINER
- [Storage](storage.md) — 3 buckets, estructura de carpetas, RLS

## Modelo de Roles

| Rol | Nivel de Acceso |
| --- | --------------- |
| `admin` | Acceso completo — CRUD todas tablas, leer analytics |
| `scan` | Creador — CRUD sobre contenido propio (`created_by = auth.uid()`) |
| `user` | Lector — leer libros visibles, gestionar favoritos |
| `suspended` | Sin acceso — bloqueado a nivel de app (routing guard) |

## Historial de Migraciones

| Versión | Nombre | Fecha | Propósito |
| ------- | ------ | ----- | --------- |
| 20260723043930 | enable_pg_net | Jul 23 | Habilitar pg_net edge functions |
| 20260723043750 | label_rules | Jul 23 | Tabla label_rules + RLS + trigger |
| 20260723041644 | add_email_to_profiles | Jul 23 | Columna email a profiles |
| 20260514220000 | initial_schema | May 14 | Tablas core (books, authors...) |
| 20260515000000 | authors_and_constraints | May 15 | Restricciones de autor |
| 20260515161849 | profiles_and_auth | May 15 | Auth + profiles |
| 20260515170000 | profiles_extended | May 15 | Campos extendidos de perfil |
| 20260515200000 | storage_migration | May 15 | Buckets de Storage |
| 20260515210000 | admin_roles | May 15 | Sistema de rol admin |
| 20260515230000 | fix_admin_consolidation | May 15 | Consolidación de admin |
| 20260515235000 | fix_storage_buckets | May 15 | Corrección buckets Storage |
| 20260517205000 | fix_profiles_rls_recursion | May 17 | Corrige recursión RLS |
| 20260518010000 | admin_ownership | May 18 | Propiedad (ownership) admin |
| 20260519000000 | fix_tooks_chapters_rls | May 19 | RLS de tomos/capítulos |
| 20260520000000 | rename_admin_to_scan | May 20 | Renombrar admin → scan |
| 20260520010000 | add_admin_role | May 20 | Agregar rol admin |
| 20260520020000 | labels | May 20 | Sistema de etiquetas |
| 20260520171320 | storage_authenticated_u... | May 20 | Subidas autenticadas |
| 20260521000000 | fix_scan_rls_own_books | May 21 | RLS scan: libros propios |
| 20260521200000 | audit_plan_fixes | May 21 | Correcciones de auditoría |
| 20260522000000 | audit_fixes | May 22 | Correcciones de auditoría |
| 20260523000000 | admin_panels | May 23 | Paneles admin + book_views |
| 20260524000000 | audit_fixes_v2 | May 24 | Correcciones de auditoría v2 |
| 20260524100000 | profiles_rls_insert_update | May 24 | RLS de perfiles |
| 20260524110000 | fix_books_rls_scan_visibility | May 24 | Visibilidad libros |
| 20260615000000 | audit_fixes_v4 | Jun 15 | Correcciones de auditoría v4 |
| 20260616000001 | fix_storage_rls_and_se... | Jun 16 | Storage RLS + seg. |
| 20260617000001 | fix_sequences_after_seed | Jun 17 | Corrección secuencias |
| 20260617153406 | fix_chapters_storage_rls | Jun 17 | RLS storage capítulos |
| 20260720010000 | add_is_user_helper | Jul 20 | Función `is_user()` |
| 20260720020000 | fix_storage_rls_ownership | Jul 20 | Carpetas Storage |
| 20260720030000 | create_user_favorites | Jul 20 | Tabla de favoritos |
| 20260720040000 | add_suspended_role | Jul 20 | Restricción rol suspendido |
| 20260720050000 | create_analytics_func... | Jul 20 | Funciones SQL analytics |
| 20260722000000 | chapter_reads | Jul 22 | Seguimiento lectura caps. + RPCs |
