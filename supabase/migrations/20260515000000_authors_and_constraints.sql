CREATE TABLE authors (
  id          SERIAL PRIMARY KEY,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  name        TEXT NOT NULL,
  description TEXT DEFAULT ''
);

INSERT INTO authors (name)
SELECT DISTINCT TRIM(author) FROM books
WHERE author IS NOT NULL AND TRIM(author) != ''
ORDER BY 1;

ALTER TABLE books ADD COLUMN author_id INT REFERENCES authors(id);

UPDATE books SET author_id = a.id
FROM authors a
WHERE TRIM(books.author) = a.name;

ALTER TABLE books ALTER COLUMN author_id SET NOT NULL;

ALTER TABLE books RENAME COLUMN took TO took_count;
ALTER TABLE books RENAME COLUMN chapter TO chapter_count;

ALTER TABLE tooks ALTER COLUMN book_id SET NOT NULL;

ALTER TABLE chapters ALTER COLUMN took_id SET NOT NULL;
