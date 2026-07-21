# Auth

> Supabase Auth integration — login, register, logout, and session state management.

## Overview

The Auth feature handles authentication via Supabase Auth. It manages the full session lifecycle: email/password login, registration (which auto-creates a profile row in `profiles`), logout, and real-time auth state listening. The `AuthBloc` is a root-level provider that drives role-based routing in `App`.

## Use Cases

| Use Case | Signature | Purpose |
|----------|-----------|---------|
| `Login` | `Future<Result<UserEntity>> call(String email, String password)` | Sign in with email/password |
| `Register` | `Future<Result<UserEntity>> call(String email, String password)` | Create account + auto-create profile |
| `Logout` | `Future<Result<void>> call()` | Sign out current session |
| `GetCurrentUser` | `Future<Result<UserEntity?>> call()` | Get current session user (null if unauthenticated) |
| `ListenAuthState` | `Stream<AuthEvent> call()` | Stream of `signedIn`, `signedOut`, `tokenRefreshed`, `userChanged` |

**Repository**: `AuthRepository` → `AuthRepositoryImpl` uses `SupabaseClientProvider` to call `signInWithPassword`, `signUp`, `signOut`, and `onAuthStateChange`. On login/register, it fetches (or auto-creates) the `profiles` row.

## BLoC

**`AuthBloc`** (`lib/features/auth/presentation/bloc/auth_bloc.dart`):

| Event | Description |
|-------|-------------|
| `CheckAuthSession` | Check if a session exists on app start |
| `LoginRequested` | Perform login with email/password |
| `RegisterRequested` | Perform registration with email/password |
| `LogoutRequested` | Perform logout |

| State | Data | When |
|-------|------|------|
| `AuthInitial` | — | App start |
| `AuthLoading` | — | Processing auth request |
| `AuthAuthenticated` | `UserEntity user` | Session active |
| `AuthUnauthenticated` | — | No session |
| `AuthError` | `String message` | Auth failure |

The BLoC also listens to `ListenAuthState` stream and auto-dispatches `LogoutRequested` on external sign-out events (e.g., token expiration).

## Screens

### LoginScreen

**File**: `lib/features/auth/presentation/screens/login_screen.dart`

- Email + password form with validation
- Navigation to register screen
- Shows error snackbar on failure

### RegisterScreen

**File**: `lib/features/auth/presentation/screens/register_screen.dart`

- Email + password registration form
- Auto-creates profile row with `user` role

## DI Registration

**File**: `lib/core/di/injection_auth.dart`

- `AuthRepository` → `LazySingleton` (via `AuthRepositoryImpl`)
- `Login`, `Register`, `Logout`, `GetCurrentUser`, `ListenAuthState` → `LazySingleton` each
- `AuthBloc` → `Factory`

## Related

- [Entities](../../domain/entities.md) — `UserEntity` fields (from profiles feature)
- [Use Cases](../../domain/use-cases.md) — Auth use case signatures
- [User Types](../../user-types/regular-user.md) — Role-based access
- [Error Handling](../../architecture/error-handling.md) — `AuthFailure`, `ProfileFailure`
- [Routing](../../architecture/routing.md) — Role-based home screen selection

← Back to [index](../../README.md)
