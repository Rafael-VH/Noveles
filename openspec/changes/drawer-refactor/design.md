# Technical Design: drawer-refactor

## 1. Architecture Overview

### 1.1 Current state

`AppDrawer` is a `StatelessWidget` that takes two boolean props (`isAdmin`, `isScan`) and uses a raw `Drawer` + `ListView` + `ListTile` combination. The header is inline via `DrawerHeader`. Logout confirmation is an inline `AlertDialog`. The unauthenticated case returns `SizedBox.shrink()` — no login option shown.

### 1.2 Target state

`AppDrawer` receives a single `UserRole?` param (replacing the two booleans) and optionally a `UserEntity?` to avoid re-reading from the bloc at the call site. It wraps `NavigationDrawer` + `BlocBuilder<AuthBloc, AuthState>` — the same auth pattern as today.

Three new widgets are extracted:

| Widget | Responsibility |
|--------|---------------|
| `AppDrawerHeader` | Gradient container, avatar (48px), display name, email — display only |
| `DrawerSectionLabel` | Section divider label (labelSmall, onSurfaceVariant) |
| `LogoutFooter` | Divider + "Cerrar Sesión" ListTile in error color, reuses `ConfirmationDialog` |

### 1.3 Key architectural decisions

| Decision | Rationale |
|----------|-----------|
| `NavigationDrawer` over `Drawer` | M3 built-in, zero deps, same system as `NavigationBar` already used |
| `NavigationDrawerDestination` over `ListTile` | M3-native destination widget, styled via `NavigationDrawerThemeData` |
| `UserRole?` over `bool isAdmin` + `bool isScan` | Enum already exists in `UserRole`, eliminates invalid state combos |
| `UserEntity?` as optional param | Allows call sites that already have the user to pass it directly, avoids extra bloc read |
| Widget extraction (header, label, footer) | Single-responsibility, testable in isolation, reusable |
| `ConfirmationDialog` reuse | Already exists in `shared/presentation/widgets/`, eliminates duplicate dialog code |
| No new packages | All widgets are from `package:flutter/material.dart` |
| No new routes | Navigation uses existing push/pushNamed patterns |

### 1.4 Why NavigationDrawer is correct

The project already has `useMaterial3: true` and uses M3 components like `NavigationBar` with `NavigationBarThemeData`. `NavigationDrawer` is the M3 successor of `Drawer` for side navigation. It:
- Has built-in support for `NavigationDrawerDestination` (widget)
- Accepts `NavigationDrawerThemeData` for theming (indicator shape, tile height, colors)
- Provides proper keyboard navigation out of the box
- Follows M3 spec for spacing and interaction patterns

---

## 2. Widget Tree

### 2.1 Authenticated (any role)

```
AppDrawer({UserEntity? user, UserRole? role})
└── BlocBuilder<AuthBloc, AuthState>
    └── if (state is AuthAuthenticated) →
        NavigationDrawer
        ├── AppDrawerHeader(user: authenticatedUser)
        │   └── Container(BoxDecoration(gradient: primary → primaryContainer))
        │       └── Column
        │           ├── CircleAvatar(radius: 24)          // 48px
        │           ├── Text(displayName, style: titleLarge, color: onPrimary)
        │           └── Text(email, style: bodySmall, color: onPrimary 80%)
        │
        ├── DrawerSectionLabel("Navegación")              // only if role has nav items
        ├── NavigationDrawerDestination(home)              // reader only
        ├── NavigationDrawerDestination(panelScan)         // scan only
        ├── NavigationDrawerDestination(panelAdmin)        // admin only
        │
        ├── DrawerSectionLabel("Perfil")                  // always if authenticated
        ├── NavigationDrawerDestination(editProfile)       // all roles
        ├── NavigationDrawerDestination(favorites)         // reader only
        │
        ├── DrawerSectionLabel("Gestión")                 // scan only
        ├── NavigationDrawerDestination(labels)            // scan only
        │
        ├── Spacer
        └── LogoutFooter(onLogout: _confirmLogout)
            └── Column
                ├── Divider
                └── ListTile(icon: Icons.logout, color: error, "Cerrar Sesión")
```

### 2.2 Unauthenticated (NEW)

```
AppDrawer({UserEntity: null, UserRole: null})
└── BlocBuilder<AuthBloc, AuthState>
    └── if (state is! AuthAuthenticated) →
        NavigationDrawer
        ├── AppDrawerHeader.simplified()
        │   └── Container(neutral gradient or surface color)
        │       └── Column
        │           ├── Icon(Icons.menu_book, size: 40, onSurfaceVariant)
        │           └── Text("Noveles", style: titleLarge)
        │
        └── NavigationDrawerDestination(login, Icons.login, "Iniciar Sesión")
            └── onTap → Navigator.pop + Navigator.pushNamed('/login')
```

---

## 3. Widget Specifications

### 3.1 `DrawerSectionLabel`

**File**: `lib/features/app/presentation/widgets/drawer/drawer_section_label.dart`

```dart
class DrawerSectionLabel extends StatelessWidget {
  final String label;
  const DrawerSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 4),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
```

- ~15 lines
- StatelessWidget, immutable
- No interaction, display only
- Padding: top 16, bottom 4, horizontal 28 (aligns with destination labels)
- Style: `labelSmall` from text theme, `onSurfaceVariant` color

### 3.2 `AppDrawerHeader`

**File**: `lib/features/app/presentation/widgets/drawer/app_drawer_header.dart`

**Named constructor**: `AppDrawerHeader({required UserEntity user, ...})`

```dart
class AppDrawerHeader extends StatelessWidget {
  final UserEntity user;
  final bool isSimplified;

  const AppDrawerHeader({required this.user, super.key, this.isSimplified = false});

  const AppDrawerHeader.simplified({super.key})
      : user = _emptyUser,
        isSimplified = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 192,  // ~180-200px
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
            backgroundImage: _backgroundImage(theme),
            child: _defaultAvatarIcon(theme),
          ),
          const SizedBox(height: 12),
          Text(
            isSimplified ? 'Noveles' : (user.displayName ?? user.email),
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
          if (!isSimplified)
            Text(
              user.email,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
    );
  }
}
```

- ~60 lines
- Height: 192px (fixed)
- Gradient: `primary` → `primaryContainer`, top → bottom
- BoxShadow: subtle, `shadow` at 15% alpha, blur 8, offset (0, 2)
- Padding: 24px all around
- Column aligned to bottom (avatar, name, email)
- Avatar: `CircleAvatar(radius: 24)` = 48px diameter
  - NetworkImage if `user.avatarUrl` is not empty, using `getIt<CoverUrlService>()`
  - Fallback: `Icon(Icons.person)` on translucent `onPrimary` background
- Name: `titleLarge`, `onPrimary` color
- Email: `bodySmall`, `onPrimary` at 80% alpha
- `simplified` constructor: shows app icon + "Noveles" title, no user data

### 3.3 `LogoutFooter`

**File**: `lib/features/app/presentation/widgets/drawer/logout_footer.dart`

```dart
class LogoutFooter extends StatelessWidget {
  final VoidCallback onLogout;
  const LogoutFooter({required this.onLogout, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(),
        ListTile(
          leading: Icon(Icons.logout, color: theme.colorScheme.error),
          title: Text(
            'Cerrar Sesión',
            style: TextStyle(color: theme.colorScheme.error),
          ),
          onTap: onLogout,
        ),
      ],
    );
  }
}
```

- ~40 lines
- StatelessWidget, receives `VoidCallback onLogout`
- Visual: `Divider` + `ListTile` with `Icons.logout` and "Cerrar Sesión" text
- Both icon and text use `colorScheme.error`
- `onLogout` is wired to `_confirmLogout` in `AppDrawer`, which calls `showConfirmationDialog`

### 3.4 `AppDrawer` (refactored)

**File**: `lib/features/app/presentation/widgets/app_drawer.dart`

#### Constructor

```dart
class AppDrawer extends StatelessWidget {
  final UserEntity? user;
  final UserRole? role;

  const AppDrawer({super.key, this.user, this.role});
}
```

- `role` replaces `isAdmin`/`isScan` booleans
- If both `user` and `role` are non-null, `role` takes precedence for filtering navigation items
- If `role` is null but `user` is provided, derive `role` from `user.role`
- If both are null, the widget reads `AuthState` from the bloc to determine role

#### Build logic

```dart
@override
Widget build(BuildContext context) {
  return BlocBuilder<AuthBloc, AuthState>(
    builder: (context, authState) {
      // Determine effective user and role
      final effectiveUser = user ?? (authState is AuthAuthenticated ? authState.user : null);
      final effectiveRole = role ?? effectiveUser?.role;
      final isAuthenticated = effectiveUser != null;

      return NavigationDrawer(
        children: [
          // ── Header ──
          if (isAuthenticated)
            AppDrawerHeader(user: effectiveUser!)
          else
            const AppDrawerHeader.simplified(),

          // ── Navigation Section (only if role has nav items) ──
          final navItems = _navItemsForRole(effectiveRole);
          if (navItems.isNotEmpty) ...[
            DrawerSectionLabel('Navegación'),
            ...navItems.map((item) => _buildDestination(context, item, effectiveUser)),
          ],

          // ── Profile Section (always if authenticated) ──
          if (isAuthenticated) ...[
            DrawerSectionLabel('Perfil'),
            ..._profileItemsForRole(effectiveRole).map(
              (item) => _buildDestination(context, item, effectiveUser),
            ),
          ],

          // ── Management Section (scan only) ──
          if (effectiveRole == UserRole.scan) ...[
            DrawerSectionLabel('Gestión'),
            ..._managementItems.map(
              (item) => _buildDestination(context, item, effectiveUser),
            ),
          ],

          // ── Login Destination (unauthenticated only) ──
          if (!isAuthenticated)
            _buildDestination(context, DrawerItem.login, null),

          // ── Spacer + Logout ──
          const Spacer(),
          if (isAuthenticated)
            LogoutFooter(onLogout: () => _confirmLogout(context)),
        ],
      );
    },
  );
}
```

#### _confirmLogout

```dart
void _confirmLogout(BuildContext context) {
  showConfirmationDialog(
    context: context,
    title: 'Cerrar Sesión',
    message: '¿Estás seguro de que deseas cerrar sesión?',
    confirmLabel: 'Cerrar Sesión',
    isDestructive: true,
  ).then((confirmed) {
    if (confirmed == true) {
      context.read<AuthBloc>().add(const LogoutRequested());
    }
  });
}
```

Reuses `showConfirmationDialog` from `shared/presentation/widgets/confirmation_dialog.dart`.

---

## 4. Role-Based Item Filtering

### 4.1 DrawerItem enum

```dart
enum DrawerItem {
  home,
  panelScan,
  panelAdmin,
  editProfile,
  favorites,
  labels,
  login,        // unauthenticated only
}
```

### 4.2 Role → Items mapping

```dart
const Map<UserRole, List<DrawerItem>> roleNavItems = {
  UserRole.user: [DrawerItem.home],
  UserRole.scan: [DrawerItem.panelScan],
  UserRole.admin: [DrawerItem.panelAdmin],
  UserRole.suspended: [],  // no navigation items
};

const Map<UserRole, List<DrawerItem>> roleProfileItems = {
  UserRole.user: [DrawerItem.editProfile, DrawerItem.favorites],
  UserRole.scan: [DrawerItem.editProfile],
  UserRole.admin: [DrawerItem.editProfile],
  UserRole.suspended: [DrawerItem.editProfile],
};
```

### 4.3 DrawerItem → visual properties

```dart
({IconData icon, String label, void Function(BuildContext, UserEntity?) action}) _itemConfig(DrawerItem item) {
  return switch (item) {
    DrawerItem.home     => (icon: Icons.home, label: 'Inicio',            action: _navigateHome),
    DrawerItem.panelScan  => (icon: Icons.qr_code_scanner, label: 'Panel Scan', action: _navigatePanelScan),
    DrawerItem.panelAdmin => (icon: Icons.admin_panel_settings, label: 'Panel Admin', action: _navigatePanelAdmin),
    DrawerItem.editProfile => (icon: Icons.person, label: 'Editar Perfil', action: _navigateEditProfile),
    DrawerItem.favorites => (icon: Icons.favorite, label: 'Mis Favoritos', action: _navigateFavorites),
    DrawerItem.labels    => (icon: Icons.label, label: 'Etiquetas',        action: _navigateLabels),
    DrawerItem.login     => (icon: Icons.login, label: 'Iniciar Sesión',   action: _navigateLogin),
  };
}
```

### 4.4 Builder helper

```dart
Widget _buildDestination(BuildContext context, DrawerItem item, UserEntity? user) {
  final config = _itemConfig(item);
  return NavigationDrawerDestination(
    icon: Icon(config.icon),
    label: Text(config.label),
    onTap: () => config.action(context, user),
  );
}
```

Note: `NavigationDrawerDestination` does not have an `onTap` property in Flutter. The actual tap handling is done by wrapping destinations in a `Listener` or using `NavigationDrawer`'s `onDestinationSelected`. The design in code will actually use `NavigationDrawer`'s built-in `onDestinationSelected` by mapping the flat list of visible items to indices. The implementer should flatten the visible items list and pass `selectedIndex` + `onDestinationSelected`.

**Implementation note**: `NavigationDrawer` uses `selectedIndex` / `onDestinationSelected` — not `onTap` per destination. The actual code will:

1. Build a flat `List<_VisibleItem>` of all visible items (sections are not destinations, so they go outside the destinations list)
2. Set `selectedIndex` to -1 (no selection) or track which item is active
3. Use `onDestinationSelected: (index) => _visibleItems[index].action(context, effectiveUser)`

---

## 5. Theme Changes

Add `navigationDrawerTheme` to both light and dark theme definitions, following the same pattern as `navigationBarTheme`.

### 5.1 Light Theme

Insert after `navigationBarTheme` (around line 151 in `light_theme.dart`):

```dart
// ── Navigation Drawer ────────────────────────────────────
navigationDrawerTheme: NavigationDrawerThemeData(
  backgroundColor: _LightColor.surface,
  indicatorColor: _LightColor.primaryContainer,
  indicatorShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  tileHeight: 56,
  labelTextStyle: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _LightColor.onSurface,
      );
    }
    return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: _LightColor.onSurfaceVariant,
    );
  }),
  iconTheme: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return const IconThemeData(color: _LightColor.primary);
    }
    return const IconThemeData(color: _LightColor.onSurfaceVariant);
  }),
),
```

### 5.2 Dark Theme

Insert after `navigationBarTheme` (around line 99 in `dark_theme.dart`):

```dart
// ── Navigation Drawer ────────────────────────────────────
navigationDrawerTheme: NavigationDrawerThemeData(
  backgroundColor: DarkColor.surface,
  indicatorColor: DarkColor.primaryContainer,
  indicatorShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  tileHeight: 56,
  labelTextStyle: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: DarkColor.onSurface,
      );
    }
    return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: DarkColor.onSurfaceVariant,
    );
  }),
  iconTheme: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return const IconThemeData(color: DarkColor.primary);
    }
    return const IconThemeData(color: DarkColor.onSurfaceVariant);
  }),
),
```

---

## 6. Call Site Changes

### 6.1 `main_screen.dart`

**Current** (lines 107-114):
```dart
drawer: Builder(
  builder: (context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    return AppDrawer(
      isScan: user?.isScan ?? false,
      isAdmin: user?.isAdmin ?? false,
    );
  },
),
```

**New**:
```dart
drawer: Builder(
  builder: (context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    return AppDrawer(user: user, role: user?.role);
  },
),
```

The `Builder` wrapping is still needed because `context.read<AuthBloc>()` needs the outer `Scaffold`'s context (not the `AppDrawer`'s context which is inside the drawer). But if `AppDrawer` uses `BlocBuilder` internally, we could simplify to:

```dart
drawer: const AppDrawer(),
```

This is the cleanest option — let `AppDrawer` handle auth state entirely internally. However, to avoid a breaking visual change during loading states, we keep the `Builder` pattern and pass the user down. **Recommended**: pass `user` directly, `role` derives from `user.role`.

### 6.2 `admin_dash_screen.dart`

**Current** (line 36):
```dart
drawer: const AppDrawer(isAdmin: true),
```

**New**:
```dart
drawer: AppDrawer(role: UserRole.admin),
```

Or if we want to pass the actual admin user:
```dart
drawer: AppDrawer(user: authState is AuthAuthenticated ? authState.user : null),
```

**Recommended**: pass `role: UserRole.admin` for simplicity — admin dash always shows admin items regardless of auth state within that screen. The `BlocBuilder` inside `AppDrawer` will handle unauthenticated edge cases.

### 6.3 `scan_main_screen.dart`

**Current** (line 52):
```dart
drawer: const AppDrawer(isScan: true),
```

**New**:
```dart
drawer: const AppDrawer(role: UserRole.scan),
```

---

## 7. Navigation Mapping

| DrawerItem | Icon | Label | Navigation Action |
|-----------|------|-------|------------------|
| `home` | `Icons.home` | "Inicio" | `Navigator.pop(context)` — stays on main screen |
| `panelScan` | `Icons.qr_code_scanner` | "Panel Scan" | `Navigator.pop(context)` — stays on scan screen |
| `panelAdmin` | `Icons.admin_panel_settings` | "Panel Admin" | `Navigator.pop(context)` then `Navigator.pushNamed(context, '/admin')` |
| `editProfile` | `Icons.person` | "Editar Perfil" | `Navigator.pop(context)` then `Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))` |
| `favorites` | `Icons.favorite` | "Mis Favoritos" | `Navigator.pop(context)` then `Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => getIt<FavoriteBloc>(), child: const FavoritesScreen())))` |
| `labels` | `Icons.label` | "Etiquetas" | `Navigator.pop(context)` then `Navigator.push(context, MaterialPageRoute(builder: (_) => const LabelManagementScreen()))` |
| `login` | `Icons.login` | "Iniciar Sesión" | `Navigator.pop(context)` then `Navigator.pushNamed(context, '/login')` |

**Important**: All navigation actions must first `Navigator.pop(context)` to close the drawer before pushing the next route. This is the existing behavior and must be preserved.

---

## 8. File Structure

```
lib/features/app/presentation/widgets/
├── app_drawer.dart                    ← REFACTORED (was ~162 lines, now ~180)
└── drawer/                            ← NEW directory
    ├── app_drawer_header.dart         ← NEW (~60 lines)
    ├── drawer_section_label.dart      ← NEW (~15 lines)
    └── logout_footer.dart             ← NEW (~40 lines)
```

### What stays the same

- `lib/features/app/presentation/widgets/app_drawer.dart` — file stays, content re-written
- `lib/core/utils/theme/light_theme.dart` — new section added, nothing removed
- `lib/core/utils/theme/dark_theme.dart` — new section added, nothing removed
- All three call sites — minimal prop changes

### What gets deleted

- `lib/features/app/presentation/widgets/app_drawer.dart` internal old code (replaced)
- No files are deleted

### What gets created

- `lib/features/app/presentation/widgets/drawer/app_drawer_header.dart`
- `lib/features/app/presentation/widgets/drawer/drawer_section_label.dart`
- `lib/features/app/presentation/widgets/drawer/logout_footer.dart`

---

## 9. Edge Cases & States

### 9.1 `UserRole.suspended`

The `UserRole` enum includes `suspended`. Suspended users should:
- See the `AppDrawerHeader` with their data (same as authenticated)
- See only the "Perfil" section with "Editar Perfil"
- NOT see any navigation items (no `roleNavItems`)
- See the `LogoutFooter`
- This is automatically handled by the role→items mapping returning `[]`

### 9.2 Loading / Initial state

While `AuthBloc` is in `AuthInitial` or `AuthLoading`:
- No user data is available
- `AppDrawer` should render the **unauthenticated** state (simplified header + login option)
- No flash of wrong content because the bloc builder rebuilds when state changes

### 9.3 Profile screen re-entry

The current implementation creates a new `FavoriteBloc` each time via `getIt<FavoriteBloc>()`. The proposal does not change this behavior — the same pattern is preserved in the refactored code.

### 9.4 Avatar URL handling

The same `CoverUrlService` from `getIt` is used to transform `avatarUrl` → full URL, identical to current behavior.

---

## 10. Testing Considerations

| Widget | What to test |
|--------|-------------|
| `AppDrawerHeader` | Renders gradient, avatar from URL or fallback, display name, email, `simplified` variant |
| `DrawerSectionLabel` | Renders label text with correct style |
| `LogoutFooter` | Renders divider, logout icon and text; invokes callback on tap |
| `AppDrawer` | Renders correct items per role, logout triggers confirmation dialog, unauthenticated shows login |
| Theme files | `NavigationDrawerThemeData` is applied and merges correctly |

---

## 11. Migration Plan

1. Create `drawer/app_drawer_header.dart` — new file
2. Create `drawer/drawer_section_label.dart` — new file
3. Create `drawer/logout_footer.dart` — new file
4. Add `NavigationDrawerThemeData` to `light_theme.dart`
5. Add `NavigationDrawerThemeData` to `dark_theme.dart`
6. Rewrite `app_drawer.dart` — new constructor, use NavigationDrawer, extracted widgets
7. Update `main_screen.dart` — change `AppDrawer` props
8. Update `admin_dash_screen.dart` — change `AppDrawer` props
9. Update `scan_main_screen.dart` — change `AppDrawer` props

Steps 1-3 and 4-5 can be done in parallel. Step 6 depends on 1-3. Steps 7-9 depend on 6.
