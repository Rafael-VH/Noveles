-- Fix 1: Agregar política SELECT faltante en authors
-- RLS está activado pero no hay política de lectura → inner join excluye todos los libros
DROP POLICY IF EXISTS "Enable read for all users" ON authors;
CREATE POLICY "Enable read for all users" ON authors
  FOR SELECT USING (true);

-- Fix 2: Corregir created_by al admin real (rafaelvillahinojosa@gmail.com)
UPDATE books SET created_by = '4723bbc3-1ea8-4747-a3a0-604dd94783a5' WHERE created_by IS NOT NULL;
UPDATE tooks SET created_by = '4723bbc3-1ea8-4747-a3a0-604dd94783a5' WHERE created_by IS NOT NULL;
UPDATE chapters SET created_by = '4723bbc3-1ea8-4747-a3a0-604dd94783a5' WHERE created_by IS NOT NULL;
