-- Analytics functions for admin dashboard

-- Views per day for the last N days
CREATE OR REPLACE FUNCTION public.get_views_trend(days_back INT DEFAULT 30)
RETURNS TABLE(view_date DATE, view_count BIGINT)
LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT DATE(viewed_at) as view_date, COUNT(*) as view_count
  FROM book_views
  WHERE viewed_at >= NOW() - (days_back || ' days')::INTERVAL
  GROUP BY DATE(viewed_at)
  ORDER BY view_date;
$$;

-- Top books by views
CREATE OR REPLACE FUNCTION public.get_top_books(limit_count INT DEFAULT 10)
RETURNS TABLE(book_id BIGINT, book_name TEXT, view_count BIGINT)
LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT bv.book_id, b.name as book_name, COUNT(*) as view_count
  FROM book_views bv
  JOIN books b ON b.id = bv.book_id
  GROUP BY bv.book_id, b.name
  ORDER BY view_count DESC
  LIMIT limit_count;
$$;

-- Overview stats
CREATE OR REPLACE FUNCTION public.get_analytics_overview()
RETURNS TABLE(
  total_views BIGINT,
  views_today BIGINT,
  total_books BIGINT,
  visible_books BIGINT
)
LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT
    (SELECT COUNT(*) FROM book_views) as total_views,
    (SELECT COUNT(*) FROM book_views WHERE DATE(viewed_at) = CURRENT_DATE) as views_today,
    (SELECT COUNT(*) FROM books) as total_books,
    (SELECT COUNT(*) FROM books WHERE is_visible = true) as visible_books;
$$;
