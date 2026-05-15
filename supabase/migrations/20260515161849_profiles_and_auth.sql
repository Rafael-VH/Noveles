-- ============================================================
-- Profiles: user roles for auth
-- ============================================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.profiles (id, role)
  VALUES (NEW.id, 'user');
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Admin can read all profiles"
  ON profiles FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ============================================================
-- Update RLS on books — only admin can write
-- ============================================================
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON books;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON books;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON books;

CREATE POLICY "Enable insert for admin only" ON books
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Enable update for admin only" ON books
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Enable delete for admin only" ON books
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ============================================================
-- Update RLS on genres — only admin can write
-- ============================================================
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON genres;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON genres;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON genres;

CREATE POLICY "Enable insert for admin only" ON genres
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Enable update for admin only" ON genres
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Enable delete for admin only" ON genres
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ============================================================
-- Update RLS on tooks — only admin can write
-- ============================================================
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON tooks;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON tooks;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON tooks;

CREATE POLICY "Enable insert for admin only" ON tooks
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Enable update for admin only" ON tooks
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Enable delete for admin only" ON tooks
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ============================================================
-- Update RLS on chapters — only admin can write
-- ============================================================
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON chapters;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON chapters;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON chapters;

CREATE POLICY "Enable insert for admin only" ON chapters
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Enable update for admin only" ON chapters
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Enable delete for admin only" ON chapters
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ============================================================
-- Update RLS on books_genres — only admin can write
-- ============================================================
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON books_genres;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON books_genres;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON books_genres;

CREATE POLICY "Enable insert for admin only" ON books_genres
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Enable update for admin only" ON books_genres
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Enable delete for admin only" ON books_genres
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );
