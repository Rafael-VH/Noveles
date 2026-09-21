# Dependencies

> Runtime and dev dependencies — categorized overview of all packages used.

## Overview

Noveles uses 14 runtime dependencies and 3 dev dependencies. All are managed via
`pubspec.yaml` with version constraints. The project targets Dart SDK `>=3.3.4
<4.0.0`.

## Runtime Dependencies

| Category | Package | Version | Purpose |
| ---------- | --------- | --------- | --------- |
| **State Management** | | | |
| | `bloc` | `^8.1.4` | BLoC pattern core |
| | `flutter_bloc` | `^8.1.6` | Flutter BLoC widgets |
| | `equatable` | `^2.0.5` | Value equality for states/events |
| **Backend** | | | |
| | `supabase_flutter` | `^2.10.0` | Supabase client (Auth, Database, Storage) — imported only inside `lib/core/backend/` |
| **Dependency Injection** | | | |
| | `get_it` | `^7.6.0` | Service locator / DI container |
| **UI** | | | |
| | `carousel_slider` | `^5.1.2` | Home screen book carousel |
| | `cached_network_image` | `^3.4.1` | Image caching for covers and avatars |
| **File Pickers** | | | |
| | `image_picker` | `^1.1.2` | Camera/gallery image selection |
| | `file_picker` | `^8.0.0` | Generic file selection (.md, .txt) |
| | `path_provider` | `^2.1.4` | Platform-specific file paths |
| **Configuration** | | | |
| | `flutter_dotenv` | `^6.0.1` | Environment variable loading from `.env` |
| **UX** | | | |
| | `flutter_native_splash` | `^2.4.1` | Native splash screen config |
| | `url_launcher` | `^6.3.1` | Open external URLs |

**Total**: 14 runtime dependencies

## Dev Dependencies

| Package | Version | Purpose |
| --------- | --------- | --------- |
| `flutter_test` | SDK | Unit and widget testing |
| `flutter_lints` | `^5.0.0` | Lint rules |
| `mocktail` | `^1.0.4` | Mock objects for testing |
| `bloc_test` | `^9.1.7` | BLoC-specific test helpers |

## Environment

The app loads environment variables via `flutter_dotenv`:

```yaml
flutter:
  assets:
    - .env
```text

Required environment variables (see `docs/configuration/environment.md`):

- `SUPABASE_URL` — Supabase project URL
- `SUPABASE_ANON_KEY` — Supabase anonymous API key

## Related

- [Getting Started](../guides/getting-started.md) — Setup instructions
- [Environment](./environment.md) — `.env` configuration
- [Deployment](../guides/deployment.md) — Build instructions
- [Testing](../testing/README.md) — Test setup with mocktail/bloc_test

← Back to [index](../README.md)
