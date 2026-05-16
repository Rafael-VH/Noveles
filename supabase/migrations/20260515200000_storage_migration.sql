-- Storage migration: migrate covers and chapters from local assets to Supabase Storage

-- RLS policies for covers bucket (public read, service_role write)
CREATE POLICY "Covers public read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'covers');

CREATE POLICY "Covers service_role all"
  ON storage.objects FOR ALL
  USING (
    bucket_id = 'covers'
    AND auth.role() = 'service_role'
  );

-- RLS policies for chapters bucket (public read, service_role write)
CREATE POLICY "Chapters public read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'chapters');

CREATE POLICY "Chapters service_role all"
  ON storage.objects FOR ALL
  USING (
    bucket_id = 'chapters'
    AND auth.role() = 'service_role'
  );

-- Update book cover paths: strip 'assets/cover/*/' prefix to just the filename
UPDATE books
SET cover = reverse(split_part(reverse(cover), '/', 1))
WHERE cover LIKE 'assets/cover/%';

-- Update chapter content paths: strip 'assets/book/' prefix to preserve subpath
UPDATE chapters
SET content = replace(content, 'assets/book/', '')
WHERE content LIKE 'assets/book/%';
