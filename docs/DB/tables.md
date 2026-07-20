# Tables & Schema

> All 11 tables have RLS enabled.

## Entity Relationship

```
auth.users ──1:1──> profiles
    │
    ├──1:N──> books (created_by)
    │           ├──1:N──> books_genres ──> genres
    │           ├──1:N──> books_labels ──> labels
    │           ├──1:N──> tooks (book_id)
    │           │           └──1:N──> chapters (took_id)
    │           ├──1:N──> book_views (book_id)
    │           └──1:N──> user_favorites (book_id)
    │
    ├──1:N──> tooks (created_by)
    ├──1:N──> chapters (created_by)
    └──1:N──> user_favorites (user_id)
    
authors ──1:N──> books (author_id)
genres ──M:N──> books (via books_genres)
labels ──M:N──> books (via books_labels)
```

## Table: `profiles`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | UUID | NO | — | FK → auth.users(id), PK |
| `role` | TEXT | NO | `'user'` | CHECK: user/scan/admin/suspended |
| `created_at` | TIMESTAMPTZ | NO | `now()` | |
| `display_name` | TEXT | YES | — | |
| `bio` | TEXT | YES | — | |
| `avatar_url` | TEXT | YES | — | |

**RLS**: Users read/update own, Admin read/update all, Scan read all.

---

## Table: `books`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | INT | NO | nextval | PK |
| `created_at` | TIMESTAMPTZ | YES | `now()` | |
| `cover` | TEXT | NO | — | Storage URL |
| `name` | TEXT | NO | — | Book title |
| `short` | TEXT | YES | `''` | Short description |
| `alternative` | TEXT | YES | `''` | Alternative title |
| `description` | TEXT | YES | `''` | Full description |
| `country` | TEXT | YES | `''` | Country of origin |
| `state` | TEXT | YES | `''` | State/region |
| `type` | TEXT | YES | `''` | Book type |
| `release` | TEXT | YES | `''` | Release info |
| `source` | TEXT | YES | `''` | Source URL |
| `link` | TEXT | YES | `''` | External link |
| `is_favorite` | BOOL | YES | `false` | Legacy — use user_favorites |
| `author_id` | INT | NO | — | FK → authors(id) |
| `created_by` | UUID | YES | — | FK → auth.users(id) |
| `is_visible` | BOOL | NO | `true` | Visibility flag |
| `took_count` | INT | YES | `0` | Denormalized count |
| `chapter_count` | INT | YES | `0` | Denormalized count |

**RLS**: Admin full, Scan own (created_by), User visible only.

---

## Table: `authors`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | INT | NO | nextval | PK |
| `created_at` | TIMESTAMPTZ | YES | `now()` | |
| `name` | TEXT | NO | — | Author name |
| `description` | TEXT | YES | `''` | |

**RLS**: Read all, Insert/Update/Delete admin + scan.

---

## Table: `genres`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | INT | NO | identity | PK |
| `created_at` | TIMESTAMPTZ | YES | `now()` | |
| `name` | TEXT | NO | — | Genre name |
| `description` | TEXT | YES | `''` | |

**RLS**: Read all, Insert/Update/Delete admin + scan.

---

## Table: `labels`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | BIGINT | NO | identity | PK |
| `created_at` | TIMESTAMPTZ | NO | `now()` | |
| `name` | TEXT | NO | — | Label name |
| `color` | TEXT | NO | `'#71A202'` | Hex color |

**RLS**: Read all, Insert/Update/Delete scan + admin.

---

## Table: `books_genres` (M:N junction)

| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| `book_id` | INT | NO | FK → books(id) |
| `genre_id` | INT | NO | FK → genres(id) |

**PK**: (book_id, genre_id)
**RLS**: Read all, Insert/Update/Delete admin + scan.

---

## Table: `books_labels` (M:N junction)

| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| `book_id` | INT | NO | FK → books(id) |
| `label_id` | BIGINT | NO | FK → labels(id) |

**PK**: (book_id, label_id)
**RLS**: Read all, Insert/Update/Delete scan + admin.

---

## Table: `tooks`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | INT | NO | nextval | PK |
| `created_at` | TIMESTAMPTZ | YES | `now()` | |
| `book_id` | INT | NO | — | FK → books(id) |
| `cover` | TEXT | YES | `''` | Storage URL |
| `number` | TEXT | YES | `''` | Took number |
| `title` | TEXT | YES | `''` | Took title |
| `created_by` | UUID | YES | — | FK → auth.users(id) |
| `chapter_count` | INT | YES | `0` | Denormalized count |

**RLS**: Read all, Insert/Update/Delete admin + scan (own).

---

## Table: `chapters`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | INT | NO | nextval | PK |
| `created_at` | TIMESTAMPTZ | YES | `now()` | |
| `took_id` | INT | NO | — | FK → tooks(id) |
| `number` | TEXT | YES | `''` | Chapter number |
| `title` | TEXT | YES | `''` | Chapter title |
| `content` | TEXT | YES | `''` | Chapter content |
| `created_by` | UUID | YES | — | FK → auth.users(id) |

**RLS**: Read all, Insert/Update/Delete admin + scan (own).

---

## Table: `book_views`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | BIGINT | NO | identity | PK |
| `book_id` | BIGINT | NO | — | FK → books(id) CASCADE |
| `viewed_at` | TIMESTAMPTZ | NO | `now()` | |
| `user_id` | UUID | YES | — | FK → auth.users(id) SET NULL |

**RLS**: Insert any authenticated, Select admin only.

---

## Table: `user_favorites`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `user_id` | UUID | NO | — | FK → auth.users(id) CASCADE |
| `book_id` | INT | NO | — | FK → books(id) CASCADE |
| `created_at` | TIMESTAMPTZ | NO | `now()` | |

**PK**: (user_id, book_id)
**RLS**: Select/Insert/Delete own only (auth.uid() = user_id).
