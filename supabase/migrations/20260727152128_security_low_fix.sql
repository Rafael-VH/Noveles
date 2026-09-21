-- =============================================================================
-- FASE 5 — LOW: Defense-in-depth
-- Findings: DB-016, DB-017, DB-020
-- Fecha: 2026-07-27
-- =============================================================================
-- 1. DB-016: Configurar avatars bucket (MIME types + size limit)
-- 2. DB-017: DELETE policy en chapter_reads
-- 3. DB-020: Eliminar pg_net (unused extension)
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. DB-016: Avatars bucket — MIME types + size limit
-- ─────────────────────────────────────────────────────────────────────────────

UPDATE storage.buckets
SET
  allowed_mime_types = ARRAY['image/png', 'image/jpeg', 'image/webp'],
  file_size_limit = 5242880  -- 5MB
WHERE id = 'avatars';

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. DB-017: DELETE policy en chapter_reads
-- ─────────────────────────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Users can delete own chapter reads" ON chapter_reads;

CREATE POLICY "Users can delete own chapter reads"
  ON chapter_reads FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. DB-020: Eliminar pg_net (unused extension)
-- ─────────────────────────────────────────────────────────────────────────────

DROP EXTENSION IF EXISTS pg_net;
