# Environment Configuration

> Required environment variables and setup for Supabase integration.

## Required Variables

| Variable | Purpose | Example |
| ---------- | --------- | --------- |
| `SUPABASE_URL` | Supabase project API URL | `https://xyzcompany.supabase.co` |
| SUPABASE_ANON_KEY | Supabase anonymous/public A... | eyJhbGciOiJIUzI1NiIs... |

## Setup

1. **Create `.env` file** in project root:

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```text

1. **Boot the backend** — `main.dart` calls one vendor-agnostic entry point:

```dart
await initializeBackend();
```text

That resolves the credentials and initializes the SDK. For release builds you can
skip the `.env` file entirely and pass the values at compile time —
`--dart-define` takes precedence:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
```text

**Source**: `lib/core/backend/supabase/supabase_config.dart` (credential
resolution) and `lib/core/backend/backend_module.dart` (boot and registrations),
so `main.dart` never names a vendor.

## Security

- `.env` is in `.gitignore` — never commit secrets to version control
- Use `.env.example` as a template (commit this file)
- The `!` operator in `dotenv.env['VAR']!` (inside `supabase_config.dart`) means
the app will crash if variables are missing — this is intentional to catch
misconfiguration early
- Supabase anon key is safe for client-side use (RLS policies enforce data
access)

## Common Issues

| Issue | Cause | Solution |
| ------- | ------- | ---------- |
| dotenv.env['SUPABASE_URL'] null | .env missing | Ensure .env in project root |
| SupabaseException on startup | Invalid URL or API key | Verify credential... |
| .env committed to git | Forgot .gitignore | Remove from trackin... |

← Back to [index](../README.md)
