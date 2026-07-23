# Funciones SQL

> Las 11 funciones son SECURITY DEFINER y se ejecutan con privilegios del
> propietario.

## Funciones Auxiliares de Rol

### `is_admin()`

```sql
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin');
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```text

**Propósito**: Verificar si el usuario actual tiene rol de admin.
**Usada en**: Políticas RLS para books, authors, genres, tooks, chapters,
profiles.

---

### `is_scan()`

```sql
CREATE OR REPLACE FUNCTION public.is_scan()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'scan');
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```text

**Propósito**: Verificar si el usuario actual tiene rol de scan.
**Usada en**: Políticas RLS para books, authors, genres, tooks, chapters, labels.

---

### `is_user()`

```sql
CREATE OR REPLACE FUNCTION public.is_user()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'user');
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```text

**Propósito**: Verificar si el usuario actual tiene rol de user.
**Usada en**: Validación de rol a nivel de app, RLS para user_favorites.

---

## Funciones de Seguimiento de Vistas

### `get_user_recent_views(uid UUID, max_results INT DEFAULT 6)`

```sql
CREATE OR REPLACE FUNCTION public.get_user_recent_views(
  uid UUID,
  max_results INT DEFAULT 6
) RETURNS TABLE(book_id BIGINT)
  LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT b.id FROM book_views bv
  JOIN books b ON b.id = bv.book_id
  WHERE bv.user_id = uid
  ORDER BY bv.viewed_at DESC
  LIMIT max_results;
$$;
```

**Propósito**: Obtener los N IDs de libros vistos más recientemente por un
usuario.
**Retorna**: `book_id` (BIGINT)
**Llamada por**: `BookRepositoryImpl.getRecentViews()` mediante Supabase RPC.
**Por qué SECURITY DEFINER**: `book_views` RLS bloquea SELECT de usuarios — los
usuarios regulares pueden INSERT pero no SELECT. Esta función se ejecuta con
privilegios del propietario para sortear esa restricción.

---

### `get_most_viewed_books(max_results INT DEFAULT 6)`

```sql
CREATE OR REPLACE FUNCTION public.get_most_viewed_books(
  max_results INT DEFAULT 6
) RETURNS TABLE(book_id BIGINT)
  LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT b.id FROM book_views bv
  JOIN books b ON b.id = bv.book_id
  GROUP BY b.id
  ORDER BY COUNT(*) DESC
  LIMIT max_results;
$$;
```

**Propósito**: Obtener los N IDs de libros más vistos globalmente.
**Retorna**: `book_id` (BIGINT)
**Llamada por**: `BookRepositoryImpl.getMostViewedBooks()` mediante Supabase RPC.
**Por qué SECURITY DEFINER**: Misma razón — sortea RLS en `book_views` para
SELECT.

---

### `is_admin_or_scan()`

```sql
CREATE OR REPLACE FUNCTION public.is_admin_or_scan()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid() AND role IN ('admin', 'scan')
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```text

**Propósito**: Verificar si el usuario actual es admin o scan.
**Usada en**: Verificaciones de rol combinadas.

---

## Funciones de Autenticación

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
```text

**Propósito**: Auto-crear perfil cuando un usuario se registra.
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
```text

**Propósito**: Auto-habilitar RLS en tablas nuevas.
**Trigger**: No se usa activamente.

---

## Funciones de Analytics

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
```text

**Propósito**: Obtener conteos diarios de vistas de los últimos N días.
**Retorna**: `view_date` (DATE), `view_count` (BIGINT)
**Usada por**: `AdminAnalyticsBloc` para el gráfico de tendencia de vistas.

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
```text

**Propósito**: Obtener los N libros principales por cantidad de vistas.
**Retorna**: `book_id`, `book_name`, `view_count`
**Usada por**: `AdminAnalyticsBloc` para la lista de libros principales.

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
```text

**Propósito**: Obtener métricas de resumen para el panel de admin.
**Retorna**: `total_views`, `views_today`, `total_books`, `visible_books`
**Usada por**: `AdminAnalyticsBloc` para el resumen del panel.

---

## Notas de Seguridad de Funciones

- Todas las funciones usan `SECURITY DEFINER` — se ejecutan con los privilegios
  del propietario de la función, no del que llama
- Esto es necesario porque las políticas RLS de otro modo bloquearían las
  consultas dentro de las funciones
- Las funciones `STABLE` están optimizadas para caching dentro de una transacción
- Las funciones de analytics son de solo lectura (solo SELECT) — seguras para
  cualquier rol
- Las funciones de seguimiento de vistas (`get_user_recent_views`,
  `get_most_viewed_books`) sortean RLS en `book_views` — los usuarios pueden leer
  datos agregados de vistas sin acceso directo a la tabla
