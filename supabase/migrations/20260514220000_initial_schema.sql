CREATE TABLE genres (
  id          INT PRIMARY KEY,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  name        TEXT NOT NULL,
  description TEXT DEFAULT ''
);

CREATE TABLE books (
  id          SERIAL PRIMARY KEY,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  cover       TEXT NOT NULL,
  name        TEXT NOT NULL,
  short       TEXT DEFAULT '',
  alternative TEXT DEFAULT '',
  description TEXT DEFAULT '',
  author      TEXT DEFAULT '',
  country     TEXT DEFAULT '',
  state       TEXT DEFAULT '',
  type        TEXT DEFAULT '',
  release     TEXT DEFAULT '',
  took        TEXT DEFAULT '',
  chapter     TEXT DEFAULT '',
  source      TEXT DEFAULT '',
  link        TEXT DEFAULT '',
  is_favorite BOOLEAN DEFAULT FALSE
);

CREATE TABLE books_genres (
  book_id  INT REFERENCES books(id) ON DELETE CASCADE,
  genre_id INT REFERENCES genres(id) ON DELETE CASCADE,
  PRIMARY KEY (book_id, genre_id)
);

CREATE TABLE tooks (
  id         SERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  book_id    INT REFERENCES books(id) ON DELETE CASCADE,
  cover      TEXT DEFAULT '',
  number     TEXT DEFAULT '',
  title      TEXT DEFAULT '',
  content    TEXT DEFAULT ''
);

CREATE TABLE chapters (
  id         SERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  took_id    INT REFERENCES tooks(id) ON DELETE CASCADE,
  number     TEXT DEFAULT '',
  title      TEXT DEFAULT '',
  content    TEXT DEFAULT ''
);