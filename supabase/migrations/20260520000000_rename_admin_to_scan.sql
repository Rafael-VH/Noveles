-- Rename admin role to scan (scalation/translation group)
-- Step 1: Update CHECK constraint
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check CHECK (role IN ('user', 'scan'));

-- Step 2: Create is_scan() helper (replaces is_admin())
DROP FUNCTION IF EXISTS public.is_admin() CASCADE;
CREATE OR REPLACE FUNCTION public.is_scan()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
STABLE
AS $$
  SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'scan');
$$;

-- Step 3: Update profiles RLS policy
DROP POLICY IF EXISTS "Admin can read all profiles" ON profiles;
DROP POLICY IF EXISTS "Scan can read all profiles" ON profiles;
CREATE POLICY "Scan can read all profiles"
  ON profiles FOR SELECT
  USING (public.is_scan());

-- Step 4: Promote existing admins to scan
UPDATE profiles SET role = 'scan' WHERE role = 'admin';

-- Step 5: Drop all old RLS policies with 'admin' in their name
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename IN ('books', 'genres', 'tooks', 'chapters', 'books_genres', 'authors')
      AND policyname LIKE '%admin%'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', pol.policyname, pol.schemaname, pol.tablename);
  END LOOP;
END;
$$;

-- Step 6: Drop old scan policies (idempotent safe)
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN SELECT unnest(ARRAY['books', 'genres', 'tooks', 'chapters', 'books_genres', 'authors'])
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS "Enable insert for scan only" ON %I', tbl);
    EXECUTE format('DROP POLICY IF EXISTS "Enable update for scan only" ON %I', tbl);
    EXECUTE format('DROP POLICY IF EXISTS "Enable delete for scan only" ON %I', tbl);
  END LOOP;
END;
$$;

-- Step 7: Recreate all write policies with 'scan' role
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN SELECT unnest(ARRAY['books', 'genres', 'tooks', 'chapters', 'books_genres', 'authors'])
  LOOP
    EXECUTE format(
      'CREATE POLICY "Enable insert for scan only" ON %I FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = ''scan''))',
      tbl
    );
    EXECUTE format(
      'CREATE POLICY "Enable update for scan only" ON %I FOR UPDATE USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = ''scan''))',
      tbl
    );
    EXECUTE format(
      'CREATE POLICY "Enable delete for scan only" ON %I FOR DELETE USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = ''scan''))',
      tbl
    );
  END LOOP;
END;
$$;
