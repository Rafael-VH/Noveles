-- =============================================================================
-- FIX: Anti-escalacion de rol en profiles (CRITICO)
-- Fecha: 2026-09-05
-- Problema: la policy "Users can update own profile" permite a un usuario
-- hacer UPDATE profiles SET role='admin' WHERE id = auth.uid() (auto-escalacion
-- a admin, comprometiendo todo el modelo de autorizacion basado en profiles.role).
-- Fix: REVOKE por columna de role/id/email + trigger que impide cambiar el propio rol.
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. REVOKE UPDATE de columnas sensibles para el rol authenticated.
--    La policy "Users can update own profile" (USING auth.uid() = id) sigue
--    vigente para columnas de perfil (display_name, bio, avatar_url), pero el
--    usuario ya no puede modificar su role, su id ni su email.
-- ─────────────────────────────────────────────────────────────────────────────

REVOKE UPDATE (role, id, email) ON public.profiles FROM authenticated;

-- Tambien para anon (defensa en profundidad; anon no deberia tener UPDATE).
REVOKE UPDATE (role, id, email) ON public.profiles FROM anon;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Trigger que impide que un usuario cambie su propio rol (o el de otro no
--    admin) fuera de los canales administrativos. Los unicos cambios de rol
--    validos son:
--      a) Un admin modificando el rol de cualquier usuario (UPDATE via tabla,
--         la policy "Admin can update profiles" autoriza).
--      b) El trigger handle_new_user (creacion inicial, rol por defecto).
--      c) La funcion admin_suspend_user (SECURITY DEFINER, ejecutada por admin).
--    El trigger corre como SECURITY DEFINER (owner) y chequea is_admin() del
--    ejecutor real para permitir o rechazar.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.prevent_self_role_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- Si el rol no cambio, permitir (update de otras columnas).
  IF OLD.role IS NOT DISTINCT FROM NEW.role THEN
    RETURN NEW;
  END IF;

  -- Permitir solo si el ejecutor es admin.
  IF public.is_admin() THEN
    RETURN NEW;
  END IF;

  RAISE EXCEPTION 'No puedes cambiar tu propio rol';
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_self_role_change ON public.profiles;

CREATE TRIGGER trg_prevent_self_role_change
  BEFORE UPDATE OF role ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.prevent_self_role_change();
