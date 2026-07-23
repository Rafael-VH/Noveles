# Getting Started

> Step-by-step guide to clone, configure, and run the Noveles project locally.

← [Back to index](../README.md)

## Prerequisites

| Requirement | Version | Notes |
| ------------- | --------- | ------- |
| Flutter SDK | >=3.3.4 | Run `flutter --version` to check |
| Dart SDK | (bundled with Flutter) | |
| Supabase account | Free tier works | [supabase.com](https://supabase.com) |
| IDE | VS Code or Android Studio | Flutter/Dart extensions recommended |
| Android Studio / Xcode | Latest | For emulator/simulator |

## Clone & Install

```bash
git clone https://github.com/<owner>/Noveles.git
cd Noveles
flutter pub get
```text

## Environment Setup

Noveles uses `flutter_dotenv` for configuration. Create a `.env` file in the
project root:

```bash
cp .env.example .env
```text

> **Note**: `.env.example` does not exist yet. Create `.env` manually with the
following content:

```text
SUPABASE_URL=https://<your-project>.supabase.co
SUPABASE_ANON_KEY=<your-anon-key>
```text

**Where to find these values:**

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Go to **Settings → API**
4. Copy the **Project URL** and **anon public** key

### Security

The `.env` file is listed in `pubspec.yaml` assets (required for
`flutter_dotenv` loading) and should be in `.gitignore`. **Never commit your
`.env` file** with real credentials.

## Supabase Setup

If you have a local Supabase instance:

```bash
supabase db push
```text

This runs all migrations and sets up the database schema (tables, RLS policies,
storage buckets).

For a remote Supabase project, migrations are applied via the dashboard or
CI/CD.

## Run the App

```bash
flutter run
```text

Make sure a device or emulator is connected. For web:

```bash
flutter run -d chrome
```text

## Project Structure

```text
lib/
├── main.dart              # Entry point: dotenv → Supabase → DI → App
├── core/                  # Cross-cutting concerns
│   ├── app/               # App widget, routing
│   ├── di/                # GetIt dependency injection (11 modules)
│   ├── errors/            # `Result<T>`, Failure types
│   ├── supabase/          # Client provider, chapter cache
│   ├── constants/         # StorageConstants
│   ├── presentation/      # ThemeBloc, notifications, shared widgets
│   └── utils/             # Colors, theme, parsing, logging
├── features/              # 11 feature modules
│   ├── auth/              # Authentication (login, register)
│   ├── books/             # Book CRUD and display
│   ├── chapters/          # Chapter reading
│   ├── tooks/             # Volumes/tomes
│   ├── genres/            # Genre classification
│   ├── labels/            # Tagging system
│   ├── profiles/          # User profiles
│   ├── favorites/         # Book favoriting
│   ├── admin/             # Admin dashboard
│   ├── scan/              # Content creation
│   └── app/               # Shell (MainScreen, drawer)
└── shared/                # Cross-feature code
    ├── domain/entities/   # BookWithRelations
    └── presentation/      # Shared widgets
```text

Each feature module follows Clean Architecture:

```text
features/{feature}/
├── domain/     # Entities, use cases, repository interfaces
├── data/       # Repository implementations (Supabase)
└── presentation/  # BLoCs, screens, widgets
```text

## Running Tests

```bash
# Run all tests
flutter test

# Run with coverage report
flutter test --coverage

# Run a specific test file
flutter test test/bloc/auth_bloc_test.dart
```text

Test structure mirrors the lib/ folder: `test/bloc/`, `test/entities/`,
`test/repositories/`, `test/use_cases/`, `test/widgets/`.

## Common Issues

| Problem | Solution |
| --------- | ---------- |
| `Missing .env file` | Create `.env` with SUPABASE_URL and SUPABASE_ANON_KEY |
| `Supabase connection error` | Verify your URL and anon key are correct |
| `flutter pub get` fails | Run `flutter clean && flutter pub get` |
| Emulator not found | Open Android Studio → Device Manager → start an emul... |

---

> Last verified: 2026-07-21
