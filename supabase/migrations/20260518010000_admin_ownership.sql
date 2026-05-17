-- Asociar novelas con la cuenta admin (c63c361c-6bc7-4b66-9aac-157e8999271c)
-- para que el usuario regular pueda ver el contenido cargado por el admin

-- 1. Agregar columna created_by en books, tooks, chapters
ALTER TABLE books
  ADD COLUMN created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE tooks
  ADD COLUMN created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE chapters
  ADD COLUMN created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL;

-- 2. Asignar las novelas existentes a la cuenta admin
UPDATE books SET created_by = 'c63c361c-6bc7-4b66-9aac-157e8999271c' WHERE created_by IS NULL;
UPDATE tooks SET created_by = 'c63c361c-6bc7-4b66-9aac-157e8999271c' WHERE created_by IS NULL;
UPDATE chapters SET created_by = 'c63c361c-6bc7-4b66-9aac-157e8999271c' WHERE created_by IS NULL;

-- 3. Limpiar políticas RLS duplicadas
-- Las políticas "Authenticated insert/update/delete" permiten a CUALQUIER usuario autenticado escribir,
-- anulando las políticas "Enable ... for admin only". Las eliminamos.
DROP POLICY IF EXISTS "Authenticated delete" ON books;
DROP POLICY IF EXISTS "Authenticated insert" ON books;
DROP POLICY IF EXISTS "Authenticated update" ON books;

DROP POLICY IF EXISTS "Authenticated delete" ON books_genres;
DROP POLICY IF EXISTS "Authenticated insert" ON books_genres;
DROP POLICY IF EXISTS "Authenticated update" ON books_genres;

DROP POLICY IF EXISTS "Authenticated delete" ON chapters;
DROP POLICY IF EXISTS "Authenticated insert" ON chapters;
DROP POLICY IF EXISTS "Authenticated update" ON chapters;

DROP POLICY IF EXISTS "Authenticated delete" ON genres;
DROP POLICY IF EXISTS "Authenticated insert" ON genres;
DROP POLICY IF EXISTS "Authenticated update" ON genres;

DROP POLICY IF EXISTS "Authenticated delete" ON tooks;
DROP POLICY IF EXISTS "Authenticated insert" ON tooks;
DROP POLICY IF EXISTS "Authenticated update" ON tooks;

-- 4. Agregar política SELECT faltante en authors
-- La tabla authors tiene RLS activado pero sin política de lectura,
-- lo que hace que el INNER JOIN authors!inner(*) falle y excluya todos los libros
CREATE POLICY "Enable read for all users" ON authors
  FOR SELECT USING (true);

-- 5. Corregir created_by: asignar al admin real (rafaelvillahinojosa@gmail.com)
UPDATE books SET created_by = '4723bbc3-1ea8-4747-a3a0-604dd94783a5' WHERE created_by IS NOT NULL;
UPDATE tooks SET created_by = '4723bbc3-1ea8-4747-a3a0-604dd94783a5' WHERE created_by IS NOT NULL;
UPDATE chapters SET created_by = '4723bbc3-1ea8-4747-a3a0-604dd94783a5' WHERE created_by IS NOT NULL;
