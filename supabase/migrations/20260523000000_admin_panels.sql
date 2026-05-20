-- Create book_views table for analytics
CREATE TABLE IF NOT EXISTS public.book_views (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  book_id BIGINT NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
  viewed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for aggregation queries
CREATE INDEX IF NOT EXISTS idx_book_views_book_id ON public.book_views(book_id);
CREATE INDEX IF NOT EXISTS idx_book_views_viewed_at ON public.book_views(viewed_at);
CREATE INDEX IF NOT EXISTS idx_book_views_book_viewed_at ON public.book_views(book_id, viewed_at);

-- RLS: admin-only write, authenticated read
ALTER TABLE public.book_views ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin can insert book views"
  ON public.book_views FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin());

CREATE POLICY "Admin can read book views"
  ON public.book_views FOR SELECT
  TO authenticated
  USING (public.is_admin());
