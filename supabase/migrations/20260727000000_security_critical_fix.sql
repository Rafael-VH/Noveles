-- =============================================================================
-- FASE 1 — CRITICAL: SECURITY DEFINER lockdown
-- Findings: DB-001, DB-002, DB-003
-- Fecha: 2026-07-27
-- =============================================================================
-- 1. DB-001: Revocar EXECUTE de SECURITY DEFINER functions para anon
-- 2. DB-002: Rewrite create_book_with_relations — role check + SET search_path
-- 3. DB-003: Rewrite update_book_with_relations — role check + own books for scan
-- =============================================================================

-- DB-001: Revocar EXECUTE de SECURITY DEFINER functions para anon
REVOKE EXECUTE ON FUNCTION
  public.create_book_with_relations(JSONB, INTEGER[], INTEGER[]),
  public.update_book_with_relations(JSONB, INTEGER[], INTEGER[]),
  public.get_analytics_overview(),
  public.get_views_trend(INTEGER),
  public.get_top_books(INTEGER),
  public.get_most_viewed_books(INTEGER),
  public.handle_new_user()
FROM anon;

-- DB-002: Rewrite create_book_with_relations — role check + SET search_path
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

-- DB-003: Rewrite update_book_with_relations — role check + own books for scan
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