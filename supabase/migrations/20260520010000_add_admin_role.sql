-- Add admin editorial role
-- 1. Update profiles CHECK constraint
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check CHECK (role IN ('user', 'scan', 'admin'));

-- 2. Create is_admin() helper
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
STABLE
AS $$
  SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin');
$$;

-- 3. Add is_visible column to books (default TRUE so existing books remain visible)
ALTER TABLE books ADD COLUMN IF NOT EXISTS is_visible BOOLEAN NOT NULL DEFAULT TRUE;

-- 4. Drop old public SELECT policy on books
DROP POLICY IF EXISTS "Enable read for all users" ON books;

-- 5. Create 3 SELECT policies on books
-- Admin: see all books
DROP POLICY IF EXISTS "Admin can read all books" ON books;
CREATE POLICY "Admin can read all books"
  ON books FOR SELECT
  USING (public.is_admin());

-- Scan: see all books (same as before, but explicit)
DROP POLICY IF EXISTS "Scan can read all books" ON books;
CREATE POLICY "Scan can read all books"
  ON books FOR SELECT
  USING (public.is_scan());

-- Regular users: only visible books
CREATE POLICY "Enable read for all users"
  ON books FOR SELECT
  USING (is_visible = TRUE);

-- 6. Admin can read all profiles
DROP POLICY IF EXISTS "Admin can read all profiles" ON profiles;
CREATE POLICY "Admin can read all profiles"
  ON profiles FOR SELECT
  USING (public.is_admin());
