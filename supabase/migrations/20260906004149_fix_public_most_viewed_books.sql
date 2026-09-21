-- =============================================================================
-- FIX: Home de lectores rota + limpieza de get_most_viewed_books obsoleta
-- Fecha: 2026-09-05
-- Problemas:
--   1. 20260727000003 puso IF NOT is_admin() en get_most_viewed_books, rompiendo
--      la home de "Mas vistos" para lectores (users/scan) que usan ese RPC.
-- Fix:
--   1. Nuevo RPC publico get_most_viewed_books_public (para authenticated no-admin)
--      que devuelve solo libros visibles.
--   2. REVOKE EXECUTE de get_most_viewed_books (obsoleta; ya nadie la usa) sobre
--      authenticated.
--   NOTA: las funciones analytics (get_analytics_overview, get_views_trend,
--   get_top_books) NO se revocan de authenticated, alineado con la decision
--   2026-07-27 (#447/#448): el admin panel las invoca con la anon key (rol de DB
--   'authenticated'), asi que su proteccion es el role-check interno is_admin()
--   en el cuerpo. Revocar EXECUTE bloquea al admin legítimo antes del check.
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. RPC publico para la home de lectores: top N libros visibles por visitas.
--    SECURITY DEFINER con search_path='' (regla de la skill). No exige is_admin:
--    replica el query original de get_most_viewed_books pero filtrando
--    is_visible = true (los lectores no deben ver libros ocultos).
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.get_most_viewed_books_public(
  max_results INT DEFAULT 6
)
RETURNS TABLE(book_id INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path = ''
AS $$
BEGIN
  RETURN QUERY
  SELECT b.id
  FROM public.book_views bv
  JOIN public.books b ON b.id = bv.book_id
  WHERE b.is_visible = true
  GROUP BY b.id
  ORDER BY COUNT(*) DESC
  LIMIT max_results;
END;
$$;

-- Solo usuarios autenticados; nunca anon.
REVOKE EXECUTE ON FUNCTION public.get_most_viewed_books_public(INTEGER) FROM anon;
REVOKE EXECUTE ON FUNCTION public.get_most_viewed_books_public(INTEGER) FROM public;
GRANT EXECUTE ON FUNCTION public.get_most_viewed_books_public(INTEGER) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. REVOKE de get_most_viewed_books (obsoleta) de PUBLIC.
--    El codigo Dart ya usa get_most_viewed_books_public; by-design las 3
--    funciones analytics se mantienen para authenticated (ver header): el
--    dashboard del admin las invoca con la anon key y su unica proteccion
--    viable es is_admin() en el cuerpo. REVOKE FROM PUBLIC corta el acceso
--    anon; GRANT a authenticated mantiene el del dashboard.
-- ─────────────────────────────────────────────────────────────────────────────

REVOKE EXECUTE ON FUNCTION
  public.get_most_viewed_books(INTEGER)
FROM PUBLIC;
