-- =============================================================================
-- FIX: REVOKE real de escalacion de rol en profiles (complementa 20260905000000)
-- Fecha: 2026-09-05
-- Problema: 20260905000000 aplico REVOKE UPDATE (role, id, email) por COLUMNA,
-- pero authenticated conserva un GRANT UPDATE a nivel TABLA (de las migraciones
-- de mayo), que en Postgres se suma al grant por columna: el REVOKE por columna
-- no quita acceso mientras exista el table-level UPDATE. Solo el trigger
-- prevent_self_role_change contenía la escalacion.
-- Fix:
--   1. REVOKE UPDATE table-level FROM authenticated.
--   2. GRANT UPDATE de las UNICAS columnas que la app modifica por tabla
--      (display_name, avatar_url; ver profiles_repository_impl). Los cambios de
--      role/id/email quedan solo para los RPCs admin (SECURITY DEFINER).
-- =============================================================================

REVOKE UPDATE ON public.profiles FROM authenticated;

GRANT UPDATE (display_name, avatar_url) ON public.profiles TO authenticated;