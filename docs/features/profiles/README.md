# Profiles

> User profiles — display info, avatar upload, password change, and role management.

## Overview

The Profiles feature manages user profile data beyond authentication. It handles display name, bio, avatar upload, password changes, and admin-level role management (assigning roles, suspending users). The `UserEntity` is shared across the entire app as the canonical user representation.

## Data Model

**`UserEntity`** (`lib/features/profiles/domain/user_entity.dart`):

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Supabase Auth UUID |
| `email` | `String` | User email |
| `role` | `UserRole` | `user`, `scan`, `admin`, or `suspended` |
| `displayName` | `String?` | Display name |
| `bio` | `String?` | User bio |
| `avatarUrl` | `String?` | Avatar image path |

**Computed getters**: `isUser`, `isScan`, `isAdmin`, `isSuspended`

**`UserRole`** enum (`lib/features/profiles/domain/user_role.dart`): `user`, `scan`, `admin`, `suspended`

## Use Cases

| Use Case | Signature | Purpose |
|----------|-----------|---------|
| `GetProfile` | `Future<Result<UserEntity>> call()` | Get current user profile |
| `UpdateProfile` | `Future<Result<UserEntity>> call({String? displayName, String? bio, String? avatarUrl})` | Update profile fields |
| `UploadAvatar` | `Future<Result<String>> call(String filePath)` | Upload avatar to Storage |
| `ChangePassword` | `Future<Result<void>> call(String newPassword)` | Change account password |
| `GetAllProfiles` | `Future<Result<List<UserEntity>>> call({int limit, String? afterEmail})` | Admin: list all users (paginated) |
| `UpdateUserRole` | `Future<Result<UserEntity>> call({required String userId, required String role})` | Admin: change user role |

**Repository**: `ProfilesRepository` → `ProfilesRepositoryImpl` queries `profiles` table and Supabase Auth.

## BLoC

**`ProfileBloc`** (`lib/features/profiles/presentation/bloc/profile_bloc.dart`):

| Event | Description |
|-------|-------------|
| `LoadProfile` | Load current user profile |
| `UpdateProfile` | Update display name, bio, or avatar |
| `UploadAvatar` | Pick and upload avatar image |
| `ChangePassword` | Change account password |

| State | Data | When |
|-------|------|------|
| `ProfileInitial` | — | Initial |
| `ProfileLoading` | — | Processing |
| `ProfileLoaded` | `UserEntity profile` | Profile loaded |
| `ProfileError` | `String message` | Error |

## Screens

### ProfileScreen

**File**: `lib/features/profiles/presentation/screens/profile_screen.dart`

- View and edit display name, bio, avatar
- Password change section
- Avatar upload with image picker

### Widgets

**File**: `lib/features/profiles/presentation/screens/widgets/`

- Profile sub-components (avatar picker, form fields)

## DI Registration

**File**: `lib/core/di/injection_profiles.dart`

- `ProfilesRepository` → `LazySingleton`
- All use cases → `LazySingleton`
- `ProfileBloc` → `Factory`

## Related

- [Entities](../../domain/entities.md) — `UserEntity` field details
- [Use Cases](../../domain/use-cases.md) — Profile use case signatures
- [User Types](../../user-types/regular-user.md) — Profile editing
- [User Types](../../user-types/admin-user.md) — Role management
- [Database](../../database/tables.md) — `profiles` table schema
- [Error Handling](../../architecture/error-handling.md) — `ProfileFailure`

← Back to [index](../../README.md)
