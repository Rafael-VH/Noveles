-- Add 'suspended' as a valid role for user suspension
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('user', 'scan', 'admin', 'suspended'));
