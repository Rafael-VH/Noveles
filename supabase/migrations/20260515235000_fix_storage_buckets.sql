-- Fix Storage: create missing buckets, fix lossy cover paths, migrate tooks.cover

-- Create Storage buckets (idempotent)
INSERT INTO storage.buckets (id, name, public, avif_autodetection)
VALUES ('covers', 'covers', true, false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public, avif_autodetection)
VALUES ('chapters', 'chapters', true, false)
ON CONFLICT (id) DO NOTHING;

-- Fix lossy cover path: replace 'assets/cover/' prefix with '' (preserves subdir)
UPDATE books
SET cover = replace(cover, 'assets/cover/', '')
WHERE cover LIKE 'assets/cover/%';

-- Migrate tooks.cover (was missed in 20260515200000_storage_migration.sql)
UPDATE tooks
SET cover = replace(cover, 'assets/cover/', '')
WHERE cover LIKE 'assets/cover/%';
