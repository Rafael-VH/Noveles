# Plan de Mejoras — Usuario Regular (`role = 'user'`)

> Generado: 2026-07-20 | Basado en auditoría de 706 líneas
> Proyecto: NovelEs Flutter + Supabase

---

## Resumen Ejecutivo

El usuario regular (`role = 'user'`) tiene un flujo funcional core sólido: autenticación, catálogo, lectura inmersiva y perfil. Sin embargo, la auditoría reveló 3 problemas críticos, 4 issues medios y varias oportunidades de polish. El campo `isFavorite` existe en la DB y en `BookEntity` pero no tiene ninguna UI — es dead code que necesita ser activado o eliminado. Los campos `source`/`link` cargan datos pero `DetailView` los ignora. Falta un `isUser` getter que hace el routing frágil. Las variables de estilo en `ChapterScreen` son dead code de features no implementadas.

La prioridad inmediata es: (1) asegurar integridad de datos con `isUser` getter, (2) activar favoritos como feature completa, (3) mostrar links externos, y (4) limpiar dead code que contamina el lector.

---

## Tabla de Prioridades

| # | Item | Prioridad | Esfuerzo | Dependencias | Estado |
|---|------|-----------|----------|--------------|--------|
| 1 | Agregar `isUser` getter a `UserEntity` | P0 | S | Ninguna | 🔲 |
| 2 | Validar `role` en `UserModel.fromJson` | P0 | S | Ninguna | 🔲 |
| 3 | Guard de rol explícito en `app.dart` | P0 | S | #1 | 🔲 |
| 4 | Agregar RLS `is_user()` SQL helper | P0 | S | Ninguna | 🔲 |
| 5 | Feature completa de Favoritos | P1 | XL | #1 | 🔲 |
| 6 | Mostrar `source`/`link` en `DetailView` | P1 | M | Ninguna | 🔲 |
| 7 | Eliminar dead code en `ChapterScreen` | P1 | S | Ninguna | 🔲 |
| 8 | Pasar `isScan`/`isAdmin` reales al `AppDrawer` | P1 | S | Ninguna | 🔲 |
| 9 | Empty states para home y búsqueda vacía | P2 | M | Ninguna | 🔲 |
| 10 | Paginación / scroll infinito en home | P2 | L | Ninguna | 🔲 |
| 11 | Filtros de género interactivos en DetailView | P2 | S | Ninguna | 🔲 |
| 12 | Estadísticas de lectura persistentes | P3 | M | #5 | 🔲 |
| 13 | Tests unitarios BLoC de usuario regular | P3 | L | Ninguna | 🔲 |
| 14 | Widget tests para pantallas core | P3 | L | Ninguna | 🔲 |

---

## Fase 1: Seguridad e Integridad (P0)

### Item 1 — Agregar `isUser` getter a `UserEntity`

**Prioridad:** P0 | **Esfuerzo:** S (1-2h)

**Problema:** `UserEntity` tiene `isScan` (línea 20) e `isAdmin` (línea 21) pero NO tiene `isUser`. El routing en `app.dart` (líneas 54-62) llega al usuario regular solo por exclusión — si mañana se agrega un rol nuevo, se escapa de la lógica.

**Solución:**

```dart
// lib/features/profiles/domain/user_entity.dart — línea 22 (agregar después de isAdmin)
bool get isUser => role == 'user';
```

**Archivos afectados:**
- `lib/features/profiles/domain/user_entity.dart` — agregar getter (1 línea)

**Acceptance criteria:**
- [ ] `UserEntity(role: 'user', ...).isUser == true`
- [ ] `UserEntity(role: 'admin', ...).isUser == false`
- [ ] `UserEntity(role: 'scan', ...).isUser == false`
- [ ] Test unitario existente en `test/entities/` pasa (o se agrega)

---

### Item 2 — Validar `role` en `UserModel.fromJson`

**Prioridad:** P0 | **Esfuerzo:** S (30min)

**Problema:** `UserModel.fromJson` acepta CUALQUIER string como `role` (línea 16 de `user_model.dart`). Si Supabase retorna `role: 'hacker'`, se deserializa sin error y el routing cae al fallback de `MainScreen`.

**Solución:**

```dart
// lib/features/profiles/data/user_model.dart — línea 16, reemplazar:
role: _validateRole(json['role'] as String?),

// Agregar helper:
static String _validateRole(String? role) {
  const validRoles = {'user', 'admin', 'scan'};
  final r = role ?? 'user';
  if (!validRoles.contains(r)) return 'user'; // fallback seguro
  return r;
}
```

**Archivos afectados:**
- `lib/features/profiles/data/user_model.dart` — agregar validación

**Acceptance criteria:**
- [ ] `UserModel.fromJson({'id': 'x', 'role': 'hacker'})` → `role == 'user'`
- [ ] `UserModel.fromJson({'id': 'x', 'role': null})` → `role == 'user'`
- [ ] Roles válidos pasan sin cambios

---

### Item 3 — Guard de rol explícito en `app.dart`

**Prioridad:** P0 | **Esfuerzo:** S (30min)

**Problema:** El routing actual (líneas 54-62 de `app.dart`) usa exclusión por ausencia. Con `isUser` disponible, se puede hacer explícito.

**Solución:**

```dart
// lib/core/app/app.dart — líneas 54-62, reemplazar:
if (authState is AuthAuthenticated) {
  if (authState.user.isAdmin) {
    return const AdminDashScreen();
  }
  if (authState.user.isScan) {
    return const ScanMainScreen();
  }
  if (authState.user.isUser) {
    return const MainScreen();
  }
  // Rol desconocido → cerrar sesión forzosamente
  return const LoginScreen();
}
return const LoginScreen();
```

**Archivos afectados:**
- `lib/core/app/app.dart` — modificar bloque de routing

**Acceptance criteria:**
- [ ] Usuario con `role = 'user'` llega a `MainScreen`
- [ ] Usuario con `role = 'admin'` llega a `AdminDashScreen`
- [ ] Usuario con `role = 'scan'` llega a `ScanMainScreen`
- [ ] Usuario con rol inválido se redirige a `LoginScreen`

---

### Item 4 — Agregar función SQL `is_user()` helper

**Prioridad:** P0 | **Esfuerzo:** S (30min)

**Problema:** Existen `is_admin()`, `is_scan()` e `is_admin_or_scan()` como helpers SQL, pero NO existe `is_user()`. Para futuras políticas RLS específicas de usuario regular (ej: tabla de favoritos), se necesita este helper.

**Solución:**

```sql
-- Nueva migración: 20260720000000_add_is_user_helper.sql
CREATE OR REPLACE FUNCTION public.is_user()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'user');
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```

**Archivos afectados:**
- `supabase/migrations/20260720000000_add_is_user_helper.sql` — nueva migración

**Acceptance criteria:**
- [ ] Migración se aplica sin error
- [ ] `SELECT public.is_user()` retorna `true` para usuario con `role = 'user'`
- [ ] `SELECT public.is_user()` retorna `false` para admin/scan

---

## Fase 2: Core UX (P1)

### Item 5 — Feature Completa de Favoritos

**Prioridad:** P1 | **Esfuerzo:** XL (3+ días)

**Problema:** `BookEntity.isFavorite` (línea 23) existe en la DB, se serializa, se carga de Supabase, pero NO hay:
- Tabla `user_favorites` o campo `is_favorite` por usuario (el campo actual es global, no por usuario)
- UI para toggle de favoritos
- Pantalla de "Mis Favoritos"
- BLoC/repository para manejar favoritos

> **NOTA CRÍTICA:** El campo `is_favorite` en la tabla `books` es un booleano GLOBAL — no está vinculado a un usuario. Para que "favoritos" funcione como se espera (cada usuario tiene sus propios favoritos), se necesita una tabla de relación `user_favorites(user_id, book_id)` o renombrar el campo existente a algo como `is_featured` si su propósito es otro.

**Sub-tareas:**

#### 5a. Decisión de diseño (antes de implementar)

Evaluar dos opciones:

| Opción | Pros | Cons | Complejidad |
|--------|------|------|-------------|
| **A: Tabla `user_favorites`** | Favoritos por usuario, escalable, RLS limpio | Nueva tabla, más queries | Alta |
| **B: Renombrar `is_favorite` → `is_featured`** | Simple, sirve como "recomendado" | No es favorito personal, es global | Baja |

**Recomendación:** Opción A si se quiere "favoritos" real. Opción B si el campo era para marcar libros destacados por admin.

#### 5b. Implementación (si Opción A)

**Migración SQL:**

```sql
-- Nueva migración
CREATE TABLE user_favorites (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  book_id INT REFERENCES books(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, book_id)
);

-- RLS
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own favorites"
  ON user_favorites FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own favorites"
  ON user_favorites FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own favorites"
  ON user_favorites FOR DELETE USING (auth.uid() = user_id);
```

**Domain:**

```
lib/features/favorites/
├── domain/
│   ├── favorite_entity.dart       — FavoriteEntity(userId, bookId, createdAt)
│   └── favorite_repository.dart   — Interface: toggleFavorite, getFavorites, isFavorite
├── data/
│   └── favorite_repository_impl.dart — Supabase CRUD
├── presentation/
│   ├── bloc/
│   │   ├── favorite_bloc.dart
│   │   ├── favorite_event.dart    — ToggleFavorite, LoadFavorites
│   │   └── favorite_state.dart
│   └── screens/
│       └── favorites_screen.dart  — Lista de libros favoritos
└── presentation/widgets/
    └── favorite_button.dart       — IconButton corazon (toggle)
```

**UI changes:**

1. `lib/features/books/presentation/views/detail/detail_view.dart` — agregar `FavoriteButton` en el header
2. `lib/features/app/presentation/widgets/app_drawer.dart` — agregar item "Mis Favoritos"
3. `lib/features/app/presentation/screens/main_screen.dart` — agregar botón de favoritos al carousel

**Archivos afectados (estimado):**
- 10+ archivos nuevos (feature `favorites/`)
- 3 archivos modificados (detail_view, app_drawer, main_screen)
- 1 migración SQL

**Acceptance criteria:**
- [ ] Tap en corazon en `DetailView` togglea favorito
- [ ] Corazon se llena si el libro es favorito del usuario actual
- [ ] Drawer tiene item "Mis Favoritos" que navega a pantalla de favoritos
- [ ] `FavoritesScreen` muestra solo libros marcados por el usuario
- [ ] RLS permite cada usuario ver solo sus favoritos
- [ ] Tests de BLoC y repository pasan

---

### Item 6 — Mostrar `source` y `link` en `DetailView`

**Prioridad:** P1 | **Esfuerzo:** M (medio día)

**Problema:** `BookWithRelations` hereda `source` y `link` de `BookEntity` (líneas 21-22), pero `DetailView` (99 líneas) solo muestra descripción, metadata y géneros. Si la app quiere dirigir a contenido externo, esto está roto.

**Solución:**

```dart
// lib/features/books/presentation/views/detail/detail_view.dart
// Después del Wrap de géneros (línea 92), agregar:

// Sección "Enlaces Externos"
if (widget.books.link.isNotEmpty || widget.books.source.isNotEmpty) ...[
  const SizedBox(height: 16),
  TitleWidget(
    text: 'Enlaces',
    clContent: Theme.of(context).colorScheme.primary,
    clText: Theme.of(context).colorScheme.onSurface,
  ),
  Padding(
    padding: const EdgeInsets.all(10.0),
    child: Column(
      children: [
        if (widget.books.link.isNotEmpty)
          CardInfoDetail(
            title1: "Enlace Externo",
            text1: widget.books.link,
            // onTap: () => launchUrl(Uri.parse(widget.books.link)),
          ),
        if (widget.books.source.isNotEmpty)
          CardInfoDetail(
            title1: "Fuente",
            text1: widget.books.source,
            // onTap: () => launchUrl(Uri.parse(widget.books.source)),
          ),
      ],
    ),
  ),
],
```

**Nota:** Se necesita evaluar si `CardInfoDetail` soporta `onTap`. Si no, crear un wrapper o usar `InkWell` + `launchUrl`. Verificar `pubspec.yaml` para `url_launcher`.

**Archivos afectados:**
- `lib/features/books/presentation/views/detail/detail_view.dart` — agregar sección de enlaces
- Posiblemente `lib/features/books/presentation/views/detail/widgets/card_info_detail.dart` — soporte onTap
- `pubspec.yaml` — agregar `url_launcher` si no existe

**Acceptance criteria:**
- [ ] Si `link` no está vacío, se muestra como enlace clickeable
- [ ] Si `source` no está vacío, se muestra como enlace clickeable
- [ ] Si ambos están vacíos, la sección "Enlaces" no aparece
- [ ] Tap en enlace abre URL en navegador externo

---

### Item 7 — Eliminar dead code en `ChapterScreen`

**Prioridad:** P1 | **Esfuerzo:** S (1-2h)

**Problema:** `ChapterScreen` (186 líneas) tiene 4 variables declaradas pero sin UI para modificarlas:

```dart
// líneas 32-35
double textSize = 14.0;
String selectedFont = 'Arial';
FontStyle selectedStyle = FontStyle.normal;
FontWeight selectedWeight = FontWeight.normal;
```

Además:
- `textEditingController` (línea 37) se crea y se asigna `textSize.toString()` (línea 43) pero nunca se usa en ningún widget
- Los `TextStats` (líneas 116-119) se calculan en CADA rebuild del `PageView` pero nunca se muestran al usuario

**Solución — dos opciones:**

**Opción A: Eliminar dead code (si no hay planes de UI de personalización)**

Eliminar las 4 variables, `textEditingController`, y los cálculos de `TextStats` en el `itemBuilder`. Queda el estilo fijo en `TextStyle` inline.

**Opción B: Activar la UI de personalización (feature futura)**

Crear un `BottomSheet` o `AppBar` con controles para cambiar `textSize`, `selectedFont`, etc. Esto es más trabajo pero aprovecha el código existente.

**Recomendación:** Opción A por ahora. Las variables se pueden recuperar del git history cuando se implemente la feature.

**Archivos afectados:**
- `lib/features/chapters/presentation/screens/chapter_screen.dart` — eliminar líneas 27-30, 32-35, 37, 43, 116-119

**Acceptance criteria:**
- [ ] No hay variables sin usar en `_ChapterScreenState`
- [ ] `textEditingController` eliminado (no se necesita)
- [ ] `TextStats` solo se calcula si se va a mostrar (o se elimina si no se usa)
- [ ] El lector funciona igual: mismo tamaño, misma fuente, misma experiencia
- [ ] No hay warnings de `unused_variable` en el archivo

---

### Item 8 — Pasar `isScan`/`isAdmin` reales al `AppDrawer`

**Prioridad:** P1 | **Esfuerzo:** S (30min)

**Problema:** `MainScreen` (línea 38) instancia `AppDrawer()` sin pasar `isScan` ni `isAdmin`. El drawer los tiene como parámetros default `false` (línea 12 de `app_drawer.dart`). Funciona para el usuario regular, pero es frágil y oculta la dependencia.

**Solución:**

```dart
// lib/features/app/presentation/screens/main_screen.dart — línea 38, reemplazar:
drawer: AppDrawer(
  isScan: context.read<AuthBloc>().state is AuthAuthenticated
      ? (context.read<AuthBloc>().state as AuthAuthenticated).user.isScan
      : false,
  isAdmin: context.read<AuthBloc>().state is AuthAuthenticated
      ? (context.read<AuthBloc>().state as AuthAuthenticated).user.isAdmin
      : false,
),
```

**Mejor aún:** Usar `BlocBuilder<AuthBloc, AuthState>` o extraer el usuario del estado del BLoC ya existente.

**Archivos afectados:**
- `lib/features/app/presentation/screens/main_screen.dart` — modificar línea 38

**Acceptance criteria:**
- [ ] `AppDrawer` recibe los valores reales del rol del usuario
- [ ] El drawer del usuario regular muestra solo "Inicio" / "Editar Perfil" / "Cerrar Sesión"
- [ ] No hay duplicación de lógica de rol

---

## Fase 3: Features Nuevos (P2)

### Item 9 — Empty states para home y búsquedas vacías

**Prioridad:** P2 | **Esfuerzo:** M (medio día)

**Problema:** Si no hay libros visibles (`BookLoaded` con lista vacía), `MainScreen` muestra un `CustomScrollView` vacío sin ningún feedback al usuario. Idéntico problema si la búsqueda por género no retorna resultados.

**Solución:**

```dart
// lib/features/app/presentation/screens/main_screen.dart
// En _buildContent, al inicio agregar:
if (listBook.isEmpty) {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.library_books_outlined, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text('No hay libros disponibles'),
        Text('Intenta más tarde o contacta al administrador'),
      ],
    ),
  );
}
```

**Archivos afectados:**
- `lib/features/app/presentation/screens/main_screen.dart` — agregar empty state
- `lib/features/genres/presentation/screens/genre_screen.dart` — agregar empty state para filtro vacío

**Acceptance criteria:**
- [ ] Home muestra mensaje amigable si no hay libros
- [ ] GenreScreen muestra mensaje si el filtro no retorna resultados
- [ ] Empty state incluye ícono ilustrativo

---

### Item 10 — Paginación / Scroll infinito en home

**Prioridad:** P2 | **Esfuerzo:** L (1-2 días)

**Problema:** `BookRepository.getBooks()` soporta `page` y `pageSize` (líneas 19-20 de `book_repository_impl.dart`), pero `MainScreen` siempre llama `LoadBooks()` sin parámetros (usa defaults `page=1, pageSize=50`). No hay scroll infinito ni indicador de "cargando más".

**Solución:**

1. Modificar `BookBloc` para soportar `LoadMoreBooks(page)` event
2. Agregar `ScrollController` en `MainScreen` que detecte cuando el usuario llega al final
3. Mostrar `CircularProgressIndicator` al final de la lista mientras carga
4. Cuando no hay más libros, dejar de mostrar el indicador

**Archivos afectados:**
- `lib/features/books/presentation/bloc/book_bloc.dart` — agregar evento `LoadMoreBooks`
- `lib/features/books/presentation/bloc/book_event.dart` — definir evento
- `lib/features/books/presentation/bloc/book_state.dart` — agregar `hasMore` al state
- `lib/features/app/presentation/screens/main_screen.dart` — scroll listener + pagination

**Acceptance criteria:**
- [ ] Al llegar al final del scroll, se cargan más libros
- [ ] Indicador de carga se muestra mientras se cargan
- [ ] Cuando no hay más, el indicador desaparece
- [ ] No se duplican libros al paginar

---

### Item 11 — Filtros de género interactivos en DetailView

**Prioridad:** P2 | **Esfuerzo:** S (1-2h)

**Problema:** En `DetailView` (línea 80), los chips de género tienen `onTap: () {}` — un callback vacío. El usuario puede ver los géneros pero no puede navegar a filtrar por ellos.

**Solución:**

```dart
// lib/features/books/presentation/views/detail/detail_view.dart — línea 79
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GenreScreen(
        genre: item.name,
        books: [], // Se cargará por género desde GenreScreen
        coverUrlService: getIt<CoverUrlService>(),
      ),
    ),
  );
},
```

**Nota:** Requiere verificar que `GenreScreen` pueda cargar libros por género sin recibir la lista completa. Si no puede, se necesita modificar `GenreScreen` para que haga su propia query.

**Archivos afectados:**
- `lib/features/books/presentation/views/detail/detail_view.dart` — modificar `onTap` en línea 80
- Posiblemente `lib/features/genres/presentation/screens/genre_screen.dart` — soportar carga por género

**Acceptance criteria:**
- [ ] Tap en chip de género navega a `GenreScreen` con filtro correcto
- [ ] `GenreScreen` muestra libros de ese género
- [ ] El usuario puede volver con el botón de retroceso

---

## Fase 4: Polish (P3)

### Item 12 — Estadísticas de lectura persistentes

**Prioridad:** P3 | **Esfuerzo:** M (medio día)

**Problema:** `ChapterScreen` calcula `caracteres`, `palabras`, `frases`, `parrafos` (líneas 27-30) pero nunca los muestra. Son dead code que podría convertirse en feature útil: mostrar stats de lectura al usuario.

**Solución:**

1. Crear widget `ReadingStats` que muestre las estadísticas
2. Mostrar en el `SliverAppBar` del `ChapterScreen` (expandible) o en un `BottomSheet`
3. Opcionalmente: persistir en Supabase para tracking de lectura

**Archivos afectados:**
- `lib/features/chapters/presentation/screens/chapter_screen.dart` — mostrar stats
- Nuevo widget `lib/features/chapters/presentation/widgets/reading_stats.dart`

**Acceptance criteria:**
- [ ] Las estadísticas de lectura son visibles en el lector
- [ ] Se actualizan al cambiar de capítulo
- [ ] El usuario puede ocultarlas (no obstaculizan la lectura)

---

### Item 13 — Tests unitarios para BLoCs de usuario regular

**Prioridad:** P3 | **Esfuerzo:** L (1-2 días)

**Problema:** Existen tests para `BookBloc`, `ChapterBloc`, `ProfileBloc`, `AuthBloc`, `GenreBloc` — pero no hay tests específicos que validen el comportamiento del usuario regular (ej: que no puede acceder a rutas admin, que solo ve libros visibles).

**Tests sugeridos:**

```
test/
├── bloc/
│   ├── auth_bloc_regular_user_test.dart  — Test que el routing llega a MainScreen
│   └── favorites_bloc_test.dart          — Si se implementa Item 5
├── integration/
│   └── regular_user_flow_test.dart       — Flujo completo: login → home → book → chapter
└── entities/
    └── user_entity_test.dart             — Tests de isUser, isAdmin, isScan
```

**Archivos afectados:**
- Nuevos archivos de test

**Acceptance criteria:**
- [ ] Test que `isUser == true` para `role = 'user'`
- [ ] Test que `UserModel.fromJson` valida roles inválidos
- [ ] Test que `BookBloc(onlyVisible: true)` solo retorna libros visibles
- [ ] Test que routing envía a `MainScreen` para usuario regular

---

### Item 14 — Widget tests para pantallas core

**Prioridad:** P3 | **Esfuerzo:** L (1-2 días)

**Pantallas a testear:**

| Pantalla | Qué testear |
|----------|------------|
| `MainScreen` | Muestra carousel, chips de género, drawer abre |
| `DetailView` | Muestra descripción, metadata, géneros |
| `ChapterScreen` | Muestra contenido, PageView funciona |
| `ProfileScreen` | Muestra avatar, nombre, email |
| `AppDrawer` | Muestra items correctos para usuario regular |

**Archivos afectados:**
- Nuevos archivos en `test/widgets/` o `test/presentation/`

**Acceptance criteria:**
- [ ] Cada pantalla renderiza sin errores
- [ ] Navegación entre pantallas funciona
- [ ] Loading states se muestran correctamente

---

## Estimación Total

| Fase | Items | Esfuerzo Estimado |
|------|-------|-------------------|
| **Fase 1: Seguridad e Integridad** | 1, 2, 3, 4 | **S** (~4h total) |
| **Fase 2: Core UX** | 5, 6, 7, 8 | **XL** (~4-5 días) |
| **Fase 3: Features Nuevos** | 9, 10, 11 | **L** (~3 días) |
| **Fase 4: Polish** | 12, 13, 14 | **L** (~3 días) |
| **TOTAL** | 14 items | **XL** (~11-12 días) |

### Dependencias entre items

```text
Item 1 (isUser getter)
  └── Item 3 (guard explícito en app.dart) requiere Item 1
  └── Item 5 (favoritos) requiere Item 1 para RLS

Item 4 (is_user() SQL)
  └── Item 5 (favoritos) necesita esta función para RLS policies

Item 7 (dead code ChapterScreen)
  └── Item 12 (stats) puede reutilizar o eliminar lo que Item 7 limpia
```

### Orden de implementación recomendado

```text
Semana 1 (Fase 1):
  Día 1: Items 1, 2, 3, 4 (todo es S, se puede hacer en una mañana)
  Día 2: Item 5a (decisión de diseño de favoritos)
  Día 3-5: Item 5b (implementación de favoritos — si se elige Opción A)

Semana 2 (Fase 2 + 3):
  Día 1: Items 7, 8 (cleanup — rápidos)
  Día 2: Item 6 (source/link en DetailView)
  Día 3: Items 9, 11 (empty states + géneros interactivos)
  Día 4-5: Item 10 (paginación)

Semana 3 (Fase 4):
  Día 1: Item 12 (stats de lectura)
  Día 2-3: Items 13, 14 (tests)
```

---

## Riesgos y Consideraciones

### Riesgo 1: `isFavorite` — Decisión de diseño pendiente

El campo `is_favorite` en la tabla `books` es un booleano GLOBAL (no por usuario). Si se implementa "favoritos" como feature personal, se necesita una tabla nueva `user_favorites`. Si el campo original era para "libros destacados por admin", hay que renombrarlo para evitar confusión. **Esta decisión debe tomarse ANTES de implementar Item 5.**

### Riesgo 2: `url_launcher` no está en dependencias

Para Item 6 (enlaces externos), se necesita `url_launcher` o `go_router` para abrir URLs. Verificar `pubspec.yaml` antes de implementar.

### Riesgo 3: `GenreScreen` acoplamiento

`GenreScreen` recibe `books: listBook` como parámetro (filtros localmente). Para Item 11 (navegación desde DetailView), se necesita que `GenreScreen` pueda cargar libros por género desde Supabase si no recibe la lista completa. Esto requiere modificar `GenreScreen` o crear una ruta alternativa.

### Riesgo 4: `ChapterScreen` — variables de estilo

Las variables de estilo (`selectedFont`, etc.) están declaradas pero se usan en el `TextStyle` del contenido (líneas 161-164). Eliminarlas (Item 7) significa que el estilo queda hardcodeado. Si se quiere personalización futuro, mejor moverlas a un `ReaderSettings` widget separado en lugar de eliminarlas.

### Riesgo 5: Performance de `TextStats`

En `ChapterScreen` (líneas 116-119), `TextStats.characters()`, `.words()`, `.sentences()`, `.paragraphs()` se ejecutan en CADA rebuild del `itemBuilder` del `PageView`. Con capítulos largos, esto puede causar jank. Si se mantiene, calcular una sola vez al cargar el capítulo y almacenar en el state.

### Riesgo 6: Paginación y RLS

`book_repository_impl.dart` usa `.range(offset, offset + pageSize - 1)` (línea 35). Si RLS filtra filas después del range, el usuario puede recibir menos de `pageSize` items sin que signifique que no hay más. Se necesita usar `COUNT` query o ajustar el range para compensar.

---

## Archivos de Referencia Rápida

| Archivo | Relevancia para este plan |
|---------|--------------------------|
| `lib/features/profiles/domain/user_entity.dart` | Items 1, 3 — agregar `isUser` |
| `lib/features/profiles/data/user_model.dart` | Item 2 — validar role |
| `lib/core/app/app.dart` | Item 3 — guard de rol |
| `lib/features/books/domain/book_entity.dart` | Items 5, 6 — isFavorite, source, link |
| `lib/features/books/presentation/views/detail/detail_view.dart` | Items 6, 11 — enlaces, géneros |
| `lib/features/chapters/presentation/screens/chapter_screen.dart` | Items 7, 12 — dead code, stats |
| `lib/features/app/presentation/screens/main_screen.dart` | Items 8, 9, 10 — drawer, empty, pagination |
| `lib/features/app/presentation/widgets/app_drawer.dart` | Item 8 — pasar roles reales |
| `lib/features/books/data/book_repository_impl.dart` | Item 10 — paginación |
| `supabase/migrations/` | Items 4, 5 — nueva migración |
