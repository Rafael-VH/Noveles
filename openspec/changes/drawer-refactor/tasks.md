# Tasks: drawer-refactor

> Implementation tasks for the drawer visual redesign. Based on proposal at `proposal.md`, spec at `spec.md`, and design at `design.md`.

---

## Task list

### Task 1: Theme — Add `NavigationDrawerThemeData`

**Files**:
- `lib/core/utils/theme/light_theme.dart`
- `lib/core/utils/theme/dark_theme.dart`

**What**: Add `navigationDrawerTheme` to both theme definitions, following the same pattern as the existing `navigationBarTheme`.

**Implementation details**:
- Insert after `navigationBarTheme` block in each file (line ~151 in light, line ~99 in dark)
- Use `_LightColor` / `DarkColor` color constants (same as other theme sections)
- Set `backgroundColor` to `surface`, `indicatorColor` to `primaryContainer`
- Set `indicatorShape` to `RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))`
- Set `tileHeight` to `56`
- Add `labelTextStyle` with `WidgetStateProperty.resolveWith` — `FontWeight.w600` when selected, `FontWeight.w400` when not, using `onSurface` / `onSurfaceVariant`
- Add `iconTheme` with `WidgetStateProperty.resolveWith` — `primary` when selected, `onSurfaceVariant` when not

**Acceptance criteria**:
- `dart analyze` passes with zero errors
- Theme compiles and `NavigationDrawerThemeData` is discoverable via `Theme.of(context).navigationDrawerTheme`
- NavigationDrawer destinations show round pill indicator (radius 12) on selection
- Indicator uses `primaryContainer` color
- Tile height is 56px
- Selected label is `w600`, unselected is `w400`
- Selected icon uses `primary` color, unselected uses `onSurfaceVariant`

**Dependencies**: None

**Est. lines**: +30 total (+15 per file)

---

### Task 2: Create `AppDrawerHeader` widget

**File**: `lib/features/app/presentation/widgets/drawer/app_drawer_header.dart` (NEW)

**What**: Extract the drawer header into its own widget. Handles both authenticated (gradient + avatar + name + email) and simplified unauthenticated states.

**Implementation details**:
- `AppDrawerHeader({required UserEntity user, super.key, this.isSimplified = false})` — primary constructor
- `AppDrawerHeader.simplified({super.key})` — named constructor for unauthenticated state
- Widget is a `StatelessWidget`
- Container with fixed height 192px, `LinearGradient` from `primary` → `primaryContainer`, `BoxShadow` with `shadow` at 15% alpha, blur 8, offset (0, 2)
- Padding: 24px all around
- `Column` with `crossAxisAlignment: CrossAxisAlignment.start`, `mainAxisAlignment: MainAxisAlignment.end`
- CircleAvatar radius 24 (48px diameter): `NetworkImage(getIt<CoverUrlService>()(user.avatarUrl!))` if avatarUrl not empty, fallback `Icon(Icons.person, size: 32)`
- Name text: `user.displayName ?? user.email` in `titleLarge`, `onPrimary` color
- Email text: `user.email` in `bodySmall`, `onPrimary` at 80% alpha (via `withValues(alpha: 0.8)`)
- Simplified variant: shows app name "Noveles" in `titleLarge` centered, no avatar, no email, gradient uses surface/neutral tones

**Imports needed**:
- `package:flutter/material.dart`
- `package:noveles/features/profiles/domain/user_entity.dart`
- `package:noveles/core/cover/cover_url_service.dart`
- `package:noveles/core/di/injection.dart`

**Acceptance criteria**:
- Widget renders gradient background using `primary` → `primaryContainer`
- CircleAvatar is 48px diameter (radius 24)
- Avatar loads via `CoverUrlService` when `avatarUrl` is non-empty
- Fallback shows `Icons.person` icon when `avatarUrl` is empty/null
- Name shows `displayName ?? email` in `titleLarge`
- Email shows in `bodySmall` with 80% opacity
- Simplified constructor renders "Noveles" text without user data
- Widget compiles with zero analysis errors

**Dependencies**: None (depends only on existing `UserEntity`, `CoverUrlService`, `getIt`)

**Est. lines**: ~65

---

### Task 3: Create `DrawerSectionLabel` widget

**File**: `lib/features/app/presentation/widgets/drawer/drawer_section_label.dart` (NEW)

**What**: Simple label widget for drawer section headers.

**Implementation details**:
- `DrawerSectionLabel(this.label, {super.key})` — single required `String label`
- `StatelessWidget`
- Padding: `EdgeInsets.fromLTRB(28, 16, 28, 4)` — generous top space to separate sections
- `Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))`
- ~15 lines total, no interaction logic

**Acceptance criteria**:
- Widget renders the label string
- Style is `labelSmall` typography
- Color is `onSurfaceVariant`
- Padding matches spec (top 16, bottom 4, horizontal 28)
- Widget compiles with zero analysis errors

**Dependencies**: None

**Est. lines**: ~15

---

### Task 4: Create `LogoutFooter` widget

**File**: `lib/features/app/presentation/widgets/drawer/logout_footer.dart` (NEW)

**What**: Logout button with error styling, always at the bottom of the drawer. Receives a `VoidCallback` that the parent wires to `showConfirmationDialog`.

**Implementation details**:
- `LogoutFooter({required this.onLogout, super.key})` — single required `VoidCallback onLogout`
- `StatelessWidget`
- `Column(mainAxisSize: MainAxisSize.min)` with `Divider` + `ListTile`
- ListTile: `leading: Icon(Icons.logout, error color)`, `title: Text('Cerrar Sesión', error color)`, `onTap: onLogout`
- Both icon and text use `theme.colorScheme.error`
- Padding: `EdgeInsets.only(bottom: 16)` on the column
- The `onLogout` callback will be wired in Task 5 to call `showConfirmationDialog`

**Acceptance criteria**:
- Widget renders a divider followed by a logout ListTile
- Logout icon and text use `colorScheme.error`
- Tapping invokes the `onLogout` callback
- Widget compiles with zero analysis errors

**Dependencies**: None (callback pattern — `showConfirmationDialog` is used in the parent, not here)

**Est. lines**: ~35

---

### Task 5: Refactor `AppDrawer` — replace `Drawer` with `NavigationDrawer`

**File**: `lib/features/app/presentation/widgets/app_drawer.dart` (REWRITE)

**What**: Complete rewrite of the drawer. Replace `Drawer` + `ListView` + `ListTile` with `NavigationDrawer` + `NavigationDrawerDestination`. Replace boolean props with `UserRole?`. Extract inline code into the new drawer widgets.

**Constructor change**:
```dart
// BEFORE
class AppDrawer extends StatelessWidget {
  final bool isScan;
  final bool isAdmin;
}

// AFTER
class AppDrawer extends StatelessWidget {
  final UserEntity? user;
  final UserRole? role;
}
```

**Implementation details**:
- `DrawerItem` enum with: `home`, `panelScan`, `panelAdmin`, `editProfile`, `favorites`, `labels`, `login`
- Role→items static maps: `_navItemsForRole`, `_profileItemsForRole`, `_managementItems` (scan only)
- `_itemConfig(DrawerItem item)` returns `({IconData icon, String label, VoidCallback action})` via `switch`
- `BlocBuilder<AuthBloc, AuthState>` wrapping (same as today)
- Resolves effective user/role: `user ?? (authState is AuthAuthenticated ? authState.user : null)`, `role ?? effectiveUser?.role`
- **CRITICAL**: `NavigationDrawer` uses `selectedIndex` / `onDestinationSelected` — NOT `onTap` on each destination. Build a flat list of visible destinations (excluding section labels, Spacer, and LogoutFooter), pass `onDestinationSelected: (index) => flatList[index].action()`.
- Set default `selectedIndex` based on role: 0 for all roles (first item is always the main nav item — Inicio/Panel Scan/Panel Admin)
- Tree structure:
  ```
  NavigationDrawer
  ├── AppDrawerHeader (authenticated) or AppDrawerHeader.simplified (unauthenticated)
  │
  ├── DrawerSectionLabel("Navegación") + destinations  ← if role has nav items
  ├── DrawerSectionLabel("Perfil") + destinations      ← if authenticated
  ├── DrawerSectionLabel("Gestión") + destinations      ← if scan role
  │
  ├── (login destination)                              ← if unauthenticated
  ├── Spacer                                           ← always
  └── LogoutFooter                                     ← if authenticated
  ```
- `_confirmLogout(context)`: calls `showConfirmationDialog(context, title: 'Cerrar Sesión', message: '¿Estás seguro de que deseas cerrar sesión?', confirmLabel: 'Cerrar Sesión', isDestructive: true)`, then dispatches `context.read<AuthBloc>().add(const LogoutRequested())` on confirm
- Navigation actions: all must `Navigator.pop(context)` first before pushing routes
- `UserRole.suspended`: treated as authenticated for header + profile section, but no nav section items (profile items include only editProfile)

**Imports needed**:
- `package:flutter/material.dart`
- `package:flutter_bloc/flutter_bloc.dart`
- `package:noveles/core/cover/cover_url_service.dart` (still needed for avatar in header via AppDrawerHeader)
- `package:noveles/core/di/injection.dart`
- `package:noveles/features/auth/presentation/bloc/auth_bloc.dart`
- `package:noveles/features/profiles/domain/user_entity.dart`
- `package:noveles/features/profiles/domain/user_role.dart`
- `package:noveles/features/favorites/presentation/bloc/favorite_bloc.dart`
- `package:noveles/features/favorites/presentation/screens/favorites_screen.dart`
- `package:noveles/features/labels/presentation/screens/label_management_screen.dart`
- `package:noveles/features/profiles/presentation/screens/profile_screen.dart`
- `package:noveles/shared/presentation/widgets/confirmation_dialog.dart`
- `package:noveles/features/app/presentation/widgets/drawer/app_drawer_header.dart`
- `package:noveles/features/app/presentation/widgets/drawer/drawer_section_label.dart`
- `package:noveles/features/app/presentation/widgets/drawer/logout_footer.dart`

**Acceptance criteria**:
- `dart analyze` passes with zero errors
- Drawer uses `NavigationDrawer` (not `Drawer`)
- Destinations use `NavigationDrawerDestination` (not `ListTile`)
- Constructor accepts `UserEntity? user` and `UserRole? role` (not `isScan` / `isAdmin`)
- Reader role shows: Inicio (selected), Editar Perfil, Mis Favoritos, Cerrar Sesión
- Scan role shows: Panel Scan (selected), Editar Perfil, Etiquetas, Cerrar Sesión
- Admin role shows: Panel Admin (selected), Editar Perfil, Cerrar Sesión
- Suspended role shows: header + Editar Perfil + Cerrar Sesión, no nav items
- Unauthenticated shows: simplified header + Iniciar Sesión
- Logout shows confirmation dialog on tap, dispatches `LogoutRequested` on confirm
- Navigation preserves existing behavior: all actions pop drawer first, then push routes
- Favorites screen wrapped in `BlocProvider<FavoriteBloc>`
- `selectedIndex` = 0 by default (main nav item per role)

**Dependencies**: Task 1 (theme), Task 2 (header), Task 3 (section label), Task 4 (logout footer)

**Est. lines**: ~180

---

### Task 6: Update call sites

**Files**:
- `lib/features/app/presentation/screens/main_screen.dart`
- `lib/features/admin/presentation/screens/admin_dash_screen.dart`
- `lib/features/scan/presentation/screens/scan_main_screen.dart`

**What**: Update the three call sites to pass `UserRole?` instead of `isScan`/`isAdmin` booleans.

**Changes**:

**`main_screen.dart` (line 111-114)**:
```dart
// BEFORE
return AppDrawer(
  isScan: user?.isScan ?? false,
  isAdmin: user?.isAdmin ?? false,
);

// AFTER
return AppDrawer(user: user, role: user?.role);
```

**`admin_dash_screen.dart` (line 36)**:
```dart
// BEFORE
drawer: const AppDrawer(isAdmin: true),

// AFTER
drawer: AppDrawer(role: UserRole.admin),
```
Remove `const` since `UserRole.admin` is a runtime value (enum comparison is constant but the constructor itself can be const if we use `const` keyword with the enum).

Actually, we can keep `const`:
```dart
drawer: const AppDrawer(role: UserRole.admin),
```
Yes, `UserRole.admin` is a constant.

**`scan_main_screen.dart` (line 52)**:
```dart
// BEFORE
drawer: const AppDrawer(isScan: true),

// AFTER
drawer: const AppDrawer(role: UserRole.scan),
```

**Acceptance criteria**:
- All three files compile with zero analysis errors
- `main_screen.dart` passes `user: user, role: user?.role`
- `admin_dash_screen.dart` passes `role: UserRole.admin` (const)
- `scan_main_screen.dart` passes `role: UserRole.scan` (const)
- Drawer renders correctly for each role when the app runs

**Dependencies**: Task 5 (new `AppDrawer` constructor)

**Est. lines**: ~9 changed total

---

### Task 7: Verify and clean up

**Files**: All files from tasks 1-6

**What**: Final verification pass. Remove any unused imports, run static analysis, run tests.

**Checklist**:
- [ ] `CoverUrlService` import check in `app_drawer.dart` — keep it, it's used by `AppDrawerHeader` via `getIt` inside the header widget (not directly in `app_drawer.dart`)
- [ ] Remove any unused imports across all changed files
- [ ] Run `dart analyze lib/` — zero errors
- [ ] Run `flutter test` — existing tests pass (no regressions)
- [ ] Run `dart format lib/` — formatting is clean

**Acceptance criteria**:
- `dart analyze` reports zero errors
- `flutter test` passes existing tests
- No unused imports remain

**Dependencies**: Task 5, Task 6

**Est. lines**: 0 (cleanup only)

---

## Dependency graph

```
Task 1 (theme)          ───┐
Task 2 (header)         ───┤
Task 3 (section label)  ───┤──→ Task 5 (main drawer) ──→ Task 6 (call sites) ──→ Task 7 (verify)
Task 4 (logout footer)  ───┘
```

- Tasks 1, 2, 3, 4 are independent and can be done in parallel
- Task 5 depends on all four preceding tasks
- Task 6 depends on Task 5
- Task 7 depends on Tasks 5 and 6

---

## Acceptance criteria per task (summary)

| Task | Key acceptance |
|------|----------------|
| T1 | `NavigationDrawerThemeData` in both themes, pill indicator radius 12, tileHeight 56, indicatorColor primaryContainer |
| T2 | `AppDrawerHeader` renders gradient + 48px avatar + name/email; `.simplified()` shows "Noveles" without user data |
| T3 | `DrawerSectionLabel` renders labelSmall + onSurfaceVariant with correct padding |
| T4 | `LogoutFooter` renders divider + error-styled logout ListTile; invokes callback on tap |
| T5 | `NavigationDrawer` replaces `Drawer`; `UserRole?` replaces booleans; correct items per role; logout uses `showConfirmationDialog` |
| T6 | All three call sites compile with `role:` prop instead of `isScan:`/`isAdmin:` |
| T7 | `dart analyze` = 0 errors, `flutter test` = pass |

---

## Review workload forecast

| Task | Files changed | Est. lines changed |
|------|---------------|-------------------|
| T1 | 2 | +30 |
| T2 | 1 (new) | +65 |
| T3 | 1 (new) | +15 |
| T4 | 1 (new) | +35 |
| T5 | 1 (rewrite) | ~180 |
| T6 | 3 | ~9 |
| T7 | — | 0 (cleanup) |
| **Total** | **9** | **~334** |

**Single PR decision**: **Yes**. At ~334 lines this is well under the 400-line threshold for single-PR. All changes are within the same domain (drawer navigation), no stacked dependencies warrant branching. **No chaining needed**.

**Auto-forecast output**: single-pr-default