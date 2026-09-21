# 📖 Noveles

**A multi-role novel reading platform** — read, create, and manage novels with
role-based access, built with Flutter + Supabase.

[![Flutter](https://img.shields.io/badge/Flutter-3.3%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3FCF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Tests](https://img.shields.io/badge/tests-506%20passing-brightgreen)](docs/en/testing/README.md)
[![Diagramas interactivos](https://img.shields.io/badge/Diagramas%20interactivos-ver%20online-26a69a?logo=githubpages&logoColor=white)](https://rafael-vh.github.io/Noveles/diagrams/)

---

**🌐 Idioma / Language**: [🇪🇸 Español](docs/README.es.md)

> 📚 [Full documentation](docs/en/README.md)

---

## 🎯 What Is Noveles?

Noveles is a full-featured mobile application for reading and managing digital
novels. It supports **three user roles** — each with a tailored experience:

| Role | Experience |
| :--- | :--- |
| **👤 Reader** | Browse, read, track progress, manage favorites |
| **✍️ Scan** | Create & manage books, tooks, chapters, labels |
| **🛡️ Admin** | Analytics, users, visibility, genres, labels, rules |

> Suspended users are blocked at the auth level — no access to any screen.

## ✨ Features

### 📚 For Readers

- **Smart home feed** — carousel of featured books, "Continuar leyendo"
  (recent reads), novedades (new arrivals), más vistos (most viewed),
  populares (top rated), and genre-based browsing
- **Infinite scroll** — paginated book list that loads as you scroll
- **Reading tracking** — chapters marked as read, visual indicators in the
  took list
- **Favorites** — personal book list with one-tap toggle
- **Role-based drawer** — M3 NavigationDrawer with sections tailored to your
  role
- **Light/Dark theme** — toggle between modes (defaults to dark)

### 🖋️ For Creators (Scan)

- **Full book CRUD** — create, edit, delete books with cover image upload
- **Volume management** — organize books into tooks (volumes) with their own
  covers
- **Chapter editor** — inline content editing or file upload (.md, .txt)
- **Label system** — create color-coded labels and assign them to books

### 🛠️ For Admins

- **Analytics dashboard** — view trends, top books, and overview stats with
  daily data
- **User management** — change roles (user/scan/admin), suspend/reactivate
  accounts
- **Book oversight** — toggle visibility, delete inappropriate content
- **Genre & Label management** — full CRUD for metadata
- **Auto-labeling rules** — configure rules that automatically assign labels
  based on book data (new releases, most read, most popular, most favorited)

## 🏗️ Architecture at a Glance

<img align="center" alt="NovelEs — Arquitectura Completa" src="docs/diagrams/overview/architecture.svg">

> **Gran Novedad** - el [dashboard de diagramas interactivos](https://rafael-vh.github.io/Noveles/diagrams/) esta online: pan/zoom, busqueda, temas claro/oscuro, rutas y export a PNG/SVG. Agregar un diagrama = crear su HTML en docs/diagrams/<dominio>/ y sumar una entrada al manifest.json.

> 🔍 **¿Querés explorarla?** Abrí la [versión interactiva](https://rafael-vh.github.io/Noveles/diagrams/) —
> pan/zoom, temas claro/oscuro, búsqueda, seguimiento de rutas y export a PNG/SVG.

**Clean Architecture** with three layers. The domain layer is **pure Dart** —
no Flutter or Supabase imports. This makes entities and use cases testable
without any framework dependency.

### Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Frontend** | Flutter 3.3+ / Dart 3.3+ |
| **State Management** | BLoC + Cubit |
| **Dependency Injection** | GetIt (service locator) |
| **Backend** | Supabase (Postgres, Auth, Storage, Edge Functions), reached only through the ports in `lib/core/backend/` |
| **Testing** | flutter_test, mocktail, bloc_test |

### Project Structure

```text
lib/
├── core/              # Cross-cutting: DI, errors, backend ports, theme, utils
├── features/          # 10 feature modules (domain/data/presentation each)
│   ├── admin/         # Dashboard, analytics, user management
│   ├── app/           # Shell, routing, NavigationDrawer, home screen
│   ├── auth/          # Login, register, session management
│   ├── books/         # Book CRUD, pagination, view tracking, favorites
│   ├── chapters/      # Chapter reading, content management
│   ├── genres/        # Genre classification
│   ├── labels/        # Manual color-coded labels + automatic rules
│   ├── profiles/      # User profiles, role management
│   ├── scan/          # Content creation panel
│   └── tooks/         # Volumes/tomes within books
├── shared/            # Shared entities and widgets
└── main.dart
```

## 🧪 Testing

**506 tests, all passing**, spread over 65 files:

| Category | Files | What's Covered |
| :--- | :--- | :--- |
| Architecture | 1 | The backend seam — fails if a feature reaches past the ports |
| BLoC Tests | 16 | All BLoCs — state transitions, event handling |
| Entity Tests | 5 | Construction, equality, copyWith |
| Repository Tests | 9 | Gateway queries, error mapping, ownership stamping |
| Use Case Tests | 7 | Business logic, Result handling |
| Widget Tests | 27 | UI rendering, user interactions, role-based menus |
| **Total** | **65 files** | **506 tests** |

```bash
flutter test        # Run all tests
flutter test --coverage   # With coverage report
```

## 🚀 Quick Start

```bash
# Prerequisites: Flutter 3.3+, Supabase account
git clone https://github.com/<your-org>/Noveles.git
cd Noveles
flutter pub get
```

Create a `.env` file:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Run migrations:

```bash
supabase db push
```

Run the app:

```bash
flutter run
```

> Full setup guide →
> [docs/en/guides/getting-started.md](docs/en/guides/getting-started.md)

## 🔌 Bringing Your Own Database

Noveles reaches Supabase through three **ports**. Nothing above
`lib/core/backend/` knows which backend is underneath, so swapping the database
— for another Postgres, or for something else entirely — is a bounded change
instead of a rewrite.

### The seam

```text
lib/features/*/data/*_repository_impl.dart   ← imports only the ports
              │
              ▼  ports
lib/core/backend/
  data_gateway.dart      DataGateway + DbQuery
  auth_gateway.dart      AuthGateway + AuthIdentityEvent
  storage_gateway.dart   StorageGateway
  auth_identity.dart     AuthIdentity
  backend_module.dart    ← the single place that picks an implementation
              │
              ▼  adapter
  supabase/              the only code that imports supabase_flutter
```

[`test/architecture/backend_seam_test.dart`](test/architecture/backend_seam_test.dart)
guards the invariant: it fails the build if a feature file imports the backend
SDK, names a vendor type, or uses embedded-resource syntax. Without it, the next
feature quietly re-couples the app.

### The recipe

1. **Write three adapters.** Implement `DataGateway`, `AuthGateway` and
   `StorageGateway` against your backend. Object storage is a separate port on
   purpose: moving the database and moving storage are independent decisions.
2. **Register them.** `lib/core/backend/backend_module.dart` is the composition
   root — swap `initializeBackend()` and `registerBackendDependencies()` there
   and nowhere else.
3. **Implement the six named aggregate reads.** Relationships (a book with its
   authors, genres, labels, tooks and chapters) cannot be expressed portably, so
   they are *named* on `DataGateway` instead of leaking one backend's join
   syntax into every repository. Keep the row shape the models already parse —
   whether that is one join or N+1 queries is your call.
4. **Recreate the schema and the authorization.** The app delegates
   authorization to the database: `getBooks` does not filter by user, the RLS
   policies do. Port all of it, or you end up with a working app that has no
   security:
   - the tables and columns →
     [docs/en/database/tables.md](docs/en/database/tables.md)
   - the server-side functions the app calls → `create_book_with_relations`,
     `update_book_with_relations`, `get_user_recent_views`,
     `get_most_viewed_books_public`, `get_analytics_overview`,
     `get_views_trend`, `get_top_books`, `admin_suspend_user`,
     `admin_reactivate_user`
   - the RLS policies →
     [docs/en/database/rls-policies.md](docs/en/database/rls-policies.md)
   - the three storage buckets → `covers`, `chapters`, `avatars`
5. **Point the config at your project.**
   `lib/core/backend/supabase/supabase_config.dart` reads `SUPABASE_URL` and
   `SUPABASE_ANON_KEY` (dart-define or `.env`); your adapter reads your own keys.

### What does not change

`domain/`, `presentation/`, the use cases, the BLoCs, the DI wiring and the test
suite. The repository tests talk to the ports rather than to a vendor, so they
keep passing against any adapter.

### The identity trap

`DataGateway` is identity-aware on purpose (`as(identity)` and `identity`). An
adapter that opens a single connection with a service role would bypass every
RLS policy by construction — authorization would be silently gone. Propagate the
acting identity on every request.

## 📚 Documentation

| Category | Path | Covers |
| :--- | :--- | :--- |
| **Architecture** | [docs/en/architecture/overview.md](docs/en/architecture/overview.md) | Clean Architecture layers, dependency flow |
| **Routing** | [docs/en/architecture/routing.md](docs/en/architecture/routing.md) | Role-based home selection, auth guard |
| **Theme** | [docs/en/architecture/theme.md](docs/en/architecture/theme.md) | Light/dark M3 theme, NavigationDrawer theme |
| **Database** | [docs/en/database/README.md](docs/en/database/README.md) | 13 tables, 48 migrations, RLS policies |
| **Entities** | [docs/en/domain/entities.md](docs/en/domain/entities.md) | All 10 domain entities with field definitions |
| **Use Cases** | [docs/en/domain/use-cases.md](docs/en/domain/use-cases.md) | 54 use cases across all features |
| **User Types** | [docs/en/user-types/](docs/en/user-types/) | Permissions per role (admin, scan, user, suspended) |
| **Testing** | [docs/en/testing/README.md](docs/en/testing/README.md) | Test strategy, patterns, coverage gaps |

## 🗺️ Role-Based Routing

The app selects the appropriate home screen based on the authenticated user's
role:

```text
AuthAuthenticated
├── isAdmin    → AdminDashScreen  (full management)
├── isScan     → ScanMainScreen   (content creation)
├── isUser     → MainScreen       (reading experience)
└── else       → LoginScreen      (suspended / unknown)
```

Named routes:

- `/admin` — admin dashboard
- `/label-management` — label management (scan + admin)

All other navigation is imperative via `Navigator.push`.

## 🤝 Contributing

Contributions are welcome! The project follows Clean Architecture with strict
dependency rules:

1. **Domain layer** must have zero framework imports (pure Dart)
2. **Features** are organized in three layers: `domain/`, `data/`,
   `presentation/`
3. **All use cases** return `Result<T>` — no exceptions for control flow
4. **Tests** are expected for BLoCs, entities, and repositories

See the full [architecture overview](docs/en/architecture/overview.md) before
contributing.

## 📄 License

This project is private. All rights reserved.

---

Built with ❤️ using Flutter & Supabase
