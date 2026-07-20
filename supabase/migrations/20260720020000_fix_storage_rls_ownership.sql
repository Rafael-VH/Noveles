-- Fix Storage RLS: restrict uploads to user's own folder
-- Phase2.3: Storage ownership verification
--
-- IMPORTANT: This migration changes the storage folder structure from
-- {timestamp}.{ext} to {user_id}/{timestamp}.{ext}
-- Existing files in the root of covers/chapters buckets will still be readable
-- but new uploads will go to user-specific folders.

-- ============================================================
-- COVERS BUCKET
-- ============================================================
-- Drop old policies that allowed any authenticated user
DROP POLICY IF EXISTS "Covers authenticated insert" ON storage.objects;
DROP POLICY IF EXISTS "Covers authenticated update" ON storage.objects;
DROP POLICY IF EXISTS "Covers authenticated delete" ON storage.objects;

-- New policies: restrict to user's own folder
CREATE POLICY "Covers: authenticated insert own folder"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'covers'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Covers: authenticated update own folder"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'covers'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Covers: authenticated delete own folder"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'covers'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- ============================================================
-- CHAPTERS BUCKET
-- ============================================================
-- Drop old policies that allowed any authenticated user
DROP POLICY IF EXISTS "Chapters authenticated insert" ON storage.objects;
DROP POLICY IF EXISTS "Chapters authenticated update" ON storage.objects;
DROP POLICY IF EXISTS "Chapters authenticated delete" ON storage.objects;

-- New policies: restrict to user's own folder
CREATE POLICY "Chapters: authenticated insert own folder"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'chapters'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Chapters: authenticated update own folder"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'chapters'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Chapters: authenticated delete own folder"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'chapters'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );
