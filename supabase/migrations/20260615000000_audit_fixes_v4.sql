-- ============================================================
-- Audit Fixes v4 — Consolidated Migration (Phase 4)
-- ============================================================
-- IDEMPOTENT: All statements use IF [NOT] EXISTS / DROP IF EXISTS
-- Rollback: Reverse the order of operations
-- ============================================================

-- STEP 1: DB-W5 — Create is_admin_or_scan() helper for RLS policies
-- Combines both role checks into one reusable function
CREATE OR REPLACE FUNCTION public.is_admin_or_scan()
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid()
      AND role IN ('admin', 'scan')
  );
$$;

-- STEP 2: DB-W1 — Drop dead column books.author
-- Data migrated to authors table; column no longer used by code
ALTER TABLE books DROP COLUMN IF EXISTS author;

-- STEP 3: DB-W2 — Drop dead column tooks.content
-- Data migrated to tooks.chapter_count in audit_fixes_v1; column no longer used
ALTER TABLE tooks DROP COLUMN IF EXISTS content;

-- STEP 4: DB-S2 — Migrate took_count/chapter_count TEXT → INTEGER
-- Add new integer columns, migrate data, drop old text columns
ALTER TABLE books ADD COLUMN IF NOT EXISTS took_count_int INTEGER DEFAULT 0;
UPDATE books SET took_count_int = NULLIF(took_count, '')::INTEGER WHERE took_count IS NOT NULL AND took_count != '';
ALTER TABLE books DROP COLUMN IF EXISTS took_count;
ALTER TABLE books RENAME COLUMN took_count_int TO took_count;

ALTER TABLE books ADD COLUMN IF NOT EXISTS chapter_count_int INTEGER DEFAULT 0;
UPDATE books SET chapter_count_int = NULLIF(chapter_count, '')::INTEGER WHERE chapter_count IS NOT NULL AND chapter_count != '';
ALTER TABLE books DROP COLUMN IF EXISTS chapter_count;
ALTER TABLE books RENAME COLUMN chapter_count_int TO chapter_count;

ALTER TABLE tooks ADD COLUMN IF NOT EXISTS chapter_count_int INTEGER DEFAULT 0;
UPDATE tooks SET chapter_count_int = NULLIF(chapter_count, '')::INTEGER WHERE chapter_count IS NOT NULL AND chapter_count != '';
ALTER TABLE tooks DROP COLUMN IF EXISTS chapter_count;
ALTER TABLE tooks RENAME COLUMN chapter_count_int TO chapter_count;

-- STEP 5: DB-S3 — Add missing indexes for query performance
CREATE INDEX IF NOT EXISTS idx_books_visible ON books(is_visible) WHERE is_visible = TRUE;
CREATE INDEX IF NOT EXISTS idx_books_scan_own ON books(created_by) WHERE created_by IS NOT NULL;

-- STEP 6: DB-C2 — Fix books_labels.book_id type mismatch (BIGINT → INTEGER)
-- Recreate FK with matching type
ALTER TABLE books_labels DROP CONSTRAINT IF EXISTS books_labels_book_id_fkey;
ALTER TABLE books_labels ALTER COLUMN book_id TYPE INTEGER USING book_id::INTEGER;
ALTER TABLE books_labels ADD CONSTRAINT books_labels_book_id_fkey
  FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE;

-- ============================================================
-- ROLLBACK (reverse order):
--   DROP INDEX IF EXISTS idx_books_scan_own;
--   DROP INDEX IF EXISTS idx_books_visible;
--   ALTER TABLE tooks ADD COLUMN content TEXT DEFAULT '';
--   UPDATE tooks SET content = chapter_count::TEXT WHERE chapter_count IS NOT NULL;
--   ALTER TABLE books ADD COLUMN author TEXT DEFAULT '';
--   DROP FUNCTION IF EXISTS public.is_admin_or_scan();
-- ============================================================
