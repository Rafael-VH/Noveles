# 📖 Noveles

**A multi-role novel reading platform** — read, create, and manage novels with
role-based access, built with Flutter + Supabase.

[![Flutter](https://img.shields.io/badge/Flutter-3.3%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3FCF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Tests](https://img.shields.io/badge/tests-388-passing-brightgreen)](docs/en/testing/README.md)
[![Español](https://img.shields.io/badge/🇪🇸-Español-green)](README.es.md)

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

```text
┌─────────────────────────────────┐
│       Presentation              │  BLoCs, Screens, Widgets
├─────────────────────────────────┤
│         Domain                  │  Entities, Use Cases, Repository interfaces
├─────────────────────────────────┤
│           Data                  │  Repository implementations, Supabase
└─────────────────────────────────┘
```

**Clean Architecture** with three layers. The domain layer is **pure Dart** —
no Flutter or Supabase imports. This makes entities and use cases testable
without any framework dependency.

### Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Frontend** | Flutter 3.3+ / Dart 3.3+ |
| **State Management** | BLoC + Cubit |
| **Dependency Injection** | GetIt (service locator) |
| **Backend** | Supabase (Postgres, Auth, Storage, Edge Functions) |
| **Testing** | flutter_test, mocktail, bloc_test |

### Project Structure

```text
lib/
├── core/              # Cross-cutting: DI, errors, Supabase client, theme, utils
├── features/          # 12 feature modules (domain/data/presentation each)
│   ├── admin/         # Dashboard, analytics, user management
│   ├── app/           # Shell, routing, NavigationDrawer, home screen
│   ├── auth/          # Login, register, session management
│   ├── books/         # Book CRUD, pagination, view tracking
│   ├── chapters/      # Chapter reading, content management
│   ├── favorites/     # Personal book favorites
│   ├── genres/        # Genre classification
│   ├── labels/        # Manual color-coded labels
│   ├── label_rules/   # Automatic label assignment rules
│   ├── profiles/      # User profiles, role management
│   ├── scan/          # Content creation panel
│   └── tooks/         # Volumes/tomes within books
├── shared/            # Shared entities and widgets
└── main.dart
```

## 🧪 Testing

**388 tests and counting** across all layers:

| Category | Count | What's Covered |
| :--- | :--- | :--- |
| BLoC Tests | 14 | All BLoCs — state transitions, event handling |
| Entity Tests | 5 | Construction, equality, copyWith |
| Repository Tests | 8 | Supabase queries, error mapping |
| Use Case Tests | 7 | Business logic, Result handling |
| Widget Tests | 20 | UI rendering, user interactions, role-based menus |
| **Total** | **55** | |

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

## 📚 Documentation

| Category | Path | Covers |
| :--- | :--- | :--- |
| **Architecture** | [docs/en/architecture/overview.md](docs/en/architecture/overview.md) | Clean Architecture layers, dependency flow |
| **Routing** | [docs/en/architecture/routing.md](docs/en/architecture/routing.md) | Role-based home selection, auth guard |
| **Theme** | [docs/en/architecture/theme.md](docs/en/architecture/theme.md) | Light/dark M3 theme, NavigationDrawer theme |
| **Database** | [docs/en/database/README.md](docs/en/database/README.md) | 13 tables, 35 migrations, RLS policies |
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

Built with ❤️ using Flutter & Supabase •
[English Documentation](docs/en/README.md) •
[Documentación en Español](docs/es/README.md)
