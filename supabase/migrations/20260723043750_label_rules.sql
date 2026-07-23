-- Create label_rules table for automated label assignment
CREATE TABLE IF NOT EXISTS label_rules (
  id SERIAL PRIMARY KEY,
  label_id INTEGER NOT NULL REFERENCES labels(id) ON DELETE CASCADE,
  rule_type TEXT NOT NULL CHECK (rule_type IN ('new_release', 'most_read', 'most_popular', 'most_favorited')),
  params JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE label_rules ENABLE ROW LEVEL SECURITY;

-- Admins can manage rules
CREATE POLICY "Admins can manage label_rules"
  ON label_rules
  FOR ALL
  TO authenticated
  USING ((SELECT is_admin(auth.uid())))
  WITH CHECK ((SELECT is_admin(auth.uid())));

-- Everyone can read rules (needed for display)
CREATE POLICY "Everyone can read label_rules"
  ON label_rules
  FOR SELECT
  TO authenticated
  USING (true);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_label_rules_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_label_rules_updated_at
  BEFORE UPDATE ON label_rules
  FOR EACH ROW
  EXECUTE FUNCTION update_label_rules_updated_at();
