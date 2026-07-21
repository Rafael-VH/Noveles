# Environment Configuration

> Required environment variables and setup for Supabase integration.

## Required Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `SUPABASE_URL` | Supabase project API URL | `https://xyzcompany.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase anonymous/public API key | `eyJhbGciOiJIUzI1NiIs...` |

## Setup

1. **Create `.env` file** in project root:

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

2. **Load in `main.dart`** using `flutter_dotenv`:

```dart
await dotenv.load(fileName: '.env');
```

3. **Initialize Supabase** with environment variables:

```dart
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

**Source**: `lib/main.dart`

## Security

- `.env` is in `.gitignore` — never commit secrets to version control
- Use `.env.example` as a template (commit this file)
- The `!` operator in `dotenv.env['VAR']!` means the app will crash if variables are missing — this is intentional to catch misconfiguration early
- Supabase anon key is safe for client-side use (RLS policies enforce data access)

## Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| `dotenv.env['SUPABASE_URL']` is `null` | `.env` file missing or not loaded | Ensure `.env` exists in project root and `dotenv.load()` runs before `Supabase.initialize()` |
| `SupabaseException` on startup | Invalid URL or API key | Verify credentials in Supabase dashboard → Settings → API |
| `.env` committed to git | Forgot to add to `.gitignore` | Remove from tracking: `git rm --cached .env` |

← Back to [index](../README.md)