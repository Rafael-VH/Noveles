# Architecture Overview

> Clean Architecture as implemented in Noveles — three layers with strict
dependency rules.

← [Back to index](../README.md)

## Overview

Noveles follows **Clean Architecture** with three concentric layers:

```text
┌─────────────────────────────────┐
│       Presentation              │  BLoCs, Screens, Widgets
├─────────────────────────────────┤
│         Domain                  │  Entities, Use Cases, Repository interfaces
├─────────────────────────────────┤
│           Data                  │  Repository implementations, Models
└─────────────────────────────────┘
```text

**Dependency rule**: Inner layers never depend on outer layers. Domain knows
nothing about Data or Presentation. Data depends on Domain (for repository
interfaces). Presentation depends on Domain (for entities and use cases).

## Folder Mapping

### Feature Modules (`lib/features/`)

Each feature follows the same three-layer structure:

```text
lib/features/{feature}/
├── di/                        # Feature DI registration (injection_{feature}.dart)
├── domain/
│   ├── *_entity.dart          # Domain entities (Equatable)
│   ├── *_repository.dart      # Abstract repository interface
│   └── *_use_case.dart        # Business logic use cases
├── data/
│   └── *_repository_impl.dart # Repository implementation (talks to the backend ports)
└── presentation/
    ├── bloc/                  # BLoC / Cubit state management
    └── screens/               # UI screens and widgets
```text

**10 feature modules**: `admin`, `app`, `auth`, `books`, `chapters`,
`genres`, `labels`, `profiles`, `scan`, `tooks`.

### Core Layer (`lib/core/`)

Shared infrastructure that all features depend on:

| Folder | Purpose |
| -------- | --------- |
| `backend/` | Backend ports (data, auth, storage) plus the adapters that implement them — the only place that names a vendor |
| `constants/` | Storage bucket names (`StorageConstants`) |
| `cover/` | Cover image utilities |
| `errors/` | ``Result<T>`` sealed class, `Failure` hierarchy |
| `presentation/` | ThemeBloc, notification system, shared widgets |
| `utils/` | Colors, theme definitions, parsing, logging |

The composition root lives outside `core/`, in `lib/bootstrap/`: `injection.dart`
registers every dependency, and `app.dart` is the root widget.

### Shared Layer (`lib/shared/`)

Code reused across multiple features:

| Folder | Purpose |
| -------- | --------- |
| domain/entities/ | BookWithRelations — hydrated book with genres,labels,t... |
| `presentation/widgets/` | Shared UI components |

## Dependency Flow

```text
Presentation ──→ Domain ←── Data
      │              │           │
      │              │           └── Repository impls call the backend ports
      │              └── Pure Dart: entities, use cases, repo interfaces
      └── BLoCs call use cases, map `Result<T>` to state
```text

**Key principle**: The Domain layer is **pure Dart** — no Flutter imports, no
Supabase imports. This makes entities and use cases testable without any
framework dependency.

### How Dependencies Are Wired

GetIt connects the layers at runtime:

1. `lib/bootstrap/injection.dart` defines `setupDependencies()`
2. It first calls `registerBackendDependencies()`, which binds the three ports to the adapters of the current backend
3. Each feature has `lib/features/{feature}/di/injection_{feature}.dart` registering its own dependencies
4. Repositories: `registerLazySingleton` (created once, shared)
5. BLoCs: `registerFactory` (new instance per request)

## Error Handling

Use cases return `Future<`Result<T>`>` where `Result` is a sealed class:

- `Ok<T>` — success with value
- `Err<T>` — failure with a `Failure` object

BLoCs receive the `Result`, extract the value or map `Failure` to error state.
See `lib/core/errors/result.dart` and `lib/core/errors/failure.dart`.

## Key Design Decisions

| Decision | Choice | Rationale |
| ---------- | -------- | ----------- |
| State management | BLoC | Predictable state transitions, testable |
| DI | GetIt | Simple service locator, no code generation |
| Entities | Equatable | Value equality for state comparisons |
| Error handling | Result<T> sealed | Explicit error paths,no exceptions in UC |
| Backend | Supabase, behind ports | Auth + DB + Storage in one platform, replaceable without touching feature code |

---

> Last verified: 2026-07-24
