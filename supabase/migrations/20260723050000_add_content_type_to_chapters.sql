-- Add content_type column to chapters table
-- Values: 'inline' (chapter content is inline text) or 'storagePath' (content is a storage path)
-- Existing chapters default to 'storagePath' for backward compatibility

ALTER TABLE chapters
  ADD COLUMN IF NOT EXISTS content_type TEXT NOT NULL DEFAULT 'storagePath';
