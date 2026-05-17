-- Fix infinite recursion in profiles RLS policy.
-- The "Admin can read all profiles" policy used a subquery on profiles
-- that caused infinite recursion. Fix: use a SECURITY DEFINER function
-- that bypasses RLS for the admin check.

-- Helper function: checks if the current user is admin (bypasses RLS)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
STABLE
AS $$
  SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin');
$$;

-- Drop the recursive policy
DROP POLICY IF EXISTS "Admin can read all profiles" ON profiles;

-- Re-create using the security definer helper
CREATE POLICY "Admin can read all profiles"
  ON profiles FOR SELECT
  USING (public.is_admin());
