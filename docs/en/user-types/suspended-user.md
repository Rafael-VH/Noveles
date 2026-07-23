# Suspended User

> Blocked access — cannot browse or interact with the app.

## Role Overview

`UserRole.suspended` is a blocked state where the user cannot access any app
functionality. Suspended users are prevented from logging in or performing any
actions. The role is reversible — an admin can reactivate a suspended user.

**Enum value**: `UserRole.suspended`

**Source**: `lib/features/profiles/domain/user_role.dart`

## Database

The `profiles` table has a `role` column with a `CHECK` constraint that includes
`'suspended'`:

```sql
CHECK (role IN ('user', 'scan', 'admin', 'suspended'))
```text

**Source**: Database migration schema

## App Behavior

When a suspended user attempts to log in:

1. **AuthBloc** receives `AuthAuthenticated` with `user.isSuspended == true`
2. **Routing logic** in `lib/core/app/app.dart` checks roles in order:

   ```dart
   if (authState.user.isAdmin) { return AdminDashScreen(); }
   if (authState.user.isScan) { return ScanMainScreen(); }
   if (authState.user.isUser) { return MainScreen(); }
   return LoginScreen(); // Falls through for suspended
   ```

1. **Result**: Suspended users see `LoginScreen` again (no navigation to any
screen)
2. **No error message** is shown — the user simply cannot proceed

**Note**: The routing does not explicitly check `isSuspended`. Since `isUser`
returns `false` for suspended users, they fall through to the default
`LoginScreen`.

## Admin Action

Admins can suspend users via the `AdminUsersBloc`:

| Event | Description |
| ----- | ----------- |
| `SuspendUser` | Toggles suspension for a target user |

**Process**:

1. Admin opens Users tab in admin dashboard
2. Clicks suspend button on a user
3. `AdminUsersBloc._onSuspendUser()` determines current state:
   - If user is currently active (`UserRole.user`) → sets role to
     `UserRole.suspended`
   - If user is currently suspended → sets role back to `UserRole.user`
     (reactivation)
4. Calls `UpdateUserRole` use case with the new role
5. Reloads user list and shows confirmation message

**Restrictions**:

- Admins cannot suspend themselves (`'No puedes suspenderte a ti mismo'`)
- Target user ID is validated against `currentUserId`

**Source**: `lib/features/admin/presentation/bloc/admin_users_bloc.dart`

## Related

- [Regular User](regular-user.md) — Default active role
- [Admin User](admin-user.md) — Who can suspend users
- [User Role Enum](../../architecture/overview.md) — Role definitions

← Back to [index](../README.md)
