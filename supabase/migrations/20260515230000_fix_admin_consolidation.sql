-- Fix admin consolidation: remove is_admin column and conflicting policies.
-- The existing role-based system (role = 'admin') is the single source of truth.

-- Drop conflicting policies created by 20260515210000_admin_roles.sql
DROP POLICY IF EXISTS "Admin insert books" ON books;
DROP POLICY IF EXISTS "Admin update books" ON books;
DROP POLICY IF EXISTS "Admin delete books" ON books;
DROP POLICY IF EXISTS "Admin insert tooks" ON tooks;
DROP POLICY IF EXISTS "Admin update tooks" ON tooks;
DROP POLICY IF EXISTS "Admin delete tooks" ON tooks;
DROP POLICY IF EXISTS "Admin insert chapters" ON chapters;
DROP POLICY IF EXISTS "Admin update chapters" ON chapters;
DROP POLICY IF EXISTS "Admin delete chapters" ON chapters;

-- Remove the unused is_admin column
ALTER TABLE profiles DROP COLUMN IF EXISTS is_admin;

-- Ensure existing role-based admin policies are in place
-- (these were created in 20260515161849_profiles_and_auth.sql)

-- Seed: promote your user to admin.
-- Run this in Supabase Dashboard SQL Editor after finding your user ID:
--   UPDATE profiles SET role = 'admin' WHERE id = '<your-auth-user-uuid>';
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM profiles WHERE role = 'admin') THEN
    RAISE NOTICE 'No admin user found. Run: UPDATE profiles SET role = ''admin'' WHERE id = ''<uuid>'';';
  END IF;
END;
$$;
