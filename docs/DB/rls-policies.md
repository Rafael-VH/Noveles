# RLS Policies

> Total: 63 policies across 11 tables.
> All policies use PERMISSIVE mode.
> Helper functions: `is_admin()`, `is_scan()`, `is_user()`, `is_admin_or_scan()`.

## Role Helper Functions

```sql
-- Used in RLS conditions
is_admin()      -- returns true if current user has role = 'admin'
is_scan()       -- returns true if current user has role = 'scan'
is_user()       -- returns true if current user has role = 'user'
is_admin_or_scan() -- returns true if admin OR scan
```

---

## profiles (6 policies)

| Operation | Policy Name | Role | Condition |
|-----------|-------------|------|-----------|
| SELECT | Admin can read all profiles | public | `is_admin()` |
| SELECT | Scan can read all profiles | public | `is_scan()` |
| SELECT | Users can read own profile | public | `auth.uid() = id` |
| INSERT | Users can insert own profile | public | `auth.uid() = id` |
| UPDATE | Admin can update profiles | public | `is_admin()` |
| UPDATE | Users can update own profile | public | `auth.uid() = id` |

**Notes**: Scan can read all profiles (needed for author display). Users cannot delete profiles.

---

## books (8 policies)

| Operation | Policy Name | Role | Condition |
|-----------|-------------|------|-----------|
| SELECT | Admin can read all books | public | `is_admin()` |
| SELECT | Scan can read all books | public | `is_scan() AND created_by = auth.uid()` |
| SELECT | Users can read visible books | public | `is_visible = true AND NOT is_scan()` |
| INSERT | Enable insert for admin only | public | `is_admin()` |
| INSERT | Enable insert for scan only | public | `is_scan() AND created_by = auth.uid()` |
| UPDATE | Enable update for admin only | public | `is_admin()` |
| UPDATE | Enable update for scan only | public | `is_scan() AND created_by = auth.uid()` |
| DELETE | Enable delete for admin only | public | `is_admin()` |
| DELETE | Enable delete for scan only | public | `is_scan() AND created_by = auth.uid()` |

**Notes**: Scan can only CRUD their own books. Users only see visible books.

---

## authors (7 policies)

| Operation | Policy Name | Role | Condition |
|-----------|-------------|------|-----------|
| SELECT | Enable read for all users | public | `true` |
| INSERT | Enable insert for admin only | public | `is_admin()` |
| INSERT | Enable insert for scan only | public | `is_scan()` |
| UPDATE | Enable update for admin only | public | `is_admin()` |
| UPDATE | Enable update for scan only | public | `is_scan()` |
| DELETE | Enable delete for admin only | public | `is_admin()` |
| DELETE | Enable delete for scan only | public | `is_scan()` |

**Notes**: Authors are shared resources — both admin and scan can create/edit.

---

## genres (7 policies)

| Operation | Policy Name | Role | Condition |
|-----------|-------------|------|-----------|
| SELECT | Enable read for all users | public | `true` |
| INSERT | Enable insert for admin only | public | `is_admin()` |
| INSERT | Enable insert for scan only | public | `is_scan()` |
| UPDATE | Enable update for admin only | public | `is_admin()` |
| UPDATE | Enable update for scan only | public | `is_scan()` |
| DELETE | Enable delete for admin only | public | `is_admin()` |
| DELETE | Enable delete for scan only | public | `is_scan()` |

**Notes**: Genres are shared resources — both admin and scan can create/edit.

---

## labels (4 policies)

| Operation | Policy Name | Role | Condition |
|-----------|-------------|------|-----------|
| SELECT | Enable read for all users | public | `true` |
| INSERT | Enable insert for scan and admin | public | `is_scan() OR is_admin()` |
| UPDATE | Enable update for scan and admin | public | `is_scan() OR is_admin()` |
| DELETE | Enable delete for scan and admin | public | `is_scan() OR is_admin()` |

**Notes**: Labels are shared — scan and admin can manage.

---

## books_genres (7 policies)

| Operation | Policy Name | Role | Condition |
|-----------|-------------|------|-----------|
| SELECT | Enable read for all users | public | `true` |
| INSERT | Enable insert for admin only | public | `is_admin()` |
| INSERT | Enable insert for scan only | public | `is_scan()` |
| UPDATE | Enable update for admin only | public | `is_admin()` |
| UPDATE | Enable update for scan only | public | `is_scan()` |
| DELETE | Enable delete for admin only | public | `is_admin()` |
| DELETE | Enable delete for scan only | public | `is_scan()` |

**Notes**: Junction table — follows same rules as genres.

---

## books_labels (3 policies)

| Operation | Policy Name | Role | Condition |
|-----------|-------------|------|-----------|
| SELECT | Enable read for all users | public | `true` |
| INSERT | Enable insert for scan and admin | public | `is_scan() OR is_admin()` |
| DELETE | Enable delete for scan and admin | public | `is_scan() OR is_admin()` |

**Notes**: Junction table — scan and admin can manage labels on books.

---

## tooks (8 policies)

| Operation | Policy Name | Role | Condition |
|-----------|-------------|------|-----------|
| SELECT | Enable read for all users | public | `true` |
| INSERT | Enable insert for admin only | public | `is_admin()` |
| INSERT | Enable insert for scan only | public | `is_scan() AND created_by = auth.uid()` |
| UPDATE | Enable update for admin only | public | `is_admin()` |
| UPDATE | Enable update for scan only | public | `is_scan() AND created_by = auth.uid()` |
| DELETE | Enable delete for admin only | public | `is_admin()` |
| DELETE | Enable delete for scan only | public | `is_scan() AND created_by = auth.uid()` |

**Notes**: Scan can only CRUD their own tooks.

---

## chapters (8 policies)

| Operation | Policy Name | Role | Condition |
|-----------|-------------|------|-----------|
| SELECT | Enable read for all users | public | `true` |
| INSERT | Enable insert for admin only | public | `is_admin()` |
| INSERT | Enable insert for scan only | public | `is_scan() AND created_by = auth.uid()` |
| UPDATE | Enable update for admin only | public | `is_admin()` |
| UPDATE | Enable update for scan only | public | `is_scan() AND created_by = auth.uid()` |
| DELETE | Enable delete for admin only | public | `is_admin()` |
| DELETE | Enable delete for scan only | public | `is_scan() AND created_by = auth.uid()` |

**Notes**: Scan can only CRUD their own chapters.

---

## book_views (2 policies)

| Operation | Policy Name                 | Role          | Condition |
| --------- | --------------------------- | ------------- | -----------|
| SELECT    | Admin can read book views   | authenticated | `is_admin()` |
| INSERT    | Users can insert book views | authenticated | `true`       |

**Notes**: Any authenticated user can track views. Only admin can read analytics.

---

## user_favorites (3 policies)

| Operation | Policy Name | Role | Condition |
|-----------|-------------|------|-----------|
| SELECT | Users can read own favorites | public | `auth.uid() = user_id` |
| INSERT | Users can insert own favorites | public | `auth.uid() = user_id` |
| DELETE | Users can delete own favorites | public | `auth.uid() = user_id` |

**Notes**: Each user can only see/manage their own favorites. No admin override.

---

## Storage Policies

### covers bucket

| Operation | Policy | Condition |
| --------- | ------ | --------- |
| INSERT | Covers: authenticated insert own folder | `bucket_id = 'covers' AND auth.role() = 'authenticated' AND (storage.foldername(name))[1] = auth.uid()::text` |
| UPDATE | Covers: authenticated update own folder | Same as INSERT |
| DELETE | Covers: authenticated delete own folder | Same as INSERT |

### chapters bucket

| Operation | Policy | Condition |
| --------- | ------ | --------- |
| INSERT | Chapters: authenticated insert own folder | `bucket_id = 'chapters' AND auth.role() = 'authenticated' AND (storage.foldername(name))[1] = auth.uid()::text` |
| UPDATE | Chapters: authenticated update own folder | Same as INSERT |
| DELETE | Chapters: authenticated delete own folder | Same as INSERT |

**Notes**: Storage is restricted to `{user_id}/` prefix. Public read access enabled on both buckets.

---

## Security Observations

### ✅ Strong

- RLS enabled on ALL tables
- SECURITY DEFINER functions prevent RLS bypass
- Content ownership enforced (`created_by = auth.uid()`)
- Favorites fully isolated per user
- Storage restricted to user folders

### ⚠️ Monitor

- `book_views` INSERT has no rate limiting (any authenticated user)
- `profiles` SELECT for scan shows all users (intentional for author display)
- Storage buckets are public (URLs are readable by anyone)
