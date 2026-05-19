-- Fix scan RLS policies on books to restrict to own books
-- Before: scan could see/edit/delete ALL books
-- After: scan can only see/edit/delete books where created_by = auth.uid()

-- 1. SELECT: scan can only read own books
DROP POLICY IF EXISTS "Scan can read all books" ON books;
CREATE POLICY "Scan can read all books"
  ON books FOR SELECT
  USING (public.is_scan() AND created_by = auth.uid());

-- 2. UPDATE: scan can only update own books
DROP POLICY IF EXISTS "Enable update for scan only" ON books;
CREATE POLICY "Enable update for scan only"
  ON books FOR UPDATE
  USING (public.is_scan() AND created_by = auth.uid());

-- 3. DELETE: scan can only delete own books
DROP POLICY IF EXISTS "Enable delete for scan only" ON books;
CREATE POLICY "Enable delete for scan only"
  ON books FOR DELETE
  USING (public.is_scan() AND created_by = auth.uid());

-- 4. INSERT: scan must set created_by to their own ID
DROP POLICY IF EXISTS "Enable insert for scan only" ON books;
CREATE POLICY "Enable insert for scan only"
  ON books FOR INSERT
  WITH CHECK (public.is_scan() AND created_by = auth.uid());
