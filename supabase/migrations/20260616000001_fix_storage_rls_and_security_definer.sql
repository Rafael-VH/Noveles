-- ============================================================
-- Fix Storage RLS Policies + SECURITY DEFINER (Phase 1.1)
-- ============================================================
-- IDEMPOTENT: Uses DO blocks for policy existence checks
-- Rollback: Reverse order of operations
-- ============================================================

-- STEP 1: CRIT-1 — Add RLS policies for chapters storage bucket
-- Without these, chapter content files are completely inaccessible
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Chapters public read' AND tablename = 'objects' AND schemaname = 'storage'
  ) THEN
    CREATE POLICY "Chapters public read" ON storage.objects FOR SELECT USING (bucket_id = 'chapters');
  END IF;
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Chapters authenticated all' AND tablename = 'objects' AND schemaname = 'storage'
  ) THEN
    CREATE POLICY "Chapters authenticated all" ON storage.objects FOR ALL USING (bucket_id = 'chapters' AND auth.role() = 'authenticated');
  END IF;
END;
$$;

-- STEP 2: CRIT-2 — Add missing SELECT policy for covers bucket
-- Without this, cover images cannot be fetched by any user
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Covers public read' AND tablename = 'objects' AND schemaname = 'storage'
  ) THEN
    CREATE POLICY "Covers public read" ON storage.objects FOR SELECT USING (bucket_id = 'covers');
  END IF;
END;
$$;

-- STEP 3: CRIT-3 — Fix is_admin_or_scan() SECURITY DEFINER
-- Add SET search_path = '' to prevent search_path injection
CREATE OR REPLACE FUNCTION public.is_admin_or_scan()
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid()
      AND role IN ('admin', 'scan')
  );
$$;

-- ============================================================
-- ROLLBACK:
--   DROP POLICY IF EXISTS "Chapters public read" ON storage.objects;
--   DROP POLICY IF EXISTS "Chapters authenticated all" ON storage.objects;
--   DROP POLICY IF EXISTS "Covers public read" ON storage.objects;
--   CREATE OR REPLACE FUNCTION public.is_admin_or_scan()
--     RETURNS BOOLEAN LANGUAGE SQL STABLE SECURITY DEFINER AS $$
--       SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'scan'));
--     $$;
-- ============================================================
