# Architecture Overview

> Clean Architecture as implemented in Noveles — three layers with strict dependency rules.

← [Back to index](../README.md)

## Overview

Noveles follows **Clean Architecture** with three concentric layers:

```
┌─────────────────────────────────┐
│       Presentation              │  BLoCs, Screens, Widgets
├─────────────────────────────────┤
│         Domain                  │  Entities, Use Cases, Repository interfaces
├─────────────────────────────────┤
│           Data                  │  Repository implementations, Models
└─────────────────────────────────┘
```

**Dependency rule**: Inner layers never depend on outer layers. Domain knows nothing about Data or Presentation. Data depends on Domain (for repository interfaces). Presentation depends on Domain (for entities and use cases).

## Folder Mapping

### Feature Modules (`lib/features/`)

Each feature follows the same three-layer structure:

```
lib/features/{feature}/
├── domain/
│   ├── *_entity.dart          # Domain entities (Equatable)
│   ├── *_repository.dart      # Abstract repository interface
│   └── *_use_case.dart        # Business logic use cases
├── data/
│   └── *_repository_impl.dart # Repository implementation (Supabase calls)
└── presentation/
    ├── bloc/                  # BLoC / Cubit state management
    └── screens/               # UI screens and widgets
```

**11 feature modules**: `admin`, `app`, `auth`, `books`, `chapters`, `favorites`, `genres`, `labels`, `profiles`, `scan`, `tooks`.

### Core Layer (`lib/core/`)

Shared infrastructure that all features depend on:

| Folder | Purpose |
|--------|---------|
| `app/` | `App` widget, routing, role-based home selection |
| `constants/` | Storage bucket names (`StorageConstants`) |
| `cover/` | Cover image utilities |
| `di/` | GetIt dependency injection setup (11 modules) |
| `errors/` | `Result<T>` sealed class, `Failure` hierarchy |
| `presentation/` | ThemeBloc, notification system, shared widgets |
| `supabase/` | Supabase client provider, chapter caching |
| `utils/` | Colors, theme definitions, parsing, logging |

### Shared Layer (`lib/shared/`)

Code reused across multiple features:

| Folder | Purpose |
|--------|---------|
| `domain/entities/` | `BookWithRelations` — hydrated book with genres, labels, tooks |
| `presentation/widgets/` | Shared UI components |

## Dependency Flow

```
Presentation ──→ Domain ←── Data
      │              │           │
      │              │           └── Repository impls call Supabase
      │              └── Pure Dart: entities, use cases, repo interfaces
      └── BLoCs call use cases, map Result<T> to state
```

**Key principle**: The Domain layer is **pure Dart** — no Flutter imports, no Supabase imports. This makes entities and use cases testable without any framework dependency.

### How Dependencies Are Wired

GetIt connects the layers at runtime:

1. `lib/core/di/injection.dart` calls `setupDependencies()`
2. Each feature has `injection_{feature}.dart` registering its own dependencies
3. Repositories: `registerLazySingleton` (created once, shared)
4. BLoCs: `registerFactory` (new instance per request)

## Error Handling

Use cases return `Future<Result<T>>` where `Result` is a sealed class:

- `Ok<T>` — success with value
- `Err<T>` — failure with a `Failure` object

BLoCs receive the `Result`, extract the value or map `Failure` to error state. See `lib/core/errors/result.dart` and `lib/core/errors/failure.dart`.

## Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| State management | BLoC | Predictable state transitions, testable |
| DI | GetIt | Simple service locator, no code generation |
| Entities | Equatable | Value equality for state comparisons |
| Error handling | Result<T> sealed | Explicit error paths, no exceptions in use cases |
| Backend | Supabase | Auth + DB + Storage in one platform |

---

*Last verified: 2026-07-21*
