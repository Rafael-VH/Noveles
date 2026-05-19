-- ============================================================
-- Audit Fixes — Consolidated Migration (Phase 1)
-- ============================================================
-- ORDER OF OPERATIONS (do NOT reorder):
--   1. Enable RLS on genres, books_genres (authors already has it)
--   2. Add SELECT policies for authenticated users
--   3. ADD COLUMN chapter_count to tooks, migrate data
--   4. Add missing FK indexes
--   5. Replace hardcoded UUIDs with dynamic subquery
--   6. Add admin write policies on all content tables
--   7. Re-create "Admin can read all books" SELECT policy
-- ============================================================

-- STEP 1: Enable RLS on tables missing it
-- (authors already has RLS enabled — verified in 20260518010000_admin_ownership.sql)
ALTER TABLE genres ENABLE ROW LEVEL SECURITY;
ALTER TABLE books_genres ENABLE ROW LEVEL SECURITY;

-- STEP 2: SELECT policies for authenticated users
-- genres: no SELECT policy existed
DROP POLICY IF EXISTS "Enable read for all users" ON genres;
CREATE POLICY "Enable read for all users" ON genres
  FOR SELECT USING (true);

-- books_genres: no SELECT policy existed
DROP POLICY IF EXISTS "Enable read for all users" ON books_genres;
CREATE POLICY "Enable read for all users" ON books_genres
  FOR SELECT USING (true);

-- authors: duplicate SELECT policies from 20260518010000 and 20260518020000
DROP POLICY IF EXISTS "Enable read for all users" ON authors;
CREATE POLICY "Enable read for all users" ON authors
  FOR SELECT USING (true);

-- STEP 3: Fix column semantics — add chapter_count to tooks, migrate from content
ALTER TABLE tooks ADD COLUMN IF NOT EXISTS chapter_count TEXT DEFAULT '';
UPDATE tooks SET chapter_count = content WHERE chapter_count = '' AND content != '';
-- Note: keep 'content' column for now (no data loss), new code maps chapter_count

-- STEP 4: Missing FK indexes for query performance
CREATE INDEX IF NOT EXISTS idx_tooks_book_id ON tooks(book_id);
CREATE INDEX IF NOT EXISTS idx_chapters_took_id ON chapters(took_id);
CREATE INDEX IF NOT EXISTS idx_books_author_id ON books(author_id);
CREATE INDEX IF NOT EXISTS idx_books_labels_book_id ON books_labels(book_id);
CREATE INDEX IF NOT EXISTS idx_books_labels_label_id ON books_labels(label_id);
CREATE INDEX IF NOT EXISTS idx_books_genres_book_id ON books_genres(book_id);
CREATE INDEX IF NOT EXISTS idx_books_genres_genre_id ON books_genres(genre_id);
CREATE INDEX IF NOT EXISTS idx_books_created_by ON books(created_by);

-- STEP 5: Replace hardcoded UUIDs with dynamic lookup
-- Looks up admin user by email with cascading fallbacks
DO $$
DECLARE
  admin_id UUID;
BEGIN
  -- Primary lookup: email matching the real admin user
  SELECT id INTO admin_id FROM auth.users WHERE email = 'rafaelvillahinojosa@gmail.com' LIMIT 1;

  -- Fallback 1: first user with scan role
  IF admin_id IS NULL THEN
    SELECT p.id INTO admin_id FROM public.profiles p
      JOIN auth.users u ON u.id = p.id
      WHERE p.role = 'scan'
      ORDER BY p.created_at ASC
      LIMIT 1;
  END IF;

  -- Fallback 2: first auth user
  IF admin_id IS NULL THEN
    SELECT id INTO admin_id FROM auth.users ORDER BY created_at ASC LIMIT 1;
  END IF;

  -- Apply the update to rows that still have NULL created_by
  IF admin_id IS NOT NULL THEN
    UPDATE books SET created_by = admin_id WHERE created_by IS NULL;
    UPDATE tooks SET created_by = admin_id WHERE created_by IS NULL;
    UPDATE chapters SET created_by = admin_id WHERE created_by IS NULL;
    RAISE NOTICE 'Updated created_by to %', admin_id;
  ELSE
    RAISE WARNING 'No admin user found — created_by left as NULL on orphaned rows';
  END IF;
END;
$$;

-- STEP 6: Admin write policies on all content tables using is_admin() helper
-- (is_admin() created in 20260520010000_add_admin_role.sql)
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN SELECT unnest(ARRAY['books', 'genres', 'tooks', 'chapters', 'books_genres', 'authors'])
  LOOP
    -- INSERT
    EXECUTE format(
      'DROP POLICY IF EXISTS "Enable insert for admin only" ON %I',
      tbl
    );
    EXECUTE format(
      'CREATE POLICY "Enable insert for admin only" ON %I FOR INSERT WITH CHECK (public.is_admin())',
      tbl
    );
    -- UPDATE
    EXECUTE format(
      'DROP POLICY IF EXISTS "Enable update for admin only" ON %I',
      tbl
    );
    EXECUTE format(
      'CREATE POLICY "Enable update for admin only" ON %I FOR UPDATE USING (public.is_admin())',
      tbl
    );
    -- DELETE
    EXECUTE format(
      'DROP POLICY IF EXISTS "Enable delete for admin only" ON %I',
      tbl
    );
    EXECUTE format(
      'CREATE POLICY "Enable delete for admin only" ON %I FOR DELETE USING (public.is_admin())',
      tbl
    );
  END LOOP;
END;
$$;

-- STEP 7: Admin can read all books (DROP and re-create for clean state)
-- Admin bypasses the created_by ownership and is_visible restrictions
DROP POLICY IF EXISTS "Admin can read all books" ON books;
CREATE POLICY "Admin can read all books"
  ON books FOR SELECT
  USING (public.is_admin());
