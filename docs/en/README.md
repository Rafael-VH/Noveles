# Noveles

> A Flutter novel reader app with role-based access, built with Clean
Architecture and Supabase.

**🌐 Languages**: [English](README.md) | [Español](../es/README.md)

## What Is This?

Noveles is a mobile application for reading and managing novels. It supports
three user roles — **Admin**, **Scan** (content creator), and **Regular User** —
each with tailored screens and permissions. Content is stored in Supabase
(Postgres + Storage), and the app follows Clean Architecture with BLoC state
management.

**Key stats**: 10 entities, 54 use cases, 19 BLoCs, 19 screens, 12 features.

## Tech Stack

| Layer | Technology |
| ------- | ----------- |
| Framework | Flutter 3.3+ / Dart |
| Backend | Supabase (Postgres, Auth, Storage) |
| State | BLoC / Cubit |
| DI | GetIt |
| Testing | flutter_test, mocktail, bloc_test |

## Quick Start

→ [Getting Started Guide](guides/getting-started.md)

## Documentation Index

| Category | Path | Description |
| ---------- | ------ | ------------- |
| **Architecture** | | |
| Clean Architecture | [architecture/overview.md](architecture/overview.md) | Layer structure,dependency flow,folder mapping |
| **Domain** | | |
| E Catalog | [domain/entities.md](domain/entities.md) | 9 entities with fi... |
| **Features** | | |
| Auth | [../lib/features/auth/](../lib... | Login,register,session management |
| Books | [../lib/features/books/](../l... | Book CRUD,cover upload,visibility |
| Chapters | [../lib/features/chapters/](... | Chapter reading,content storage |
| Tooks | [../lib/features/tooks/](../lib/feat... | Volumes/tomes within books |
| Genres | [../lib/features/genres/](../lib/features... | Genre classification |
| Labels | [../lib/features/labels/](../lib/features/labels/) | Tagging system |
| Label Rules | [../lib/features/label_rules/](../lib/features/label_rules/) | Automatic label assignment rules, admin-managed |
| Profiles | [../lib/features/profiles/](..... | User profiles,role management |
| Favorites | [../lib/features/favorites/](../lib/feature... | Book favoriting |
| Admin | [../lib/features/admin/](../lib/features/admin/) | Admin dashboard |
| Scan | [../lib/features/scan/](../lib/features/scan/) | Content creation |
| App | [../lib/features/app/](../lib/features/app/) | Shell, routing, drawer (NavigationDrawer with AppDrawerHeader, DrawerSectionLabel, LogoutFooter, role-based menus), main screen sections (carousel, continuar leyendo, novedades, más vistos, populares, géneros) |
| **User Types** | | |
| Regular User | [user-types/regular-user.md](user-types/reg... | Default role |
| Scan User | [user-types/scan-user.md](user-types/s... | Content creator role |
| Admin User | [user-types/admin-user.md](user-types/adm... | Full access role |
| **Database** | | |
| Database Docs | [database/README.md](d... | Tables,storage,RLS,SQL functions |
| **Guides** | | |
| Getting Started | [guides/getting-started.md](gui... | Developer setup guide |
| **Testing** | | |
| Test Strategy | [testing/README.md](t... | 55 test files,categories,patterns |

## Project Structure

```text
lib/
├── core/              # Cross-cutting: DI, errors, Supabase client, theme, utils
├── features/          # 12 feature modules (domain/data/presentation each)
│   ├── admin/
│   ├── app/
│   ├── auth/
│   ├── books/
│   ├── chapters/
│   ├── favorites/
│   ├── genres/
│   ├── labels/
│   ├── label_rules/
│   ├── profiles/
│   ├── scan/
│   └── tooks/
├── shared/            # Shared entities and widgets across features
│   ├── domain/
│   └── presentation/
└── main.dart          # Entry point
```text

---

> Last verified: 2026-07-23
