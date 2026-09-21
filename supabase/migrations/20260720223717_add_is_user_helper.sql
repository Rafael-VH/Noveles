-- Add is_user() helper function for consistency with is_admin(), is_scan(), is_admin_or_scan()
-- Used in RLS policies (e.g., user_favorites table) and app-level role validation
CREATE OR REPLACE FUNCTION public.is_user()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'user');
$$ LANGUAGE sql SECURITY DEFINER STABLE;
