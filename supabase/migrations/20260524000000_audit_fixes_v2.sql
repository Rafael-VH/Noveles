-- Audit Fixes v2: RLS hardening, book_views improvements, authors RLS

-- 1. Enable RLS on authors table (was missing from migrations, only done manually)
ALTER TABLE public.authors ENABLE ROW LEVEL SECURITY;

-- 2. Fix scan RLS on tooks — add created_by = auth.uid() check
DROP POLICY IF EXISTS "Enable update for scan only" ON public.tooks;
DROP POLICY IF EXISTS "Enable delete for scan only" ON public.tooks;
DROP POLICY IF EXISTS "Enable insert for scan only" ON public.tooks;

CREATE POLICY "Enable insert for scan only" ON public.tooks
  FOR INSERT WITH CHECK (public.is_scan() AND created_by = auth.uid());

CREATE POLICY "Enable update for scan only" ON public.tooks
  FOR UPDATE USING (public.is_scan() AND created_by = auth.uid());

CREATE POLICY "Enable delete for scan only" ON public.tooks
  FOR DELETE USING (public.is_scan() AND created_by = auth.uid());

-- 3. Fix scan RLS on chapters — add created_by = auth.uid() check
DROP POLICY IF EXISTS "Enable update for scan only" ON public.chapters;
DROP POLICY IF EXISTS "Enable delete for scan only" ON public.chapters;
DROP POLICY IF EXISTS "Enable insert for scan only" ON public.chapters;

CREATE POLICY "Enable insert for scan only" ON public.chapters
  FOR INSERT WITH CHECK (public.is_scan() AND created_by = auth.uid());

CREATE POLICY "Enable update for scan only" ON public.chapters
  FOR UPDATE USING (public.is_scan() AND created_by = auth.uid());

CREATE POLICY "Enable delete for scan only" ON public.chapters
  FOR DELETE USING (public.is_scan() AND created_by = auth.uid());

-- 4. Fix book_views RLS — allow authenticated users to insert, not just admin
DROP POLICY IF EXISTS "Admin can insert book views" ON public.book_views;

CREATE POLICY "Users can insert book views"
  ON public.book_views FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- 5. Add user_id to book_views for deduplication
ALTER TABLE public.book_views
  ADD COLUMN IF NOT EXISTS user_id UUID
  REFERENCES auth.users(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_book_views_user_id ON public.book_views(user_id);

-- 6. Update seed books created_by if admin user exists (safe no-op otherwise)
UPDATE books SET created_by = (SELECT id FROM auth.users WHERE email = 'admin@noveles.com')
WHERE created_by IS NULL;

UPDATE tooks SET created_by = (SELECT id FROM auth.users WHERE email = 'admin@noveles.com')
WHERE created_by IS NULL;

UPDATE chapters SET created_by = (SELECT id FROM auth.users WHERE email = 'admin@noveles.com')
WHERE created_by IS NULL;
