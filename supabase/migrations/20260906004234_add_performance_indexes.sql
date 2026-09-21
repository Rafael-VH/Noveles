-- =============================================================================
-- FIX: Indices de performance (ALTO)
-- Fecha: 2026-09-05
-- Reglas violadas (supabase-postgres-best-practices):
--   - query-composite-indexes: faltan indices compuestos para queries de la home
--     y de analytics (book_views, books ordenado por is_visible+id).
--   - schema-foreign-key-indexes: chapter_reads.chapter_id sin indice; el
--     CASCade/SET NULL de auth.users -> book_views.user_id y chapter_reads.user_id
--     hace scan de tabla al borrar un usuario.
-- =============================================================================

-- Home "Mas vistos" / recientes: agrega por (book_id, viewed_at DESC).
CREATE INDEX IF NOT EXISTS idx_book_views_book_viewed
  ON public.book_views (book_id, viewed_at DESC);

-- "Continuar leyendo" / recientes por usuario: (user_id, viewed_at DESC).
CREATE INDEX IF NOT EXISTS idx_book_views_user_viewed
  ON public.book_views (user_id, viewed_at DESC);

-- FK de chapter_reads -> chapters(id) (borrado de capitulos / reportes).
CREATE INDEX IF NOT EXISTS idx_chapter_reads_chapter_id
  ON public.chapter_reads (chapter_id);

-- FK de chapter_reads -> profiles(id) (borrado de usuarios).
CREATE INDEX IF NOT EXISTS idx_chapter_reads_user_id
  ON public.chapter_reads (user_id);

-- Home paginada: feed ordenado por id filtrando visibles.
CREATE INDEX IF NOT EXISTS idx_books_visible_id
  ON public.books (is_visible, id);

-- FK tooks.created_by -> profiles(id) (borrado de scans).
CREATE INDEX IF NOT EXISTS idx_tooks_created_by
  ON public.tooks (created_by);

-- FK books_labels.label_id (las queries de labels -> libros).
CREATE INDEX IF NOT EXISTS idx_books_labels_label_id
  ON public.books_labels (label_id);
