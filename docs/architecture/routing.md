# Routing

> Role-based home screen selection, named routes, and auth guard behavior.

## Overview

Noveles uses a **role-based routing** pattern rather than a traditional route table. The `App` widget (`lib/core/app/app.dart`) listens to `AuthBloc` state and renders the appropriate home screen based on the authenticated user's role. There are only two named routes; all other navigation is imperative.

## Routing Table

| Route | Widget | Access | Type |
|-------|--------|--------|------|
| `/admin` | `AdminDashScreen` | Admin only | Named route |
| `/label-management` | `LabelManagementScreen` | Scan + Admin | Named route |
| Home (default) | Role-dependent | All roles | `home:` parameter |

All other screens use imperative `Navigator.push(MaterialPageRoute(...))`.

## Auth Guard

The app does **not** use a middleware-based auth guard. Instead, the `BlocBuilder<AuthBloc, AuthState>` in `App.build()` acts as the guard:

```
AuthLoading → CircularProgressIndicator
AuthAuthenticated → Role-based home screen
AuthUnauthenticated → LoginScreen
AuthError → LoginScreen (with snackbar)
```

**Suspended users**: A user with `role == UserRole.suspended` does not match `isAdmin`, `isScan`, or `isUser`, so they fall through to the `return const LoginScreen()` fallback. The auth error snackbar displays the failure message. This effectively blocks suspended users from accessing any screen.

## Role Routing Logic

The routing decision tree in `app.dart`:

```
if (authState is AuthAuthenticated)
  ├── user.isAdmin    → AdminDashScreen
  ├── user.isScan     → ScanMainScreen
  ├── user.isUser     → MainScreen
  └── else            → LoginScreen  (suspended / unknown role)
else
  └── LoginScreen
```

**Order matters**: `isAdmin` is checked first, then `isScan`, then `isUser`. This means an admin always gets the admin panel even if they somehow also have other role flags.

## Named Route Registration

Defined in `MaterialApp.routes`:

```dart
routes: {
  '/label-management': (_) => const LabelManagementScreen(),
  '/admin': (_) => const AdminDashScreen(),
},
```

Navigated via `Navigator.pushNamed(context, '/admin')` from the drawer.

## App-Level BLoC Providers

`App` provides two root-level BLoCs:

| BLoC | Scope | Purpose |
|------|-------|---------|
| `ThemeBloc` | Global | Theme state (light/dark) |
| `AuthBloc` | Global | Auth session + role routing |

The `AuthBloc` is created from GetIt (`getIt<AuthBloc>()`) and dispatched `CheckAuthSession` immediately.

## Error Handling

`BlocListener<AuthBloc, AuthState>` in `App` listens for `AuthError` states and shows a `SnackBar` with the error message and error color scheme. This provides feedback for failed session checks without leaving the current screen.

## Related

- [App Feature](../features/app/README.md) — MainScreen, AppDrawer details
- [Auth Feature](../features/auth/README.md) — AuthBloc and session management
- [Theme](./theme.md) — ThemeBloc integration
- [User Types](../user-types/regular-user.md) — Regular user home screen
- [User Types](../user-types/scan-user.md) — Scan user home screen
- [User Types](../user-types/admin-user.md) — Admin home screen

← Back to [index](../README.md)
