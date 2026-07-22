-- Create chapter_reads table for tracking reading progress
CREATE TABLE IF NOT EXISTS chapter_reads (
  user_id UUID NOT NULL REFERENCES auth.users(id),
  chapter_id INTEGER NOT NULL REFERENCES chapters(id),
  read_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, chapter_id)
);

-- Enable RLS
ALTER TABLE chapter_reads ENABLE ROW LEVEL SECURITY;

-- RLS: users can only read their own reads
CREATE POLICY "Users can read own chapter reads"
  ON chapter_reads FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- RLS: users can only insert their own reads
CREATE POLICY "Users can insert own chapter reads"
  ON chapter_reads FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- SECURITY DEFINER: get user's recent viewed book IDs
CREATE OR REPLACE FUNCTION public.get_user_recent_views(
  uid UUID,
  max_results INT DEFAULT 6
) RETURNS TABLE(book_id BIGINT)
  LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT b.id FROM book_views bv
  JOIN books b ON b.id = bv.book_id
  WHERE bv.user_id = uid
  ORDER BY bv.viewed_at DESC
  LIMIT max_results;
$$;

-- SECURITY DEFINER: get most viewed book IDs globally
CREATE OR REPLACE FUNCTION public.get_most_viewed_books(
  max_results INT DEFAULT 6
) RETURNS TABLE(book_id BIGINT)
  LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT b.id FROM book_views bv
  JOIN books b ON b.id = bv.book_id
  GROUP BY b.id
  ORDER BY COUNT(*) DESC
  LIMIT max_results;
$$;
