-- Admin roles: add is_admin to profiles and RLS policies for admin write access

-- Add is_admin column to profiles
ALTER TABLE profiles ADD COLUMN is_admin BOOLEAN DEFAULT FALSE;

-- RLS policies for admin write on books
CREATE POLICY "Admin insert books"
  ON books FOR INSERT
  WITH CHECK (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = TRUE)
  );

CREATE POLICY "Admin update books"
  ON books FOR UPDATE
  USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = TRUE)
  );

CREATE POLICY "Admin delete books"
  ON books FOR DELETE
  USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = TRUE)
  );

-- RLS policies for admin write on tooks
CREATE POLICY "Admin insert tooks"
  ON tooks FOR INSERT
  WITH CHECK (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = TRUE)
  );

CREATE POLICY "Admin update tooks"
  ON tooks FOR UPDATE
  USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = TRUE)
  );

CREATE POLICY "Admin delete tooks"
  ON tooks FOR DELETE
  USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = TRUE)
  );

-- RLS policies for admin write on chapters
CREATE POLICY "Admin insert chapters"
  ON chapters FOR INSERT
  WITH CHECK (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = TRUE)
  );

CREATE POLICY "Admin update chapters"
  ON chapters FOR UPDATE
  USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = TRUE)
  );

CREATE POLICY "Admin delete chapters"
  ON chapters FOR DELETE
  USING (
    auth.uid() IN (SELECT id FROM profiles WHERE is_admin = TRUE)
  );

-- Enable RLS on tables (safe to run multiple times)
ALTER TABLE books ENABLE ROW LEVEL SECURITY;
ALTER TABLE tooks ENABLE ROW LEVEL SECURITY;
ALTER TABLE chapters ENABLE ROW LEVEL SECURITY;
