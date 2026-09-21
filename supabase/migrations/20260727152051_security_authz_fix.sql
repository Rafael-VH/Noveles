-- =============================================================================
-- FASE 3 — HIGH: Authorization Gaps
-- Findings: DB-005, DB-006, DB-007, DB-008, DB-014
-- Fecha: 2026-07-27
-- =============================================================================
-- 1. DB-005: IDOR en get_user_recent_views — cualquier usuario puede leer
--    el historial de lectura de cualquier otro.
-- 2. DB-006/007/008: Scan puede modificar autores, géneros, y asociaciones
--    de CUALQUIER usuario (no ownership check).
-- 3. DB-014: book_views INSERT permite cualquier user_id (inflación de vistas).
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. DB-005: Fix IDOR en get_user_recent_views
--    Agregar verificación: solo propio o admin puede consultar.
-- ─────────────────────────────────────────────────────────────────────────────

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
    AND (uid = auth.uid() OR is_admin())
  ORDER BY bv.viewed_at DESC
  LIMIT max_results;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. DB-006/007/008: Restringir scan write en authors, genres, books_genres
--    Estas tablas son datos de referencia compartidos. Scan no debería poder
--    modificar los de otros usuarios. Solo admin.
-- ─────────────────────────────────────────────────────────────────────────────

-- Authors: eliminar policies de escritura de scan
DROP POLICY IF EXISTS "Enable insert for scan only" ON authors;
DROP POLICY IF EXISTS "Enable update for scan only" ON authors;
DROP POLICY IF EXISTS "Enable delete for scan only" ON authors;

-- Genres: eliminar policies de escritura de scan
DROP POLICY IF EXISTS "Enable insert for scan only" ON genres;
DROP POLICY IF EXISTS "Enable update for scan only" ON genres;
DROP POLICY IF EXISTS "Enable delete for scan only" ON genres;

-- Books_genres: eliminar policies de escritura de scan
DROP POLICY IF EXISTS "Enable insert for scan only" ON books_genres;
DROP POLICY IF EXISTS "Enable update for scan only" ON books_genres;
DROP POLICY IF EXISTS "Enable delete for scan only" ON books_genres;

-- Verificar que existan policies de admin para estas tablas
-- (ya deberían existir de migraciones anteriores, pero por seguridad)
DO $$
BEGIN
  -- Authors admin policies
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Enable insert for admin only' AND tablename = 'authors'
  ) THEN
    CREATE POLICY "Enable insert for admin only" ON authors
      FOR INSERT WITH CHECK (public.is_admin());
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Enable update for admin only' AND tablename = 'authors'
  ) THEN
    CREATE POLICY "Enable update for admin only" ON authors
      FOR UPDATE USING (public.is_admin());
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Enable delete for admin only' AND tablename = 'authors'
  ) THEN
    CREATE POLICY "Enable delete for admin only" ON authors
      FOR DELETE USING (public.is_admin());
  END IF;

  -- Genres admin policies
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Enable insert for admin only' AND tablename = 'genres'
  ) THEN
    CREATE POLICY "Enable insert for admin only" ON genres
      FOR INSERT WITH CHECK (public.is_admin());
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Enable update for admin only' AND tablename = 'genres'
  ) THEN
    CREATE POLICY "Enable update for admin only" ON genres
      FOR UPDATE USING (public.is_admin());
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Enable delete for admin only' AND tablename = 'genres'
  ) THEN
    CREATE POLICY "Enable delete for admin only" ON genres
      FOR DELETE USING (public.is_admin());
  END IF;

  -- Books_genres admin policies
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Enable insert for admin only' AND tablename = 'books_genres'
  ) THEN
    CREATE POLICY "Enable insert for admin only" ON books_genres
      FOR INSERT WITH CHECK (public.is_admin());
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Enable update for admin only' AND tablename = 'books_genres'
  ) THEN
    CREATE POLICY "Enable update for admin only" ON books_genres
      FOR UPDATE USING (public.is_admin());
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Enable delete for admin only' AND tablename = 'books_genres'
  ) THEN
    CREATE POLICY "Enable delete for admin only" ON books_genres
      FOR DELETE USING (public.is_admin());
  END IF;
END;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. DB-014: Fix book_views INSERT policy
--    WITH CHECK (true) permite a cualquier usuario inflar vistas o
--    asociar fake views a otros usuarios.
-- ─────────────────────────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Users can insert book views" ON book_views;

CREATE POLICY "Users can insert book views"
  ON book_views FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());
