# Deployment

> Build and deploy Noveles to Android, Web, and iOS — with Supabase production setup.

## Android

### Debug APK

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Release App Bundle (Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

**Signing**: Configure `android/app/build.gradle` with your keystore for release builds.

## Web

```bash
flutter build web --release
```

Output: `build/web/`

Serve with any static file server. For Supabase on web, ensure your project's auth redirect URLs include your deployment domain.

**Notes**:
- Web builds require proper CORS configuration in Supabase
- `flutter_native_splash` is not used on web
- `image_picker` may have limited functionality on web

## iOS

```bash
flutter build ipa --release
```

Output: `build/ios/ipa/`

**Requirements**:
- Xcode with valid signing certificate
- Configure bundle identifier in `ios/Runner.xcodeproj`
- Set up provisioning profiles for distribution

## Supabase Production Setup

### Database

```bash
supabase db push
```

Applies all migrations from `supabase/migrations/` to the remote database.

### Storage Buckets

Verify these buckets exist in your Supabase dashboard:

| Bucket | Purpose | Public |
|--------|---------|--------|
| `covers` | Book/took cover images | Yes |
| `chapters` | Chapter content files (.md, .txt) | No |
| `avatars` | User profile pictures | Yes |

### RPC Functions

Deploy the SQL functions used by the analytics feature:

- `get_views_trend(days_back)` — views trend data
- `get_top_books(limit_count)` — top viewed books
- `get_analytics_overview` — dashboard summary

See `docs/database/sql-functions.md` for function definitions.

### RLS Policies

Ensure Row-Level Security policies are active on all tables. See `docs/database/rls-policies.md` for the full policy list.

## Environment Variables

Create a production `.env` file at the project root:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

**Security**: Never commit `.env` to version control. The `.gitignore` already excludes it.

## Build Versioning

Update version in `pubspec.yaml` before each release:

```yaml
version: 1.1.0+1  # version+build_number
```

The build number auto-increments for Android; for iOS, set it explicitly in Xcode.

## Related

- [Getting Started](./getting-started.md) — Local development setup
- [Environment](../configuration/environment.md) — Environment variables
- [Dependencies](../configuration/dependencies.md) — Package versions
- [Database](../database/README.md) — Schema and migrations

← Back to [index](../README.md)
