# SQL Functions

> All 9 functions are SECURITY DEFINER and run with owner privileges.

## Role Helper Functions

### `is_admin()`

```sql
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin');
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```

**Purpose**: Check if current user has admin role.
**Used in**: RLS policies for books, authors, genres, tooks, chapters, profiles.

---

### `is_scan()`

```sql
CREATE OR REPLACE FUNCTION public.is_scan()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'scan');
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```

**Purpose**: Check if current user has scan role.
**Used in**: RLS policies for books, authors, genres, tooks, chapters, labels.

---

### `is_user()`

```sql
CREATE OR REPLACE FUNCTION public.is_user()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'user');
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```

**Purpose**: Check if current user has user role.
**Used in**: App-level role validation, RLS for user_favorites.

---

### `is_admin_or_scan()`

```sql
CREATE OR REPLACE FUNCTION public.is_admin_or_scan()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'scan'));
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```

**Purpose**: Check if current user is admin or scan.
**Used in**: Combined role checks.

---

## Auth Functions

### `handle_new_user()`

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, role)
  VALUES (NEW.id, 'user');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Purpose**: Auto-create profile when user signs up.
**Trigger**: `auth.users` AFTER INSERT.

---

### `rls_auto_enable()`

```sql
CREATE OR REPLACE FUNCTION public.rls_auto_enable()
RETURNS TRIGGER AS $$
BEGIN
  EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', TG_TABLE_NAME);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Purpose**: Auto-enable RLS on new tables.
**Trigger**: Not actively used.

---

## Analytics Functions

### `get_views_trend(days_back INT DEFAULT 30)`

```sql
CREATE OR REPLACE FUNCTION public.get_views_trend(days_back INT DEFAULT 30)
RETURNS TABLE(view_date DATE, view_count BIGINT)
LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT DATE(viewed_at) as view_date, COUNT(*) as view_count
  FROM book_views
  WHERE viewed_at >= NOW() - (days_back || ' days')::INTERVAL
  GROUP BY DATE(viewed_at)
  ORDER BY view_date;
$$;
```

**Purpose**: Get daily view counts for the last N days.
**Returns**: `view_date` (DATE), `view_count` (BIGINT)
**Used by**: `AdminAnalyticsBloc` for views trend chart.

---

### `get_top_books(limit_count INT DEFAULT 10)`

```sql
CREATE OR REPLACE FUNCTION public.get_top_books(limit_count INT DEFAULT 10)
RETURNS TABLE(book_id BIGINT, book_name TEXT, view_count BIGINT)
LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT bv.book_id, b.name as book_name, COUNT(*) as view_count
  FROM book_views bv
  JOIN books b ON b.id = bv.book_id
  GROUP BY bv.book_id, b.name
  ORDER BY view_count DESC
  LIMIT limit_count;
$$;
```

**Purpose**: Get top N books by view count.
**Returns**: `book_id`, `book_name`, `view_count`
**Used by**: `AdminAnalyticsBloc` for top books list.

---

### `get_analytics_overview()`

```sql
CREATE OR REPLACE FUNCTION public.get_analytics_overview()
RETURNS TABLE(
  total_views BIGINT,
  views_today BIGINT,
  total_books BIGINT,
  visible_books BIGINT
)
LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT
    (SELECT COUNT(*) FROM book_views) as total_views,
    (SELECT COUNT(*) FROM book_views WHERE DATE(viewed_at) = CURRENT_DATE) as views_today,
    (SELECT COUNT(*) FROM books) as total_books,
    (SELECT COUNT(*) FROM books WHERE is_visible = true) as visible_books;
$$;
```

**Purpose**: Get overview metrics for admin dashboard.
**Returns**: `total_views`, `views_today`, `total_books`, `visible_books`
**Used by**: `AdminAnalyticsBloc` for dashboard summary.

---

## Function Security Notes

- All functions use `SECURITY DEFINER` — they run with the function owner's
  privileges, not the caller's
- This is necessary because RLS policies would otherwise block the queries
  inside the functions
- `STABLE` functions are optimized for caching within a transaction
- Analytics functions are read-only (SELECT only) — safe for any role to call
