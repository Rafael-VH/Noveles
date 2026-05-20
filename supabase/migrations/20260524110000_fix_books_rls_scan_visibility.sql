-- Fix: scan users should only see their own books, not all visible books.
-- The "Enable read for all users" policy applied to ALL users including scans,
-- so scan users saw every book with is_visible = true instead of only their own.

DROP POLICY IF EXISTS "Enable read for all users" ON books;

CREATE POLICY "Users can read visible books"
  ON books FOR SELECT
  USING (is_visible = true AND NOT is_scan());
