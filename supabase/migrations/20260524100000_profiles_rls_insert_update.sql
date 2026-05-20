-- Add INSERT and UPDATE RLS policies for profiles table
-- The INSERT policy allows the app's fallback in _getProfile to create
-- a profile row when one doesn't exist (auth.users created before trigger).

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Admin can update profiles"
  ON profiles FOR UPDATE
  USING (public.is_admin());
