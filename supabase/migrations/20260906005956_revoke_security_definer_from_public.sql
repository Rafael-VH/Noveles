-- =============================================================================
-- FIX: REVOKE real de EXECUTE (complementa 20260905020000/2026090501 0000)
-- Fecha: 2026-09-05
-- Problema: las funciones creadas sin GRANT externo heredan EXECUTE del rol
-- PUBLIC por defecto; REVOKE FROM anon o FROM authenticated no corta ese
-- acceso porque PUBLIC concede a todos. Por eso el linter seguia reportando
-- admin_suspend_user / analytics como ejecutables por anon.
-- Fix:
--   1. REVOKE EXECUTE ... FROM PUBLIC de las funciones admin y analytics.
--   2. GRANT EXECUTE ... TO authenticated para conservar el flujo del dashboard
--      (anon key -> rol de DB authenticated), con proteccion is_admin() interna.
--   3. get_most_viewed_books (obsoleta) queda sin grants: ni anon ni los del panel.
-- =============================================================================

REVOKE EXECUTE ON FUNCTION
  public.admin_suspend_user(UUID),
  public.admin_reactivate_user(UUID, TEXT),
  public.get_analytics_overview(),
  public.get_views_trend(INTEGER),
  public.get_top_books(INTEGER)
FROM PUBLIC;

GRANT EXECUTE ON FUNCTION
  public.admin_suspend_user(UUID),
  public.admin_reactivate_user(UUID, TEXT),
  public.get_analytics_overview(),
  public.get_views_trend(INTEGER),
  public.get_top_books(INTEGER)
TO authenticated;

REVOKE EXECUTE ON FUNCTION public.get_most_viewed_books(INTEGER) FROM PUBLIC;