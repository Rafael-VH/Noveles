-- Add email column to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- Backfill emails from auth.users for existing profiles
UPDATE profiles p
SET email = u.email
FROM auth.users u
WHERE p.id = u.id AND p.email IS NULL;
