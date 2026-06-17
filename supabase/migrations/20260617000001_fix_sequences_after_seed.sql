-- Fix SERIAL sequences after seed.sql inserted explicit IDs
-- Seed uses ON CONFLICT DO NOTHING with literal IDs, but the sequences
-- never advanced past their starting value (1). Any INSERT without an
-- explicit id tries nextval() which returns an already-used value,
-- causing: duplicate key value violates unique constraint 'tooks_pkey'
--
-- See also: 20260521200000_audit_plan_fixes.sql (genres was already fixed)

SELECT setval('authors_id_seq', COALESCE((SELECT MAX(id) FROM authors), 0) + 1);
SELECT setval('books_id_seq',   COALESCE((SELECT MAX(id) FROM books),   0) + 1);
SELECT setval('tooks_id_seq',   COALESCE((SELECT MAX(id) FROM tooks),   0) + 1);
SELECT setval('chapters_id_seq', COALESCE((SELECT MAX(id) FROM chapters), 0) + 1);
