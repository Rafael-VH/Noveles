# Noveles

> A Flutter novel reader app with role-based access, built with Clean Architecture and Supabase.

## What Is This?

Noveles is a mobile application for reading and managing novels. It supports three user roles — **Admin**, **Scan** (content creator), and **Regular User** — each with tailored screens and permissions. Content is stored in Supabase (Postgres + Storage), and the app follows Clean Architecture with BLoC state management.

**Key stats**: 9 entities, 46 use cases, 16 BLoCs, 19 screens, 11 features.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.3+ / Dart |
| Backend | Supabase (Postgres, Auth, Storage) |
| State | BLoC / Cubit |
| DI | GetIt |
| Testing | flutter_test, mocktail, bloc_test |

## Quick Start

→ [Getting Started Guide](guides/getting-started.md)

## Documentation Index

| Category | Path | Description |
|----------|------|-------------|
| **Architecture** | | |
| Clean Architecture | [architecture/overview.md](architecture/overview.md) | Layer structure, dependency flow, folder mapping |
| **Domain** | | |
| Entity Catalog | [domain/entities.md](domain/entities.md) | 9 entities with field types and relationships |
| **Features** | | |
| Auth | [../lib/features/auth/](../lib/features/auth/) | Login, register, session management |
| Books | [../lib/features/books/](../lib/features/books/) | Book CRUD, cover upload, visibility |
| Chapters | [../lib/features/chapters/](../lib/features/chapters/) | Chapter reading, content storage |
| Tooks | [../lib/features/tooks/](../lib/features/tooks/) | Volumes/tomes within books |
| Genres | [../lib/features/genres/](../lib/features/genres/) | Genre classification |
| Labels | [../lib/features/labels/](../lib/features/labels/) | Tagging system |
| Profiles | [../lib/features/profiles/](../lib/features/profiles/) | User profiles, role management |
| Favorites | [../lib/features/favorites/](../lib/features/favorites/) | Book favoriting |
| Admin | [../lib/features/admin/](../lib/features/admin/) | Admin dashboard |
| Scan | [../lib/features/scan/](../lib/features/scan/) | Content creation |
| App | [../lib/features/app/](../lib/features/app/) | Shell, routing, drawer |
| **User Types** | | |
| Regular User | [user-types/regular-user.md](user-types/regular-user.md) | Default role |
| Scan User | [user-types/scan-user.md](user-types/scan-user.md) | Content creator role |
| Admin User | [user-types/admin-user.md](user-types/admin-user.md) | Full access role |
| **Database** | | |
| Database Docs | [database/README.md](database/README.md) | Tables, storage, RLS, SQL functions |
| **Guides** | | |
| Getting Started | [guides/getting-started.md](guides/getting-started.md) | Developer setup guide |
| **Testing** | | |
| Test Strategy | [testing/README.md](testing/README.md) | 34 test files, categories, patterns |

## Project Structure

```
lib/
├── core/              # Cross-cutting: DI, errors, Supabase client, theme, utils
├── features/          # 11 feature modules (domain/data/presentation each)
│   ├── admin/
│   ├── app/
│   ├── auth/
│   ├── books/
│   ├── chapters/
│   ├── favorites/
│   ├── genres/
│   ├── labels/
│   ├── profiles/
│   ├── scan/
│   └── tooks/
├── shared/            # Shared entities and widgets across features
│   ├── domain/
│   └── presentation/
└── main.dart          # Entry point
```

---

*Last verified: 2026-07-21*
