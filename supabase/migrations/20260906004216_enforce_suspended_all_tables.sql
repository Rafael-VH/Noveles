-- =============================================================================
-- FIX: Enforcement real del rol suspended (ALTO)
-- Fecha: 2026-09-05
-- Problemas:
--   1. Las policies RESTRICTIVE "Deny suspended users" (20260727000001) cubren
--      solo 6 tablas (books, tooks, chapters, user_favorites, chapter_reads,
--      book_views). Quedan expuestas: profiles, labels, books_labels,
--      books_genres, label_rules, authors, genres.
--   2. Suspender a un usuario no invalida su sesion (JWT vigente hasta 1 h).
-- Fix:
--   1. Extender RESTRICTIVE a las 7 tablas restantes.
--   2. Funcion admin_suspend_user (SECURITY DEFINER, exige is_admin) que setea
--      role='suspended' Y borra las sesiones activas del usuario (re-login
--      forzado). Tambien admin_reactivate_user para re-activar.
--   3. Chequeo is_suspended al inicio de las funciones SECURITY DEFINER de
--      negocio (create/update_book_with_relations), defensa en profundidad.
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. RESTRICTIVE "Deny suspended users" en las 7 tablas restantes.
--    Mismo patron que 20260727000001 (Postgres 15+).
-- ─────────────────────────────────────────────────────────────────────────────

DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN SELECT unnest(ARRAY[
    'profiles', 'labels', 'books_labels', 'books_genres',
    'label_rules', 'authors', 'genres'
  ])
  LOOP
    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE policyname = 'Deny suspended users'
        AND tablename = tbl
        AND schemaname = 'public'
    ) THEN
      EXECUTE format(
        'CREATE POLICY "Deny suspended users" ON %I AS RESTRICTIVE
         FOR ALL TO public
         USING (NOT public.is_suspended())',
        tbl
      );
    END IF;
  END LOOP;
END;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Funciones de administracion: suspender / reactivar con invalidacion de
--    sesion. SECURITY DEFINER, exigen is_admin().
--    auth.sessions pertenece al schema auth (privado): el owner de la base
--    (postgres, rol del definer) puede borrar sesiones de otros usuarios.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.admin_suspend_user(target_uid UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Insufficient privileges: admin role required';
  END IF;

  -- Marcar como suspendido.
  UPDATE public.profiles
  SET role = 'suspended'
  WHERE id = target_uid;

  -- Invalidar todas las sesiones activas: fuerza re-login inmediato.
  DELETE FROM auth.sessions WHERE user_id = target_uid;
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_reactivate_user(target_uid UUID, new_role TEXT DEFAULT 'user')
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Insufficient privileges: admin role required';
  END IF;

  IF new_role NOT IN ('user', 'scan', 'admin') THEN
    RAISE EXCEPTION 'Invalid target role: %', new_role;
  END IF;

  UPDATE public.profiles
  SET role = new_role
  WHERE id = target_uid;
END;
$$;

-- Los RPCs admin los invoca el admin panel con la anon key (rol de DB
-- 'authenticated'); por eso se mantienen para authenticated: su proteccion es el
-- check interno public.is_admin() en el cuerpo (decision 2026-07-27). Se
-- REVOKEa de PUBLIC (que concede a TODOS, incluido anon) y se re-grantea solo a
-- authenticated.
REVOKE EXECUTE ON FUNCTION
  public.admin_suspend_user(UUID),
  public.admin_reactivate_user(UUID, TEXT)
FROM PUBLIC;

GRANT EXECUTE ON FUNCTION
  public.admin_suspend_user(UUID),
  public.admin_reactivate_user(UUID, TEXT)
TO authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Defensa en profundidad: rechazar suspended dentro de las funciones
--    SECURITY DEFINER de negocio (las policies RESTRICTIVE no aplican dentro
--    de funciones definer). Los RPCs ya hacen role-check (admin/scan), pero un
--    scan suspendido con JWT vigente podria seguirlos usando; agregamos el
--    chequeo explicito.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.create_book_with_relations(
  p_book JSONB,
  p_genre_ids INTEGER[],
  p_label_ids INTEGER[]
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_author_id INTEGER;
  v_book_id INTEGER;
  v_author_name TEXT;
  v_role TEXT;
BEGIN
  -- Defensa en profundidad: suspended no opera.
  IF public.is_suspended() THEN
    RAISE EXCEPTION 'Insufficient privileges: account suspended';
  END IF;

  -- Role check: admin or scan
  SELECT role INTO v_role FROM public.profiles WHERE id = auth.uid();
  IF v_role IS NULL OR v_role NOT IN ('admin', 'scan') THEN
    RAISE EXCEPTION 'Insufficient privileges: admin or scan role required';
  END IF;

  -- Force created_by to authenticated user
  p_book := p_book || jsonb_build_object('created_by', auth.uid());

  -- 1. Upsert author
  v_author_name := p_book->>'author';
  v_author_id := (p_book->>'author_id')::INTEGER;

  IF v_author_id = 0 AND v_author_name IS NOT NULL AND v_author_name != '' THEN
    SELECT id INTO v_author_id FROM public.authors WHERE name = v_author_name;
    IF v_author_id IS NULL THEN
      INSERT INTO public.authors (name) VALUES (v_author_name) RETURNING id INTO v_author_id;
    END IF;
  END IF;

  -- 2. Insert book
  INSERT INTO public.books (
    created_at, cover, name, short, alternative, description,
    author_id, country, state, type, release, took_count,
    chapter_count, source, link, is_favorite, is_visible, created_by
  ) VALUES (
    (p_book->>'created_at')::TIMESTAMPTZ,
    p_book->>'cover',
    p_book->>'name',
    p_book->>'short',
    p_book->>'alternative',
    p_book->>'description',
    v_author_id,
    p_book->>'country',
    p_book->>'state',
    p_book->>'type',
    p_book->>'release',
    (p_book->>'took_count')::INTEGER,
    (p_book->>'chapter_count')::INTEGER,
    p_book->>'source',
    p_book->>'link',
    (p_book->>'is_favorite')::BOOLEAN,
    COALESCE((p_book->>'is_visible')::BOOLEAN, true),
    (p_book->>'created_by')::UUID
  ) RETURNING id INTO v_book_id;

  -- 3. Insert genres
  IF p_genre_ids IS NOT NULL AND array_length(p_genre_ids, 1) > 0 THEN
    INSERT INTO public.books_genres (book_id, genre_id)
    SELECT v_book_id, unnest(p_genre_ids);
  END IF;

  -- 4. Insert labels
  IF p_label_ids IS NOT NULL AND array_length(p_label_ids, 1) > 0 THEN
    INSERT INTO public.books_labels (book_id, label_id)
    SELECT v_book_id, unnest(p_label_ids);
  END IF;

  RETURN v_book_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_book_with_relations(
  p_book JSONB,
  p_genre_ids INTEGER[],
  p_label_ids INTEGER[]
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_book_id INTEGER;
  v_role TEXT;
  v_book_owner UUID;
BEGIN
  -- Defensa en profundidad: suspended no opera.
  IF public.is_suspended() THEN
    RAISE EXCEPTION 'Insufficient privileges: account suspended';
  END IF;

  -- Role check
  SELECT role INTO v_role FROM public.profiles WHERE id = auth.uid();
  IF v_role IS NULL OR v_role NOT IN ('admin', 'scan') THEN
    RAISE EXCEPTION 'Insufficient privileges: admin or scan role required';
  END IF;

  v_book_id := (p_book->>'id')::INTEGER;

  -- Scan can only update own books
  SELECT created_by INTO v_book_owner FROM public.books WHERE id = v_book_id;
  IF v_role = 'scan' AND v_book_owner != auth.uid() THEN
    RAISE EXCEPTION 'Scan users can only update their own books';
  END IF;

  -- 1. Update book
  UPDATE public.books SET
    cover = p_book->>'cover',
    name = p_book->>'name',
    short = p_book->>'short',
    alternative = p_book->>'alternative',
    description = p_book->>'description',
    author_id = (p_book->>'author_id')::INTEGER,
    country = p_book->>'country',
    state = p_book->>'state',
    type = p_book->>'type',
    release = p_book->>'release',
    took_count = (p_book->>'took_count')::INTEGER,
    chapter_count = (p_book->>'chapter_count')::INTEGER,
    source = p_book->>'source',
    link = p_book->>'link',
    is_favorite = (p_book->>'is_favorite')::BOOLEAN,
    is_visible = (p_book->>'is_visible')::BOOLEAN
  WHERE id = v_book_id;

  -- 2. Replace genres
  DELETE FROM public.books_genres WHERE book_id = v_book_id;
  IF p_genre_ids IS NOT NULL AND array_length(p_genre_ids, 1) > 0 THEN
    INSERT INTO public.books_genres (book_id, genre_id)
    SELECT v_book_id, unnest(p_genre_ids);
  END IF;

  -- 3. Replace labels
  DELETE FROM public.books_labels WHERE book_id = v_book_id;
  IF p_label_ids IS NOT NULL AND array_length(p_label_ids, 1) > 0 THEN
    INSERT INTO public.books_labels (book_id, label_id)
    SELECT v_book_id, unnest(p_label_ids);
  END IF;
END;
$$;

-- Los RPCs de negocio ya no deberian ser ejecutables por suspended: el chequeo
-- is_suspended() al inicio los protege aunque el JWT siga vigente.
