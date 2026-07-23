# Spec: drawer-refactor

> Delta spec for the drawer visual redesign. Based on proposal at `proposal.md`.

---

## 1. Functional requirements per role

### 1.1 reader (`UserRole.user`)

| Section | Item | Icon | Action |
|---------|------|------|--------|
| **Navegación** | Inicio | `Icons.home` | `Navigator.pop(context)` — cierra el drawer (ya está en home) |
| **Perfil** | Editar Perfil | `Icons.person` | `Navigator.pop(context)` + `Navigator.push → ProfileScreen` |
| **Perfil** | Mis Favoritos | `Icons.favorite` | `Navigator.pop(context)` + `Navigator.push → FavoritesScreen` (envuelto en `BlocProvider<FavoriteBloc>`) |
| _(footer)_ | Cerrar Sesión | `Icons.logout` (error color) | `showConfirmationDialog` → `AuthBloc.add(LogoutRequested())` |

**No mostrados**: Panel Admin, Panel Scan, Etiquetas.

### 1.2 scan (`UserRole.scan`)

| Section | Item | Icon | Action |
|---------|------|------|--------|
| **Navegación** | Panel Scan | `Icons.qr_code_scanner` | `Navigator.pop(context)` — cierra el drawer (ya está en scan panel) |
| **Perfil** | Editar Perfil | `Icons.person` | `Navigator.pop(context)` + `Navigator.push → ProfileScreen` |
| **Gestión** | Etiquetas | `Icons.label` | `Navigator.pop(context)` + `Navigator.push → LabelManagementScreen` |
| _(footer)_ | Cerrar Sesión | `Icons.logout` (error color) | `showConfirmationDialog` → `AuthBloc.add(LogoutRequested())` |

**No mostrados**: Inicio, Panel Admin, Mis Favoritos.

### 1.3 admin (`UserRole.admin`)

| Section | Item | Icon | Action |
|---------|------|------|--------|
| **Navegación** | Panel Admin | `Icons.admin_panel_settings` | `Navigator.pop(context)` + `Navigator.pushNamed(context, '/admin')` |
| **Perfil** | Editar Perfil | `Icons.person` | `Navigator.pop(context)` + `Navigator.push → ProfileScreen` |
| _(footer)_ | Cerrar Sesión | `Icons.logout` (error color) | `showConfirmationDialog` → `AuthBloc.add(LogoutRequested())` |

**No mostrados**: Inicio, Panel Scan, Mis Favoritos, Etiquetas.

### 1.4 unauthenticated (`AuthUnauthenticated`)

| Item | Icon | Action |
|------|------|--------|
| Iniciar Sesión | `Icons.login` | `Navigator.pop(context)` + `Navigator.pushNamed(context, '/login')` |

- Header simplificado: sin avatar ni datos de usuario. Muestra el logo de Noveles en tonos neutros/grises.
- Sin secciones, sin Cerrar Sesión.
- Drawer visible (no `SizedBox.shrink()` como hoy).

---

## 2. Visual requirements

### 2.1 Header: `AppDrawerHeader`

| Propiedad | Valor |
|-----------|-------|
| Fondo | Gradiente vertical: `primary` → `primaryContainer` (`LinearGradient`). Sin valores fijos de color — usa `colorScheme` del theme. |
| Sombra | `BoxShadow` sutil con `blurRadius: 4`, `offset: Offset(0, 2)`, color `shadow` con 15% opacidad. Opcional: `elevation: 2` en lugar de shadow manual. |
| Padding | `EdgeInsets.symmetric(horizontal: 16, vertical: 24)` |
| Avatar | `CircleAvatar(radius: 24)` (48px diámetro). `backgroundImage` si `avatarUrl` no vacío (vía `CoverUrlService`), fallback `Icon(Icons.person, size: 32)`. |
| Nombre | `displayName ?? email` en `titleLarge`, color `onPrimary`. |
| Email | `email` en `bodySmall`, color `onPrimary` con 80% de opacidad (`Color.withValues(alpha: 0.8)`). |
| Espaciado | 12px entre avatar y texto, 4px entre nombre y email. |

**Estado no autenticado**:
- Fondo: mismo gradiente pero en grises (puede reusar `surfaceContainerHighest` o un gradiente apagado).
- Sin avatar. Muestra el nombre de la app "Noveles" en `titleLarge` centrado, color `onSurface`.
- Sin email.

### 2.2 Section labels: `DrawerSectionLabel`

| Propiedad | Valor |
|-----------|-------|
| Texto | `labelSmall` typography del theme, color `onSurfaceVariant`. |
| Padding | `EdgeInsets.only(top: 24, bottom: 8, left: 28, right: 16)` — generoso arriba para separar secciones. |
| Estilo adicional | Puede usar `.toUpperCase()` si se desea, pero no es necesario para la spec. Lo que importa es que se distinga visualmente de los destinos. |

### 2.3 Navigation items

Usar `NavigationDrawerDestination` de Material 3, **no** `ListTile`.

| Propiedad | Valor |
|-----------|-------|
| icon | Icono del item según tabla de sección 1 |
| label | `Text(título del item)` |
| Indicador de selección | `indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))` |
| tileHeight | 56px — para espaciado generoso entre items |
| Label style | predeterminado del `NavigationDrawerThemeData` |

**Nota**: El drawer actual no tiene estado de selección (no "recuerda" qué item estaba activo). La selección visual se aplica al item de navegación principal de cada rol (Inicio para reader, Panel Scan para scan, Panel Admin para admin) como seleccionado por defecto, ya que el drawer se abre sobre esa pantalla.

### 2.4 Logout footer

| Propiedad | Valor |
|-----------|-------|
| Posición | Siempre al fondo, separado por `Spacer` del contenido de navegación. |
| Estilo | **NO** es un `NavigationDrawerDestination`. Es un widget independiente (`LogoutFooter`) con: |
| | `ListTile` o `TextButton.icon` con `Icons.logout`, color `error` en icono y texto. |
| | Opcional: un `Divider` sutil encima para separación visual. |
| Padding | `EdgeInsets.only(bottom: 16)` para separación del borde inferior. |

### 2.5 Layout general del `NavigationDrawer`

```
NavigationDrawer
├── AppDrawerHeader (gradient, avatar, name, email)
├── DrawerSectionLabel("Navegación")
├── NavigationDrawerDestination (item principal del rol)  ← selected
│
├── DrawerSectionLabel("Perfil")
├── NavigationDrawerDestination (Editar Perfil)
├── NavigationDrawerDestination (Mis Favoritos)  ← solo reader
│
├── DrawerSectionLabel("Gestión")  ← solo scan
├── NavigationDrawerDestination (Etiquetas)  ← solo scan
│
├── Spacer
├── [Divider opcional]
└── LogoutFooter
```

---

## 3. Non-functional requirements

### 3.1 Technical constraints

| # | Requisito |
|---|-----------|
| NFR-1 | Debe usar `NavigationDrawer` del package `package:flutter/material.dart`. Sin dependencias externas. |
| NFR-2 | Debe preservar todo el comportamiento de navegación existente: `Navigator.pop()`, `Navigator.push()`, `Navigator.pushNamed()` exactamente como hoy. |
| NFR-3 | Debe usar `showConfirmationDialog` desde `shared/presentation/widgets/confirmation_dialog.dart` para el logout — no escribir un `AlertDialog` manual. |
| NFR-4 | El widget `AppDrawer` debe seguir siendo un `StatelessWidget`. |
| NFR-5 | El tema debe ser configurable vía `NavigationDrawerThemeData` en ambos `light_theme.dart` y `dark_theme.dart`. |
| NFR-6 | El prop `UserRole?` reemplaza los booleanos `isScan` / `isAdmin`. El valor `null` representa usuario no autenticado. |

### 3.2 Theme: `NavigationDrawerThemeData`

Valores sugeridos para ambos temas:

```dart
navigationDrawerTheme: NavigationDrawerThemeData(
  indicatorShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  ),
  tileHeight: 56,
  backgroundColor: colorScheme.surface,        // o surfaceContainerLow en M3
  surfaceTintColor: Colors.transparent,
  indicatorColor: colorScheme.primaryContainer, // pill background
),
```

### 3.3 Widget structure

```
lib/features/app/presentation/widgets/
├── drawer/
│   ├── app_drawer_header.dart       # NEW — header widget
│   ├── drawer_section_label.dart    # NEW — section label widget
│   └── logout_footer.dart           # NEW — logout button widget
└── app_drawer.dart                  # REWRITE — main drawer
```

### 3.4 Signature change

```dart
// ANTES
class AppDrawer extends StatelessWidget {
  final bool isScan;
  final bool isAdmin;
  // ...
}

// DESPUÉS
class AppDrawer extends StatelessWidget {
  final UserRole? role;
  // ...
}
```

### 3.5 Caller changes

```dart
// main_screen.dart (antes)
AppDrawer(
  isScan: user?.isScan ?? false,
  isAdmin: user?.isAdmin ?? false,
);

// main_screen.dart (después)
AppDrawer(role: user?.role);

// admin_dash_screen.dart (antes)
const AppDrawer(isAdmin: true);

// admin_dash_screen.dart (después)
const AppDrawer(role: UserRole.admin);

// scan_main_screen.dart (antes)
const AppDrawer(isScan: true);

// scan_main_screen.dart (después)
const AppDrawer(role: UserRole.scan);
```

---

## 4. States

### 4.1 States matrix

| State | Relevance | Behavior |
|-------|-----------|----------|
| Loading | N/A | El drawer no tiene estado asíncrono propio. No aplica. |
| Empty | N/A | El drawer siempre muestra contenido (header + al menos un item, o login si no autenticado). No aplica. |
| Error | N/A | El drawer no tiene operaciones propias. No aplica. |

### 4.2 Edge cases

| # | Caso | Comportamiento esperado |
|---|------|------------------------|
| EC-1 | **Usuario no autenticado** (`AuthUnauthenticated`) | Header simplificado + `NavigationDrawerDestination` con "Iniciar Sesión". Sin Cerrar Sesión. Sin secciones. |
| EC-2 | **Usuario sin avatar** (`avatarUrl` vacío o null) | `CircleAvatar` sin `backgroundImage`. Mostrar `Icon(Icons.person, size: 32)` como child. |
| EC-3 | **Usuario sin `displayName`** (`displayName` null) | Usar `email` en lugar de `displayName` para el texto del nombre en el header. |
| EC-4 | **Ambos `isScan` y `isAdmin` verdaderos** (imposible por `UserRole` enum) | Con `UserRole`, es imposible tener ambos valores simultáneamente. No requiere manejo. Si por algún error de datos ocurriera, el `UserRole.admin` prevalece al ser el más permisivo (el proposal establece que admin puede hacer todo, pero el drawer sigue la tabla de items de admin). |
| EC-5 | **Usuario suspendido** (`UserRole.suspended`) | Tratar como no autenticado: mostrar header simplificado + "Iniciar Sesión". El drawer no es responsable de prevenir acciones — eso lo maneja la capa de dominio. |
| EC-6 | **Avatar URL inválida** (NetworkImage falla) | Flutter maneja el error silenciosamente: `CircleAvatar` muestra el color de fondo sin imagen. No implementar fallback adicional (comportamiento M3 por defecto). |

---

## 5. Scenarios

### Scenario 1: "User opens drawer and sees role-appropriate menu items"

**Given** a user with `UserRole.user` (reader) is authenticated  
**When** they open the drawer  
**Then** they see:
- Header with their avatar, name, and email
- Section "Navegación" with "Inicio" (selected)
- Section "Perfil" with "Editar Perfil" and "Mis Favoritos"
- "Cerrar Sesión" at the bottom in error color
- No "Panel Admin", no "Panel Scan", no "Etiquetas"

**Given** a user with `UserRole.scan`  
**Then** they see "Panel Scan" (selected), "Editar Perfil", "Etiquetas", and "Cerrar Sesión". No "Inicio", no "Panel Admin", no "Mis Favoritos".

**Given** a user with `UserRole.admin`  
**Then** they see "Panel Admin" (selected), "Editar Perfil", and "Cerrar Sesión". No "Inicio", no "Panel Scan", no "Mis Favoritos", no "Etiquetas".

### Scenario 2: "User taps a menu item and navigates to the correct screen"

**Given** the drawer is open  
**When** the user taps a menu item  
**Then** the drawer closes via `Navigator.pop(context)`  
**And** the corresponding screen is pushed (or no push for home/main items that pop only)

| Item | Navigates to |
|------|-------------|
| Inicio | No push — solo `Navigator.pop()` |
| Panel Scan | No push — solo `Navigator.pop()` |
| Panel Admin | `Navigator.pushNamed(context, '/admin')` |
| Editar Perfil | `Navigator.push(context, MaterialPageRoute → ProfileScreen())` |
| Mis Favoritos | `Navigator.push` con `BlocProvider<FavoriteBloc>` + `FavoritesScreen` |
| Etiquetas | `Navigator.push(context, MaterialPageRoute → LabelManagementScreen())` |

### Scenario 3: "User taps logout and sees confirmation dialog"

**Given** the drawer is open  
**When** the user taps "Cerrar Sesión"  
**Then** `showConfirmationDialog` is called with `isDestructive: true`  
**And** the dialog displays "¿Estás seguro de que deseas cerrar sesión?"  
**When** the user taps "Cancelar"  
**Then** the dialog closes, no action is taken  
**When** the user taps "Cerrar Sesión" in the dialog  
**Then** the dialog closes **and** `AuthBloc.add(LogoutRequested())` is dispatched

### Scenario 4: "Unauthenticated user sees login option instead of empty drawer"

**Given** the user is not authenticated (`AuthUnauthenticated`)  
**When** they open the drawer  
**Then** they see a simplified header with "Noveles" and a "Iniciar Sesión" option  
**When** they tap "Iniciar Sesión"  
**Then** the drawer closes and `Navigator.pushNamed(context, '/login')` navigates to the login screen

### Scenario 5: "User with avatar sees their avatar in the header"

**Given** the user has `avatarUrl` set  
**When** they open the drawer  
**Then** the header shows a `CircleAvatar(radius: 24)` with `backgroundImage: NetworkImage(coverUrlService(user.avatarUrl))`

### Scenario 6: "User without avatar sees the fallback person icon"

**Given** the user has no `avatarUrl` (null or empty)  
**When** they open the drawer  
**Then** the header shows a `CircleAvatar(radius: 24)` with child `Icon(Icons.person, size: 32)`  
**And** no `backgroundImage` is set

### Scenario 7: "User without displayName sees email in header"

**Given** the user has `displayName` as null  
**When** they open the drawer  
**Then** the name text displays the user's `email` instead  
**And** the email line below still shows the email (same text, no duplication concern — it follows the same pattern as the current implementation)

---

## 6. Files affected

| File | Action | Est. lines |
|------|--------|-----------|
| `lib/features/app/presentation/widgets/drawer/app_drawer_header.dart` | Create | ~65 |
| `lib/features/app/presentation/widgets/drawer/drawer_section_label.dart` | Create | ~15 |
| `lib/features/app/presentation/widgets/drawer/logout_footer.dart` | Create | ~40 |
| `lib/features/app/presentation/widgets/app_drawer.dart` | Rewrite | ~180 |
| `lib/core/utils/theme/light_theme.dart` | Modify: add `navigationDrawerTheme` | +15 |
| `lib/core/utils/theme/dark_theme.dart` | Modify: add `navigationDrawerTheme` | +15 |
| `lib/features/app/presentation/screens/main_screen.dart` | Modify: `role: user?.role` | ~5 |
| `lib/features/admin/presentation/screens/admin_dash_screen.dart` | Modify: `role: UserRole.admin` | ~5 |
| `lib/features/scan/presentation/screens/scan_main_screen.dart` | Modify: `role: UserRole.scan` | ~2 |