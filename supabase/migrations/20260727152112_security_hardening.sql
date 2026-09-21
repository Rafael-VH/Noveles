-- =============================================================================
-- FASE 4 — MEDIUM: Hardening
-- Findings: DB-011, DB-012, DB-013, DB-015
-- Fecha: 2026-07-27
-- =============================================================================
-- 1. DB-011/012: search_path = '' en todas las funciones SECURITY DEFINER
-- 2. DB-013: Analytics functions — role check interno (admin-only)
-- 3. DB-015: Scan puede leer email de todos los usuarios (PII)
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. DB-011: Fix is_user() — única helper sin search_path
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.is_user()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = ''
AS $$
  SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'user');
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. DB-012: Fix search_path en funciones analytics + role check (DB-013)
--    Convertir a PL/pgSQL para soportar IF (role check)
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.get_views_trend(days_back INT DEFAULT 30)
RETURNS TABLE(view_date DATE, view_count BIGINT)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path = ''
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Insufficient privileges: admin role required';
  END IF;

  RETURN QUERY
  SELECT DATE(bv.viewed_at) as view_date, COUNT(*)::BIGINT as view_count
  FROM public.book_views bv
  WHERE bv.viewed_at >= NOW() - (days_back || ' days')::INTERVAL
  GROUP BY DATE(bv.viewed_at)
  ORDER BY view_date;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_top_books(limit_count INT DEFAULT 10)
RETURNS TABLE(book_id BIGINT, book_name TEXT, view_count BIGINT)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path = ''
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Insufficient privileges: admin role required';
  END IF;

  RETURN QUERY
  SELECT bv.book_id, b.name as book_name, COUNT(*)::BIGINT as view_count
  FROM public.book_views bv
  JOIN public.books b ON b.id = bv.book_id
  GROUP BY bv.book_id, b.name
  ORDER BY view_count DESC
  LIMIT limit_count;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_analytics_overview()
RETURNS TABLE(
  total_views BIGINT,
  views_today BIGINT,
  total_books BIGINT,
  visible_books BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path = ''
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Insufficient privileges: admin role required';
  END IF;

  RETURN QUERY
  SELECT
    (SELECT COUNT(*) FROM public.book_views)::BIGINT,
    (SELECT COUNT(*) FROM public.book_views WHERE DATE(viewed_at) = CURRENT_DATE)::BIGINT,
    (SELECT COUNT(*) FROM public.books)::BIGINT,
    (SELECT COUNT(*) FROM public.books WHERE is_visible = true)::BIGINT;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_most_viewed_books(
  max_results INT DEFAULT 6
)
RETURNS TABLE(book_id BIGINT)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path = ''
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Insufficient privileges: admin role required';
  END IF;

  RETURN QUERY
  SELECT b.id FROM public.book_views bv
  JOIN public.books b ON b.id = bv.book_id
  GROUP BY b.id
  ORDER BY COUNT(*) DESC
  LIMIT max_results;
END;
$$;

-- Fix update_label_rules_updated_at
CREATE OR REPLACE FUNCTION public.update_label_rules_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. DB-015: Restringir email PII
--    Scan solo puede ver su propio perfil completo (no el de otros).
-- ─────────────────────────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Scan can read all profiles" ON profiles;

CREATE POLICY "Scan can read own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (is_scan() AND id = auth.uid());
