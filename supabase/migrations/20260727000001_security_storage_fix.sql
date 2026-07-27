-- =============================================================================
-- FASE 2 — HIGH: Storage + Broken Policies + Suspended Enforcement
-- Findings: DB-004, DB-009, DB-010
-- Fecha: 2026-07-27
-- =============================================================================
-- 1. DB-010: "Chapters authenticated all" anula las restricciones de owner
-- 2. DB-004: label_rules policies llaman is_admin(uid) que NO EXISTE
-- 3. DB-009: suspended role no tiene enforcement en RLS
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. DB-010: Eliminar storage policy permisiva
--    La policy "Chapters authenticated all" (FOR ALL) permite a CUALQUIER
--    usuario autenticado insertar/update/delete CUALQUIER archivo en chapters.
--    Las policies restrictivas de owner (20260720020000) se anulan porque
--    PostgreSQL suma policies permisivas.
-- ─────────────────────────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Chapters authenticated all" ON storage.objects;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. DB-004: Fix label_rules policies
--    Las policies actuales llaman is_admin(auth.uid()) pero is_admin() no
--    toma argumentos. Todas las operaciones INSERT/UPDATE/DELETE fallan con
--    PostgreSQL error: function public.is_admin(uuid) does not exist.
-- ─────────────────────────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Admins can manage label_rules" ON label_rules;
DROP POLICY IF EXISTS "Admins can insert label_rules" ON label_rules;
DROP POLICY IF EXISTS "Admins can update label_rules" ON label_rules;
DROP POLICY IF EXISTS "Admins can delete label_rules" ON label_rules;
DROP POLICY IF EXISTS "Admins can read label_rules" ON label_rules;

-- Policy unificada: admin puede todo, Everyone puede leer
CREATE POLICY "Admins can manage label_rules"
  ON label_rules
  FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

CREATE POLICY "Everyone can read label_rules"
  ON label_rules
  FOR SELECT
  TO authenticated
  USING (true);

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. DB-009: Enforcement del rol suspended
--    El rol suspended solo tiene CHECK constraint pero ninguna policy lo
--    bloquea. Un usuario suspendido conserva todos los permisos de user.
-- ─────────────────────────────────────────────────────────────────────────────

-- Helper function
CREATE OR REPLACE FUNCTION public.is_suspended()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'suspended'
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
    -- Solo crear si no existe ya
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE policyname = 'Deny suspended users'
        AND tablename = tbl
        AND schemaname = 'public'
    ) THEN
      EXECUTE format(
        'CREATE POLICY "Deny suspended users" ON %I AS RESTRICTIVE
         FOR ALL TO public
         USING (NOT is_suspended())',
        tbl
      );
    END IF;
  END LOOP;
END;
$$;
