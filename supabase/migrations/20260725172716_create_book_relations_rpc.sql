-- Atomic book creation with author upsert, genres, and labels
-- Replaces the non-atomic sequential operations in book_repository_impl.dart
CREATE OR REPLACE FUNCTION create_book_with_relations(
  p_book JSONB,
  p_genre_ids INTEGER[],
  p_label_ids INTEGER[]
) RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_author_id INTEGER;
  v_book_id INTEGER;
  v_author_name TEXT;
BEGIN
  -- 1. Upsert author
  v_author_name := p_book->>'author';
  v_author_id := (p_book->>'author_id')::INTEGER;

  IF v_author_id = 0 AND v_author_name IS NOT NULL AND v_author_name != '' THEN
    -- Try to find existing author
    SELECT id INTO v_author_id FROM authors WHERE name = v_author_name;
    -- Create if not found
    IF v_author_id IS NULL THEN
      INSERT INTO authors (name) VALUES (v_author_name) RETURNING id INTO v_author_id;
    END IF;
  END IF;

  -- 2. Insert book
  INSERT INTO books (
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
    INSERT INTO books_genres (book_id, genre_id)
    SELECT v_book_id, unnest(p_genre_ids);
  END IF;

  -- 4. Insert labels
  IF p_label_ids IS NOT NULL AND array_length(p_label_ids, 1) > 0 THEN
    INSERT INTO books_labels (book_id, label_id)
    SELECT v_book_id, unnest(p_label_ids);
  END IF;

  RETURN v_book_id;
END;
$$;

-- Atomic book update with genres and labels replacement
-- Replaces the non-atomic delete+insert pattern in book_repository_impl.dart
CREATE OR REPLACE FUNCTION update_book_with_relations(
  p_book JSONB,
  p_genre_ids INTEGER[],
  p_label_ids INTEGER[]
) RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_book_id INTEGER;
BEGIN
  v_book_id := (p_book->>'id')::INTEGER;

  -- 1. Update book
  UPDATE books SET
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

  -- 2. Replace genres (delete old + insert new)
  DELETE FROM books_genres WHERE book_id = v_book_id;
  IF p_genre_ids IS NOT NULL AND array_length(p_genre_ids, 1) > 0 THEN
    INSERT INTO books_genres (book_id, genre_id)
    SELECT v_book_id, unnest(p_genre_ids);
  END IF;

  -- 3. Replace labels (delete old + insert new)
  DELETE FROM books_labels WHERE book_id = v_book_id;
  IF p_label_ids IS NOT NULL AND array_length(p_label_ids, 1) > 0 THEN
    INSERT INTO books_labels (book_id, label_id)
    SELECT v_book_id, unnest(p_label_ids);
  END IF;
END;
$$;
