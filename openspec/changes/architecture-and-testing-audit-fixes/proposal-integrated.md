# Proposal: Auditoría Completa — Plan Integrado Post Multi-Agent Review

## Contexto

Este plan **reemplaza y extiende** el proposal anterior (`proposal.md`). La revisión paralela de 5 sub-agentes (Domain, Data, Presentation, Core, Supabase/DB) encontró **13 CRITICAL, 32 WARNING, 19 SUGGESTION** — muchos NO cubiertos por el plan original.

---

## Veredicto sobre Modularización (Batch 0)

❌ **NO es necesaria para el plan. No la recomiendo.**

| Factor | Peso |
|--------|------|
| Bugs que arregla | **0 de 13 CRITICAL** |
| Archivos a tocar | ~120 solo para imports |
| Riesgo de romper | Alto (imports rotos, barrel exports) |
| Dependencia para fixes | **Ninguna** — los fixes funcionan con estructura plana o modular |
| Valor | Cosmético / organizacional |

> **Si querés hacerla**, el diseño ya existe en `design/batch-0-restructure.md` y tasks en `tasks/batch-0-restructure.md`. Se puede ejecutar como cambio separado después de los fixes. Pero **no es un blocker**.

---

## Plan de Acción — 4 Fases

### 🔴 FASE 1: DB + Schema (3 CRITICAL, 7 WARNING)
*Base de datos — debe ir primero porque los fixes de código dependen del schema*

| # | Ticket | Severidad | Descripción | Archivo |
|---|--------|-----------|-------------|---------|
| 1.1 | DB-C1 | 🔴 CRITICAL | Verificar/crear trigger `on_auth_user_created` en producción | `20260515161849_profiles_and_auth.sql` |
| 1.2 | DB-C2 | 🔴 CRITICAL | `books_labels.book_id` BIGINT → INTEGER (match `books.id`) | `20260520020000_labels.sql` |
| 1.3 | DB-C3 | 🔴 CRITICAL | Seed: verificar que `admin@noveles.com` role `'admin'` sea intencional | `seed.sql` |
| 1.4 | DB-W1 | 🟡 WARNING | Dropear columna muerta `books.author` | Migration nueva |
| 1.5 | DB-W2 | 🟡 WARNING | Dropear columna muerta `tooks.content` | Migration nueva |
| 1.6 | DB-S2 | 🔵 SUGGESTION | Migrar `took_count`/`chapter_count` TEXT → INTEGER | Migration nueva |
| 1.7 | DB-W7 | 🟡 WARNING | Agregar CASCADE en `tooks` → `chapters` (evitar orphans) | Migration nueva |
| 1.8 | DB-S3 | 🔵 SUGGESTION | Agregar índice `idx_books_visible` + `idx_books_scan_own` | Migration nueva |
| 1.9 | DB-W5 | 🟡 WARNING | Agregar `is_admin_or_scan()` helper para RLS | Migration nueva |
| 1.10 | DB-S6 | 🔵 SUGGESTION | Agregar `.env` al `.gitignore` raíz | `.gitignore` |

**Migración unificada**: `20260615000000_audit_fixes_v4.sql` con todos los cambios idempotentes.

---

### 🟠 FASE 2: Domain + Core Architecture (6 CRITICAL, 9 WARNING)
*Debe ir antes que Data y Presentation*

#### 2.1 Domain Layer

| # | Ticket | Severidad | Descripción |
|---|--------|-----------|-------------|
| 2.1.1 | DM-C1 | 🔴 CRITICAL | Reemplazar `AuthChangeEvent` (Supabase) por `enum AuthEvent` (domain puro) en `AuthRepository` |
| 2.1.2 | DM-C2 | 🔴 CRITICAL | Crear jerarquía `Failure` base con subtipos (`AuthFailure`, `BookFailure`, etc.) |
| 2.1.3 | — | 🔴 CRITICAL | Migrar repositorios a `Future<Either<Failure, T>>` (dartz) en vez de lanzar `RepositoryException` |

**Archivos a modificar:**
- `domain/repositories/auth_repository.dart` — cambiar tipo de retorno
- `domain/helpers/auth_event.dart` — **NUEVO**: enum AuthEvent
- `core/errors/failure.dart` — **NUEVO**: clase Failure + subtipos
- `core/errors/repository_exception.dart` — mantener como wrapper interno de data
- 7 interfaces de repositorio en `domain/repositories/` — cambiar retornos a `Either<Failure, T>`
- 42 use cases en `domain/use_cases/` — actualizar tipos de retorno

#### 2.2 Core / Infrastructure

| # | Ticket | Severidad | Descripción |
|---|--------|-----------|-------------|
| 2.2.1 | CR-C1 | 🔴 CRITICAL | Hacer SupabaseClient inyectable (wrapper/abstract class, DI registration) |
| 2.2.2 | CR-C4 | 🔴 CRITICAL | Agregar tests para `lib/core/` (setupDependencies, supabase client, storage_helper) |
| 2.2.3 | CR-C3 | 🟡 WARNING | Registrar `ThemeBloc` en DI (no crearlo inline en `app.dart`) |
| 2.2.4 | CR-W3 | 🟡 WARNING | `storage_helper.coverUrl()` — convertir a servicio inyectable (`CoverUrlService`) |
| 2.2.5 | CR-W4 | 🟡 WARNING | Evaluar si `blueTheme`/`BlueColor` deben eliminarse (código muerto) |
| 2.2.6 | CR-W5 | 🟡 WARNING | Actualizar `flutter_lints ^4.0.0` → `^5.0.0` |
| 2.2.7 | CR-W7 | 🟡 WARNING | Agregar reglas custom a `analysis_options.yaml` |

---

### 🟡 FASE 3: Data Layer (4 CRITICAL, 16 WARNING)
*Depende de Fase 2 (nuevos tipos de retorno Either/Failure)*

| # | Ticket | Severidad | Descripción |
|---|--------|-----------|-------------|
| 3.1 | DT-C2 | 🔴 CRITICAL | `book_repository_impl.dart`: INNER JOIN → LEFT JOIN (`authors!inner` y `books_genres!inner`) |
| 3.2 | DT-C4 | 🔴 CRITICAL | `book_model.dart`/`took_model.dart`: `tookCount`/`chapterCount` casteo `String` — sincronizar con DB |
| 3.3 | DT-W1+ | 🟡 WARNING | `auth_repository_impl`: usar `UserModel` en vez de construir `UserEntity` directo |
| 3.4 | DT-W2 | 🟡 WARNING | `auth_repository_impl.register()`: sacar throw del catch |
| 3.5 | DT-W3 | 🟡 WARNING | `auth_repository_impl.getCurrentUser()`: no silenciar errores de perfil |
| 3.6 | DT-W8 | 🟡 WARNING | `profiles_repository_impl.getProfile()`: `.single()` → `.maybeSingle()` |
| 3.7 | DT-W5 | 🟡 WARNING | `took_repository_impl.deleteTook()`: hacer transactional o usar CASCADE |
| 3.8 | DT-W4 | 🟡 WARNING | `book_repository_impl.uploadCover()`: retornar URL, no solo filename |
| 3.9 | DT-W11 | 🟡 WARNING | `book_model.toJson()`: limpiar campos no usados |
| 3.10 | DT-W12 | 🟡 WARNING | `chapter_model.toJson()`: sync con convención (id/created_at sí o no) |
| 3.11 | DT-W7 | 🟡 WARNING | Extraer `MockFilterBuilder` duplicado a `test/helpers/mocks.dart` |

---

### 🔵 FASE 4: Tests (4 CRITICAL, 7 WARNING)
*Puede correr en paralelo parcial con Fase 3*

| # | Ticket | Severidad | Descripción |
|---|--------|-----------|-------------|
| 4.1 | DT-W1 | 🟡 WARNING | Tests para repositorios faltantes: `auth`, `genre`, `label`, `profiles` |
| 4.2 | DT-W2 | 🟡 WARNING | Tests para modelos faltantes: `book_model`, `chapter_model`, `genre_model`, `label_model`, `took_model`, `user_model` |
| 4.3 | CR-C4 | 🔴 CRITICAL | Tests para `lib/core/`: `setupDependencies()`, `supabase_client`, `storage_helper`, `repository_exception` |
| 4.4 | DM-W | 🟡 WARNING | Tests para entidades faltantes: `GenreEntity`, `UserEntity` |
| 4.5 | — | 🟡 WARNING | Tests para use cases críticos: create/update/delete book, chapter, took |
| 4.6 | — | 🔵 SUGGESTION | Reemplazar `widget_test.dart` placeholder |

---

### 🧹 FASE 5: Cleanup Opcional
*Cosmético / baja prioridad*

| # | Descripción |
|---|-------------|
| 5.1 | Eliminar `blueTheme`/`BlueColor` si no se usa |
| 5.2 | Agregar reglas de linter (`prefer_single_quotes`, `require_trailing_commas`, etc.) |
| 5.3 | Migrar a `package:dart_flutter_style_lints` |
| 5.4 | Generar tipos Dart desde `supabase gen types` |

---

## Dependencias Entre Fases

```
FASE 1 (DB) ──→ FASE 2 (Domain/Core) ──→ FASE 3 (Data) ──→ FASE 4 (Tests)
       ↑                                        │                    │
       └── independiente de Fase 2              └── Fase 4 puede    │
                                                  arrancar con      │
                                                  Fase 3 parcial    │
                                                                     ↓
                                                            FASE 5 (Cleanup)
                                                            (independiente)
```

---

## Resumen de Carga

| Fase | CRITICAL | WARNING | SUGGESTION | Archivos a tocar |
|------|----------|---------|------------|------------------|
| Fase 1: DB | 3 | 7 | 6 | ~4 (1 migration + seed + .gitignore) |
| Fase 2: Domain/Core | 6 | 9 | 7 | ~55 (domain + core) |
| Fase 3: Data | 4 | 16 | 6 | ~23 (data models + repos + helpers) |
| Fase 4: Tests | 0 | 7 | 0 | ~20 (test files) |
| Fase 5: Cleanup | 0 | 0 | 4 | ~5 |
| **TOTAL** | **13** | **39** | **23** | **~107 archivos** |

---

## Estrategia de Entrega

**Recomendación**: 3-4 chained PRs, ordenados por fase:

| PR | Contenido | Líneas estimadas |
|----|-----------|------------------|
| PR#1 | Fase 1 (DB schema + seed) | ~100 |
| PR#2 | Fase 2 (Domain + Core architecture) | ~350 |
| PR#3 | Fase 3 (Data layer fixes) | ~250 |
| PR#4 | Fase 4 + 5 (Tests + Cleanup) | ~400 |

Cada PR pasa por `arquic review` antes de mergear.

---

## Lo que NO está en este plan

- Modularización (Batch 0) — disponible como cambio separado si se desea
- Descomposición de `ScanBloc` (God BLoC) — requiere cambio arquitectónico aparte
- Descomposición de `AdminMainScreen` (705 líneas) — refactor separado
- Migración `String role` → `enum UserRole` — requiere migración de datos
