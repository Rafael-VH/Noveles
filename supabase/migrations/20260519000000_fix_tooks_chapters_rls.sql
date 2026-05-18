-- Fix RLS on tooks and chapters tables
-- Both tables have RLS enabled but NO SELECT policy,
-- causing tooks and chapters to never load for any user.

ALTER TABLE tooks ENABLE ROW LEVEL SECURITY;
ALTER TABLE chapters ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read for all users" ON tooks FOR SELECT USING (true);
CREATE POLICY "Enable read for all users" ON chapters FOR SELECT USING (true);
